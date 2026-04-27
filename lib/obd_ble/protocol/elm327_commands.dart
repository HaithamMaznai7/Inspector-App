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

  /// Auto-detect protocol. Lets the adapter pick whichever ISO/CAN variant
  /// the vehicle uses — works across most modern cars.
  static const String autoProtocol = 'ATSP0';

  /// OBD-II Mode 03 — read stored Diagnostic Trouble Codes.
  static const String readDtcs = '03';

  /// Init sequence run sequentially after connect. Each command must return
  /// `OK` (except [reset], whose banner is ignored — we just wait for `>`).
  static const List<String> initSequence = [
    reset,
    echoOff,
    linefeedsOff,
    spacesOff,
    autoProtocol,
  ];
}
