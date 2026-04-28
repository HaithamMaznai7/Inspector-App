/// Pure-function parsers for ELM327 ASCII responses.
///
/// All inputs are the raw response string returned by the command service
/// (prompt `>` already stripped, but newlines/spaces may still be present).
class Elm327Parser {
  Elm327Parser._();

  /// True if [response] is the bare success acknowledgement.
  static bool isOk(String response) =>
      _normalize(response).toUpperCase() == 'OK';

  /// True if the device explicitly reported "no data" — typical for Mode 03
  /// when the car's ECU has no stored DTCs.
  static bool isNoData(String response) =>
      _normalize(response).toUpperCase().contains('NO DATA');

  /// True if [response] is one of the documented ELM327 vehicle-comms errors.
  /// These signal that the chip itself is healthy but it could not talk to
  /// the car's ECU — e.g. ignition off, OBD port not seated, ECU asleep, or
  /// an unsupported protocol on this vehicle.
  ///
  /// Distinct from [isNoData], which is a *successful* "ECU answered with
  /// zero DTCs" reply. Distinct from `OK`, which is a successful AT command.
  ///
  /// The list is from the ELM327 datasheet (Elm Electronics, rev. 1.4):
  ///   - `UNABLE TO CONNECT` — auto-detect could not find a responding ECU.
  ///   - `BUS INIT...ERROR`  — ISO 9141 / 14230 init failed (K-line cars).
  ///   - `BUS ERROR`         — generic CAN/J1850 frame error.
  ///   - `BUS BUSY`          — bus is too busy to insert a frame.
  ///   - `CAN ERROR`         — CAN-specific arbitration / framing error.
  ///   - `STOPPED`           — chip was interrupted mid-search.
  ///   - bare `?`            — the chip didn't recognise the command we sent
  ///                           (only matches a `?` standing alone, so we
  ///                           don't false-positive on a `?` inside data).
  static bool isConnectionError(String response) {
    final n = _normalize(response).toUpperCase();
    if (n == '?') return true;
    return n.contains('UNABLE TO CONNECT') ||
        n.contains('BUS INIT') ||
        n.contains('BUS ERROR') ||
        n.contains('BUS BUSY') ||
        n.contains('CAN ERROR') ||
        n.contains('STOPPED');
  }

  /// Parses a Mode 03 (read DTCs) response into a list of DTC strings like
  /// `"P0123"`. Returns an empty list for `NO DATA`, `43 00`, or unparseable
  /// input. Skips zero-padded entries.
  ///
  /// Handles single-line responses (`"43 01 00 02 00\r>"`) and multi-line
  /// ISO-TP responses (`"010: 43 04 01 00 02..."`). Echo of the request
  /// (e.g. a leading `"03"`) is tolerated and skipped.
  static List<String> parseDtcResponse(String raw) {
    if (isNoData(raw)) return const [];

    final hex = _extractHex(raw);
    if (hex.isEmpty) return const [];

    // Walk byte pairs looking for the Mode 03 response header (0x43). Some
    // adapters prefix with a length byte (e.g. ISO 9141), some don't — scan
    // until we find 0x43 then read DTC pairs from there.
    final headerIndex = hex.indexOf(0x43);
    if (headerIndex < 0) return const [];

    final dtcBytes = hex.sublist(headerIndex + 1);

    final out = <String>[];
    for (var i = 0; i + 1 < dtcBytes.length; i += 2) {
      final b1 = dtcBytes[i];
      final b2 = dtcBytes[i + 1];
      if (b1 == 0 && b2 == 0) continue; // padding / no-DTC slot
      final dtc = _decodeDtc(b1, b2);
      if (!out.contains(dtc)) out.add(dtc);
    }
    return out;
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  /// Strips ELM line prefixes (`"0:"`, `"1:"`, …) and whitespace, then
  /// converts every contiguous pair of hex chars into a byte. Non-hex tokens
  /// are skipped silently — handles echo (`"03"`), banners, and stray text.
  static List<int> _extractHex(String raw) {
    final cleaned = raw
        .split(RegExp(r'[\r\n]+'))
        .map((line) {
          // Strip leading `"<digit>:"` line prefix used by ISO-TP multi-frame.
          final m = RegExp(r'^\s*[0-9A-Fa-f]:\s*').firstMatch(line);
          return m != null ? line.substring(m.end) : line;
        })
        .join(' ');

    // Match runs of hex digits — each run is treated as a sequence of bytes.
    final bytes = <int>[];
    final re = RegExp(r'[0-9A-Fa-f]+');
    for (final m in re.allMatches(cleaned)) {
      final token = m.group(0)!;
      // Walk the token two chars at a time. Odd trailing nibble is ignored.
      for (var i = 0; i + 1 < token.length; i += 2) {
        final byte = int.tryParse(token.substring(i, i + 2), radix: 16);
        if (byte != null) bytes.add(byte);
      }
    }
    return bytes;
  }

  /// Decodes a 2-byte DTC into the standard 5-char form (e.g. `"P0123"`).
  /// See SAE J2012 — top 2 bits select the system letter, next 2 bits + low
  /// nibble form the first two digits, byte 2 forms the last two.
  static String _decodeDtc(int b1, int b2) {
    const letters = ['P', 'C', 'B', 'U'];
    final letter = letters[(b1 >> 6) & 0x03];
    final d1 = (b1 >> 4) & 0x03;
    final d2 = b1 & 0x0F;
    final d3 = (b2 >> 4) & 0x0F;
    final d4 = b2 & 0x0F;
    return '$letter$d1${d2.toRadixString(16).toUpperCase()}'
        '${d3.toRadixString(16).toUpperCase()}'
        '${d4.toRadixString(16).toUpperCase()}';
  }

  static String _normalize(String s) =>
      s.replaceAll(RegExp(r'[\r\n>]+'), '').trim();
}
