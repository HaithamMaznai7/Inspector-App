import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/models/vehicle.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';

// TODO(backend-swap): Replace this entire class with a backend call to
// POST /api/v1/dtc/describe once the Laravel endpoint is live. The API
// key is exposed in the shipped binary as long as this file exists —
// testing-phase only. Do NOT publish or push public with the key set.
const String _apiKey = '';

const String _endpoint = 'https://api.anthropic.com/v1/messages';
const String _model = 'claude-sonnet-4-6';
const int _maxTokens = 500;
const int _temperature = 0;
const Duration _httpTimeout = Duration(seconds: 20);

/// Structured result returned by [DtcDescriptionService.describe].
/// Only [description] is saved to the backend — [causes] and [suggestion]
/// are displayed in-app for readability and discarded on submit.
class DtcResult {
  final String description;
  final String causes;
  final String suggestion;

  const DtcResult({
    required this.description,
    required this.causes,
    required this.suggestion,
  });

  bool get hasCauses => causes.isNotEmpty;
  bool get hasSuggestion => suggestion.isNotEmpty;
}

class DtcDescriptionService {
  DtcDescriptionService._();

  static Future<DtcResult?> describe({
    required String dtc,
    Vehicle? vehicle,
    String? vin,
    required String lang,
  }) async {
    if (_apiKey.isEmpty) {
      AppLogger.error('[DTC]', 'ANTHROPIC API key constant is empty');
      FLoader.errorSnackBar(
        title: 'AI key missing',
        message: 'Set _apiKey in dtc_description_service.dart',
      );
      return null;
    }

    final systemPrompt = lang == 'ar' ? _systemPromptAr : _systemPromptEn;
    final userPrompt = _buildUserPrompt(
      dtc: dtc,
      vehicle: vehicle,
      vinOverride: vin,
      lang: lang,
    );

    AppLogger.log('[DTC]', 'describe → $dtc lang=$lang');

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = _httpTimeout;

      final req = await client
          .postUrl(Uri.parse(_endpoint))
          .timeout(_httpTimeout);
      req.headers.set('x-api-key', _apiKey);
      req.headers.set('anthropic-version', '2023-06-01');
      req.headers.contentType = ContentType.json;

      final body = jsonEncode({
        'model': _model,
        'max_tokens': _maxTokens,
        'temperature': _temperature,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      });
      req.add(utf8.encode(body));

      final res = await req.close().timeout(_httpTimeout);
      final raw = await res
          .transform(utf8.decoder)
          .join()
          .timeout(_httpTimeout);

      if (res.statusCode != 200) {
        AppLogger.error(
          '[DTC]',
          'HTTP ${res.statusCode}: ${_truncate(raw, 500)}',
        );
        FLoader.errorSnackBar(
          title: 'AI failed (${res.statusCode})',
          message: _shortError(res.statusCode),
        );
        return null;
      }

      final Map<String, dynamic> body200;
      try {
        body200 = jsonDecode(raw) as Map<String, dynamic>;
      } on FormatException catch (e) {
        AppLogger.error(
          '[DTC]',
          'malformed JSON: $e — raw=${_truncate(raw, 500)}',
        );
        FLoader.errorSnackBar(title: 'AI bad response');
        return null;
      }

      final content = body200['content'];
      if (content is! List || content.isEmpty) {
        AppLogger.error('[DTC]', 'empty/invalid content array');
        FLoader.errorSnackBar(title: 'AI returned empty');
        return null;
      }
      final first = content.first;
      if (first is! Map) {
        AppLogger.error('[DTC]', 'content[0] is not a Map');
        FLoader.errorSnackBar(title: 'AI bad shape');
        return null;
      }
      final text = (first['text'] as String?)?.trim();
      if (text == null || text.isEmpty) {
        AppLogger.error('[DTC]', 'whitespace-only text');
        return null;
      }

      final usage = body200['usage'];
      if (usage is Map) {
        AppLogger.log(
          '[DTC]',
          'in=${usage['input_tokens']} out=${usage['output_tokens']}',
        );
      }

      final result = _parseResponse(text, lang);
      AppLogger.log(
        '[DTC]',
        'describe ✓ $dtc → desc=${result.description.length}c',
      );
      return result;
    } on TimeoutException {
      AppLogger.error('[DTC]', 'timeout >${_httpTimeout.inSeconds}s');
      FLoader.errorSnackBar(
        title: 'AI timeout',
        message: 'description not generated',
      );
      return null;
    } on SocketException catch (e) {
      AppLogger.error('[DTC]', 'network: $e');
      FLoader.errorSnackBar(
        title: 'Network error',
        message: 'cannot reach AI service',
      );
      return null;
    } on HttpException catch (e) {
      AppLogger.error('[DTC]', 'http: $e');
      FLoader.errorSnackBar(title: 'AI HTTP error', message: e.message);
      return null;
    } catch (e, st) {
      AppLogger.error('[DTC]', 'unexpected: $e', st);
      FLoader.errorSnackBar(title: 'AI failed', message: e.toString());
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  static DtcResult _parseResponse(String text, String lang) {
    final isAr = lang == 'ar';

    final descHeader = isAr ? 'الوصف:' : 'Description:';
    final causesHeader = isAr ? 'الأسباب المحتملة:' : 'Likely causes:';
    final actionHeader = isAr ? 'الإجراء المقترح:' : 'Suggested action:';

    String extract(String start, String? end) {
      final startIdx = text.indexOf(start);
      if (startIdx == -1) return '';
      final from = startIdx + start.length;
      final endIdx = end != null ? text.indexOf(end, from) : -1;
      final raw = endIdx == -1
          ? text.substring(from)
          : text.substring(from, endIdx);
      return raw.trim();
    }

    final description = extract(descHeader, causesHeader);
    final causes = extract(causesHeader, actionHeader);
    final suggestion = extract(actionHeader, null);

    // Fallback: if parsing found nothing, put everything in description.
    if (description.isEmpty) {
      return DtcResult(description: text, causes: '', suggestion: '');
    }

    return DtcResult(
      description: description,
      causes: causes,
      suggestion: suggestion,
    );
  }

  // ── Prompt building ───────────────────────────────────────────────────────

  static String _buildUserPrompt({
    required String dtc,
    Vehicle? vehicle,
    String? vinOverride,
    required String lang,
  }) {
    String? orNull(String? s) =>
        (s == null || s.trim().isEmpty) ? null : s.trim();

    final vin = orNull(vinOverride) ?? orNull(vehicle?.vin) ?? '';
    final make = orNull(vehicle?.make?.label);
    final model = orNull(vehicle?.model?.label);
    final year = orNull(vehicle?.year);

    final buf = StringBuffer()
      ..writeln('DTC: $dtc')
      ..writeln('VIN: $vin');

    final vehicleParts = [year, make, model].whereType<String>().toList();
    if (vehicleParts.isNotEmpty) {
      buf.writeln('Vehicle: ${vehicleParts.join(' ')}');
    }

    buf.write('Language: $lang');
    return buf.toString();
  }

  static String _shortError(int status) {
    switch (status) {
      case 401:
        return 'bad API key';
      case 429:
      case 529:
        return 'rate-limited / overloaded';
      default:
        if (status >= 500) return 'server error';
        return 'check logs';
    }
  }

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}…';

