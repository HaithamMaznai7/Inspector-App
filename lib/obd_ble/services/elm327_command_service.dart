import 'dart:async';
import 'dart:convert';

import 'package:fahis_inspector/obd_ble/protocol/elm327_commands.dart';
import 'package:fahis_inspector/obd_ble/protocol/elm327_parser.dart';
import 'package:fahis_inspector/obd_ble/protocol/errors.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';

/// Sends ELM327 ASCII commands and accumulates the streamed BLE response
/// until the prompt character `>` arrives — then returns the trimmed body.
///
/// Single-flight: only one command runs at a time (an internal completer
/// queue serializes calls). Required because the device returns responses
/// in arrival order and we need to associate each one with its sender.
class Elm327CommandService {
  final Future<void> Function(List<int>) writeBytes;
  final Stream<List<int>> notifications;

  final Duration commandTimeout;
  final Duration resetTimeout;

  Elm327CommandService({
    required this.writeBytes,
    required this.notifications,
    this.commandTimeout = const Duration(seconds: 20),
    this.resetTimeout = const Duration(seconds: 20),

    // this.commandTimeout = const Duration(seconds: 5),
    // this.resetTimeout = const Duration(seconds: 3),
  });

  // Lock so only one command can be in-flight at a time.
  Future<void> _lock = Future.value();

  /// Runs the ELM init sequence. Throws [ElmInitException] on the first
  /// command that doesn't return `OK`. The reset banner is ignored — we just
  /// wait for the prompt.
  Future<void> initialize() async {
    for (final cmd in Elm327Commands.initSequence) {
      final timeout = cmd == Elm327Commands.reset
          ? resetTimeout
          : commandTimeout;
      final response = await sendCommand(cmd, timeout: timeout);

      // ATZ returns a banner, not OK — accept any non-error response.
      if (cmd == Elm327Commands.reset) continue;

      if (!Elm327Parser.isOk(response)) {
        throw ElmInitException(cmd, response);
      }
    }
  }

  /// Sends Mode 03 (read stored DTCs) and parses the response into a list of
  /// DTC strings like `"P0123"`. Returns `[]` for `NO DATA` or all-zero
  /// (padding) responses. Encapsulates send + parse so callers don't depend
  /// on the parser directly.
  Future<List<String>> readDtcs() async {
    final raw = await sendCommand(Elm327Commands.readDtcs);
    return Elm327Parser.parseDtcResponse(raw);
  }

  /// Sends [cmd] (a bare ASCII string, no `\r`) and returns the device's
  /// response stripped of the prompt and trailing whitespace. Throws
  /// [ElmTimeoutException] if no prompt arrives within [timeout].
  Future<String> sendCommand(String cmd, {Duration? timeout}) {
    final t = timeout ?? commandTimeout;

    // Chain onto the lock so commands run strictly serially.
    final completer = Completer<String>();
    _lock = _lock.then((_) async {
      try {
        final result = await _runOne(cmd, t);
        if (!completer.isCompleted) completer.complete(result);
      } catch (e, st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<String> _runOne(String cmd, Duration timeout) async {
    final buffer = StringBuffer();
    final done = Completer<String>();
    late final StreamSubscription<List<int>> sub;

    // Subscribe BEFORE writing — ELM responses can come back faster than the
    // listener-attach if we do it the other way around.
    sub = notifications.listen((bytes) {
      try {
        buffer.write(utf8.decode(bytes, allowMalformed: true));
      } catch (_) {
        // Best-effort decode; keep listening.
      }
      final s = buffer.toString();
      if (s.contains('>')) {
        final body = s.substring(0, s.indexOf('>'));
        if (!done.isCompleted) done.complete(body);
      }
    });

    try {
      AppLogger.log('[OBD ELM]', 'TX: $cmd');
      await writeBytes(utf8.encode('$cmd\r'));

      final body = await done.future.timeout(
        timeout,
        onTimeout: () {
          throw ElmTimeoutException(timeout);
        },
      );
      final cleaned = _stripEcho(body, cmd);
      AppLogger.log('[OBD ELM]', 'RX: ${_oneLine(cleaned)}');
      return cleaned.trim();
    } finally {
      await sub.cancel();
    }
  }

  static String _oneLine(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Strips a leading echo of [cmd] from [body]. ELM327 defaults to echo-on
  /// (`ATE1`); the reply to every command therefore starts with the bytes
  /// `<cmd>\r` until `ATE0` is processed by the chip — and `ATE0`'s own
  /// reply still carries the echo because echo was still on when `ATE0`
  /// arrived. Without this strip, `Elm327Parser.isOk("ATE0\rOK")` returns
  /// false and init aborts on a perfectly correct adapter response.
  ///
  /// Defensive against three observed firmware variants:
  ///   - exact echo:   `<cmd>\r<response>` (the documented form, our log).
  ///   - CR-less echo: `<cmd><response>` (some no-name clones).
  ///   - leading-CR:   `\r\r<cmd>\r<response>` (a few BM-78 builds).
  /// On adapters that don't echo at all (the post-`ATE0` steady state), all
  /// three branches fall through and `body` is returned unchanged.
  static String _stripEcho(String body, String cmd) {
    final stripped = body.replaceFirst(RegExp(r'^[\r\n]+'), '');
    if (stripped.startsWith('$cmd\r')) {
      return stripped.substring(cmd.length + 1);
    }
    if (stripped.startsWith(cmd)) {
      return stripped.substring(cmd.length);
    }
    return body;
  }
}
