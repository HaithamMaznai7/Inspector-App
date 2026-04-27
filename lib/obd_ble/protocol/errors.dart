/// Exceptions raised by the ELM327 command service. Kept narrow so the
/// controller can map each one to a user-facing snackbar.
sealed class ElmException implements Exception {
  final String message;
  const ElmException(this.message);

  @override
  String toString() => message;
}

/// One of the AT init commands didn't return `OK`. Usually means the device
/// is not actually an ELM327 (or is stuck in a bad state) — disconnect and
/// have the user retry.
class ElmInitException extends ElmException {
  final String command;
  final String response;
  const ElmInitException(this.command, this.response)
      : super('ELM init failed for "$command": "$response"');
}

/// No prompt (`>`) received within the timeout. Either the link is dead or
/// the car ECU isn't responding.
class ElmTimeoutException extends ElmException {
  final Duration timeout;
  const ElmTimeoutException(this.timeout) : super('No response within timeout');
}
