/// ELM327 ASCII commands sent to the ODB-II adapter.
///
/// All commands are written as `"$cmd\r"` and the device replies end with
/// the prompt character `>`. Init sequence is run once after each connect.
class Elm327Commands {
  Elm327Commands._();

  /// Reset the device. Returns a multi-line banner (e.g. "ELM327 v1.5") then `>`.
  /// We ignore the body and just wait for the prompt.
  static const String reset = 'ATZ';

  /// Echo OFF. After this, the device no longer prefixes responses with the
  /// command we sent — keeps parsing simple.
  static const String echoOff = 'ATE0';

  /// Linefeeds OFF. Responses end with `\r` only (no `\n`).
  static const String linefeedsOff = 'ATL0';

  /// Spaces OFF. Hex bytes are concatenated without separators.
  static const String spacesOff = 'ATS0';

  /// Headers OFF. Strips the protocol header bytes from responses so Mode 03
  /// payloads start directly at the `0x43` service-id byte. Without this,
  /// some adapters prepend ECU/protocol headers that confuse the parser.
  static const String headersOff = 'ATH0';

  /// Auto-detect protocol. Lets the adapter pick whichever ISO/CAN variant
  /// the vehicle uses — works across most modern cars.
  static const String autoProtocol = 'ATSP0';

  /// OBD-II Mode 01 PID 00 — supported-PIDs bitmask. We send this at the end
  /// of init as a "warm-up" so the ELM finishes its protocol search **before**
  /// we hit Mode 03. Reasons:
  ///   - `ATSP0` doesn't actually pick a protocol; it just enables auto-detect.
  ///     The first real OBD-II query triggers the search and waits up to ~5s.
  ///   - Many ECUs ignore Mode 03 from cold but reliably answer Mode 01, so
  ///     `0100` is the canonical warm-up command used by CarScanner / Torque.
  ///   - If the ECU is unreachable, we fail at init time with a clear
  ///     `UNABLE TO CONNECT` instead of `03` later returning "no codes".
  static const String pidsSupported01 = '0100';

  /// OBD-II Mode 03 — read stored Diagnostic Trouble Codes.
  static const String readDtcs = '03';

  /// Init sequence run sequentially after connect. Each command must return
  /// `OK` (except [reset], whose banner is ignored — we just wait for `>`).
  ///
  /// Order is significant:
  ///   1. [reset]            — clear adapter state and emit the boot banner.
  ///   2. [echoOff]          — stop the adapter from echoing our commands back.
  ///   3. [spacesOff]        — drop hex separators so parsing is simpler.
  ///   4. [linefeedsOff]     — `\r`-only line endings.
  ///   5. [headersOff]       — strip protocol headers from response frames.
  ///   6. [autoProtocol]     — let the adapter pick the right OBD protocol.
  ///   7. [pidsSupported01]  — warm-up Mode-01 query that forces ATSP0's
  ///                           protocol search to complete *now*, so the
  ///                           subsequent Mode 03 read doesn't have to.
  static const List<String> initSequence = [
    reset,
    echoOff,
    spacesOff,
    linefeedsOff,
    headersOff,
    autoProtocol,
    pidsSupported01,
  ];
}
