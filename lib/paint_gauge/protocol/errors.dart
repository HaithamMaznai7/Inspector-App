/// Base class for all gauge protocol errors.
sealed class GaugeProtocolException implements Exception {
  final String message;
  const GaugeProtocolException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Device replied with NAK (0x00 0x95) — bad packet format.
class DeviceNakException extends GaugeProtocolException {
  const DeviceNakException() : super('Device rejected packet (NAK)');
}

/// Device replied with Cancel (0x00 0x98) — unsupported command.
class DeviceCancelException extends GaugeProtocolException {
  const DeviceCancelException()
      : super('Command not supported by device (Cancel)');
}

/// No response received within the expected timeout.
class CommandTimeoutException extends GaugeProtocolException {
  final Duration timeout;
  const CommandTimeoutException(this.timeout)
      : super('No response within timeout');

  @override
  String toString() =>
      'CommandTimeoutException: No response within ${timeout.inMilliseconds}ms';
}

/// Device returned an unexpected response type for the command sent.
class UnexpectedResponseException extends GaugeProtocolException {
  const UnexpectedResponseException(super.message);
}

/// Received packet CRC does not match computed CRC.
class CrcMismatchException extends GaugeProtocolException {
  final int expected;
  final int actual;
  const CrcMismatchException({required this.expected, required this.actual})
      : super('CRC mismatch');

  @override
  String toString() =>
      'CrcMismatchException: expected 0x${expected.toRadixString(16)}, '
      'got 0x${actual.toRadixString(16)}';
}
