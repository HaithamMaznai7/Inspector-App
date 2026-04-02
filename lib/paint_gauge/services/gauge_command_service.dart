import 'dart:async';

import 'package:fahis_inspector/util/helpers/logger.dart';

import '../protocol/errors.dart';
import '../protocol/models.dart';
import '../protocol/packet_builder.dart';
import '../protocol/packet_parser.dart';

/// Orchestrates all Section 4 commands to the Guoou thickness gauge.
///
/// Uses constructor injection — no direct BLE dependency.
/// Commands are executed sequentially (one at a time) with an async lock.
class GaugeCommandService {
  final Future<void> Function(List<int> data) _writeFrame;
  final Stream<List<int>> _responses;

  /// Timeout for waiting on a device response.
  final Duration responseTimeout;

  /// Delay between BLE frames (protocol requires 125ms).
  static const _interFrameDelay = Duration(milliseconds: 125);

  final _lock = _AsyncLock();

  GaugeCommandService({
    required Future<void> Function(List<int> data) writeFrame,
    required Stream<List<int>> responses,
    this.responseTimeout = const Duration(seconds: 3),
  }) : _writeFrame = writeFrame,
       _responses = responses;

  // ── CarHandy queries ──

  /// 4.1: Query alarm switch status. Returns true if ON.
  Future<bool> queryAlarmSwitch() async {
    final response = await _sendAndWait(PacketBuilder.queryAlarmSwitch());
    if (response is AlarmSwitchResponse) return response.enabled;
    throw _unexpectedResponse(response);
  }

  /// 4.2: Query upper limit alarm value.
  Future<int> queryUpperAlarm() async {
    final response = await _sendAndWait(PacketBuilder.queryUpperAlarm());
    if (response is AlarmValueResponse) return response.value;
    throw _unexpectedResponse(response);
  }

  /// 4.3: Query lower limit alarm value.
  Future<int> queryLowerAlarm() async {
    final response = await _sendAndWait(PacketBuilder.queryLowerAlarm());
    if (response is AlarmValueResponse) return response.value;
    throw _unexpectedResponse(response);
  }

  /// 4.4: Query serious upper limit alarm value.
  Future<int> querySeriousUpperAlarm() async {
    final response = await _sendAndWait(PacketBuilder.querySeriousUpperAlarm());
    if (response is AlarmValueResponse) return response.value;
    throw _unexpectedResponse(response);
  }

  /// 4.5: Query serious lower limit alarm value.
  Future<int> querySeriousLowerAlarm() async {
    final response = await _sendAndWait(PacketBuilder.querySeriousLowerAlarm());
    if (response is AlarmValueResponse) return response.value;
    throw _unexpectedResponse(response);
  }

  /// 4.7: Get stored measurements from [firstIndex], up to [count] items.
  /// Max 10 per request. Use [getAllData] for automatic pagination.
  Future<DataRangeResponse> getDataRange(int firstIndex, int count) async {
    assert(count >= 1 && count <= 20);
    final response = await _sendAndWait(
      PacketBuilder.getDataRange(firstIndex, count),
    );
    if (response is DataRangeResponse) return response;
    throw _unexpectedResponse(response);
  }

  /// Fetches all stored measurements by paginating through the data set.
  Future<List<DeviceMeasurement>> getAllData() async {
    final totalCount = await queryDataCount();
    if (totalCount == 0) return [];

    final all = <DeviceMeasurement>[];
    var index = 1;
    while (index <= totalCount) {
      final batchSize = (totalCount - index + 1).clamp(1, 10);
      final response = await getDataRange(index, batchSize);
      all.addAll(response.measurements);
      index += batchSize;
    }
    return all;
  }

  /// 4.8: Query data count in the data set.
  Future<int> queryDataCount() async {
    final response = await _sendAndWait(PacketBuilder.queryDataCount());
    if (response is DataCountResponse) return response.count;
    throw _unexpectedResponse(response);
  }

  // ── CarHandy setters ──