  // ── System prompts ────────────────────────────────────────────────────────

  static const String _systemPromptEn = '''
You are an automotive diagnostic expert helping workshop mechanics.

Given an OBD-II code and vehicle info, respond with exactly three sections in this order:

Description:
One or two clear sentences explaining what this fault means on this vehicle.

Likely causes:
- Cause one
- Cause two
- Cause three

Suggested action:
One or two sentences on what to inspect or test first.

Rules:
- Use the SAE J2012 standard text for generic codes (P0xxx, P2xxx, P34xx–P39xx, B0xxx, C0xxx, U0xxx).
- Use the manufacturer-documented description for brand-specific codes (P1xxx, P3xxx 0–3, B/C/U 1–3xxx).
- If vehicle context is missing, give the most likely generic interpretation and note "Vehicle context not provided" in the Description.
- If the code cannot be identified, write only: "Description:\nInsufficient data. Consult the manufacturer service manual."
- Never invent causes or procedures.
- Do not repeat the DTC code in the body.
- Keep total output between 80 and 130 words.
- Write clearly. No jargon. Easy for a mechanic to read.
''';

  static const String _systemPromptAr = '''
أنت خبير تشخيص سيارات متخصص في مساعدة فنيي الورش.

بناءً على رمز OBD-II ومعلومات السيارة، أجب بثلاثة أقسام بهذا الترتيب تماماً:

الوصف:
جملة أو جملتان واضحتان تشرحان معنى هذا العطل على هذه السيارة.

الأسباب المحتملة:
- السبب الأول
- السبب الثاني
- السبب الثالث

الإجراء المقترح:
جملة أو جملتان حول أول شيء يجب فحصه أو اختباره.

القواعد:
- استخدم النص المعياري SAE J2012 للأكواد العامة (P0xxx, P2xxx, P34xx–P39xx, B0xxx, C0xxx, U0xxx).
- استخدم وصف الشركة المصنّعة للأكواد الخاصة (P1xxx, P3xxx 0–3, B/C/U 1–3xxx).
- إذا كانت بيانات السيارة غير متوفرة، أعطِ التفسير الأرجح وأضف في الوصف: "لم يتم توفير معلومات السيارة".
- إذا تعذّر تحديد الكود، اكتب فقط: "الوصف:\nبيانات غير كافية. راجع دليل الصيانة الخاص بالشركة المصنّعة."
- لا تخترع أسباباً أو إجراءات.
- لا تكرر رمز الكود داخل النص.
- اجعل الإخراج بين 80 و 130 كلمة.
- اكتب بأسلوب واضح ومباشر يفهمه الفني بسهولة.
''';
}