  /// 4.9: Set alarm switch ON/OFF.
  Future<void> setAlarmSwitch(bool enabled) async {
    final response = await _sendAndWait(PacketBuilder.setAlarmSwitch(enabled));
    _checkAckOrEcho(response);
  }

  /// 4.10: Set upper limit alarm value.
  Future<void> setUpperAlarm(int value) async {
    final response = await _sendAndWait(PacketBuilder.setUpperAlarm(value));
    _checkAckOrEcho(response);
  }

  /// 4.11: Set lower limit alarm value.
  Future<void> setLowerAlarm(int value) async {
    final response = await _sendAndWait(PacketBuilder.setLowerAlarm(value));
    _checkAckOrEcho(response);
  }

  /// 4.12: Set serious upper limit alarm value.
  Future<void> setSeriousUpperAlarm(int value) async {
    final response = await _sendAndWait(
      PacketBuilder.setSeriousUpperAlarm(value),
    );
    _checkAckOrEcho(response);
  }

  /// 4.13: Set serious lower limit alarm value.
  Future<void> setSeriousLowerAlarm(int value) async {
    final response = await _sendAndWait(
      PacketBuilder.setSeriousLowerAlarm(value),
    );
    _checkAckOrEcho(response);
  }

  /// 4.14: Delete [count] data items from the group.
  /// Returns actual number deleted (may be less if fewer exist).
  Future<int> deleteData(int count) async {
    final response = await _sendAndWait(PacketBuilder.deleteData(count));
    if (response is DeleteDataResponse) return response.deletedCount;
    throw _unexpectedResponse(response);
  }

  // ── Mode commands ──

  /// 4.17: Query current measurement mode.
  Future<MeasurementMode> queryMode() async {
    final response = await _sendAndWait(PacketBuilder.queryMode());
    if (response is ModeResponse && response.mode != null) {
      return response.mode!;
    }
    throw _unexpectedResponse(response);
  }

  /// 4.18: Set measurement mode.
  Future<void> setMode(MeasurementMode mode) async {
    final response = await _sendAndWait(PacketBuilder.setMode(mode));
    _checkAckOrEcho(response);
  }

  // ── CarPro commands ──

  /// 4.19: Clear data of a vehicle panel.
  Future<void> clearPanelData(CarPart panel) async {
    // Device responds with ClearPanelResponse (BD 64 echo), not a generic ACK.
    final response = await _sendAndWait(
      PacketBuilder.clearPanelData(panel),
      isResponse: (p) =>
          p is ClearPanelResponse ||
          p is AckPacket ||
          p is NakPacket ||
          p is CancelPacket,
    );
    if (response is NakPacket) throw const DeviceNakException();
    if (response is CancelPacket) throw const DeviceCancelException();
    // ClearPanelResponse or AckPacket both indicate success.
  }

  /// 4.20: Get vehicle panel data (up to 6 measurements per panel).
  Future<PanelDataResponse> getPanelData(CarPart panel) async {
    final response = await _sendAndWait(PacketBuilder.getPanelData(panel));
    if (response is PanelDataResponse) return response;
    throw _unexpectedResponse(response);
  }

  /// 4.21: Query current panel number.
  Future<CarPart?> queryCurrentPanel() async {
    // Override filter: this command specifically expects CurrentPanelResponse.
    final response = await _sendAndWait(
      PacketBuilder.queryCurrentPanel(),
      isResponse: (p) =>
          p is CurrentPanelResponse || p is NakPacket || p is CancelPacket,
    );
    if (response is CurrentPanelResponse) return response.carPart;
    throw _unexpectedResponse(response);
  }

  /// 4.22: Toggle current panel to [panel].
  Future<void> togglePanel(CarPart panel) async {
    final response = await _sendAndWait(PacketBuilder.togglePanel(panel));
    _checkAckOrEcho(response);
  }

  /// 4.23: Toggle car data group.
  Future<void> toggleCarDataGroup(int groupNumber, {bool clear = false}) async {
    final response = await _sendAndWait(
      PacketBuilder.toggleCarDataGroup(groupNumber, clear: clear),
    );
    _checkAckOrEcho(response);
  }

  /// 4.24: Delete all panels data for a vehicle (1–999).
  Future<void> deleteAllPanelsData(int vehicleNumber) async {
    final response = await _sendAndWait(
      PacketBuilder.deleteAllPanelsData(vehicleNumber),
    );
    _checkAckOrEcho(response);
  }

  /// Fetches all alarm settings in a single batch.
  Future<AlarmSettings> queryAlarmSettings() async {
    final enabled = await queryAlarmSwitch();
    final upper = await queryUpperAlarm();
    final lower = await queryLowerAlarm();
    final seriousUpper = await querySeriousUpperAlarm();
    final seriousLower = await querySeriousLowerAlarm();

    return AlarmSettings(
      enabled: enabled,
      upperLimit: upper,
      lowerLimit: lower,
      seriousUpperLimit: seriousUpper,
      seriousLowerLimit: seriousLower,
    );
  }

  // ── Internal ──

  /// Sends a packet (splitting into frames) and waits for a typed response.
  ///
  /// [isResponse] overrides which packets are treated as the command response.
  /// By default, unsolicited packet types (measurements, panel change notifications)
  /// are skipped so they don't race with real command responses.
  Future<ParsedPacket> _sendAndWait(
    List<int> packet, {
    bool Function(ParsedPacket)? isResponse,
  }) async {
    return _lock.run(() async {
      final frames = PacketBuilder.splitFrames(packet);

      // Set up response listener BEFORE writing
      final completer = Completer<ParsedPacket>();
      late StreamSubscription<List<int>> sub;

      sub = _responses.listen((bytes) {
        if (bytes.isEmpty) return;
        final parsed = PacketParser.parse(bytes);

        final accepted = isResponse != null
            ? isResponse(parsed)
            : _isCommandResponse(parsed);

        if (accepted && !completer.isCompleted) {
          completer.complete(parsed);
          sub.cancel();
        }
      });

      // Write frames with inter-frame delay
      for (var i = 0; i < frames.length; i++) {
        if (i > 0) await Future.delayed(_interFrameDelay);
        await _writeFrame(frames[i]);
        AppLogger.log(
          'Wrote frame ${i + 1}/${frames.length}: '
              '${frames[i].map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
          'Frame written',
        );
      }

      // Wait for response with timeout
      try {
        return await completer.future.timeout(responseTimeout);
      } on TimeoutException {
        sub.cancel();
        throw CommandTimeoutException(responseTimeout);
      }
    });
  }

  /// Default filter for [_sendAndWait].
  ///
  /// Returns true for packets that are direct command responses.
  /// Skips unsolicited broadcasts that can arrive at any time:
  /// - [MeasurementPacket] — live readings from the probe
  /// - [CurrentPanelResponse] / [PartSelectionPacket] — BD 70 panel-change notifications
  /// - [UnknownPacket] — unparseable frames
  bool _isCommandResponse(ParsedPacket p) {
    return p is! UnknownPacket &&
        p is! MeasurementPacket &&
        p is! CurrentPanelResponse &&
        p is! PartSelectionPacket;
  }

  void _checkAckOrEcho(ParsedPacket response) {
    if (response is NakPacket) throw const DeviceNakException();
    if (response is CancelPacket) throw const DeviceCancelException();
    // ACK or echo-back — both indicate success
  }

  GaugeProtocolException _unexpectedResponse(ParsedPacket response) {
    if (response is NakPacket) return const DeviceNakException();
    if (response is CancelPacket) return const DeviceCancelException();
    return UnexpectedResponseException('Unexpected response: $response');
  }
}

/// Simple async lock to ensure one command at a time.
class _AsyncLock {
  Future<void>? _pending;

  Future<T> run<T>(Future<T> Function() action) async {
    // Wait for any pending operation
    while (_pending != null) {
      try {
        await _pending;
      } catch (_) {
        // Ignore errors from previous operations
      }
    }

    final completer = Completer<void>();
    _pending = completer.future;

    try {
      final result = await action();
      return result;
    } finally {
      _pending = null;
      completer.complete();
    }
  }
}
