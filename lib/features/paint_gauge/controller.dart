import 'dart:async';

import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/paint_gauge_reading.dart';
import 'package:fahis_inspector/models/paint_gauge_result.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/paint_gauge/protocol/packet_parser.dart';
import 'package:fahis_inspector/paint_gauge/services/ble_connection_service.dart';
import 'package:fahis_inspector/paint_gauge/services/gauge_command_service.dart';
import 'package:fahis_inspector/paint_gauge/ui/device_scan_page.dart';
import 'package:fahis_inspector/resources/paint_gauge_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaintGaugeController extends GetxController {
  static const _tag = 'PaintGaugeController';

  InspectionDetailsController get mainController =>
      InspectionDetailsBinding().instance;
  String? get slug => mainController.slug;

  // ── BLE services ────────────────────────────────────────────────────────────
  BleConnectionService? _connectionService;
  GaugeCommandService? _commandService;
  StreamSubscription<BleConnectionState>? _connectionStateSub;
  StreamSubscription<List<int>>? _dataSub;

  // ── State ────────────────────────────────────────────────────────────────────
  final RxMap<CarPart, PartMeasurement> partMeasurements =
      RxMap<CarPart, PartMeasurement>({});

  final Rxn<CarPart> selectedPanel = Rxn<CarPart>();
  final Rxn<CarPart> currentDevicePanel = Rxn<CarPart>();
  final Rxn<CarPart> recentlyUpdatedPart = Rxn<CarPart>();

  final Rx<BleConnectionState> connectionState =
      Rx<BleConnectionState>(BleConnectionState.disconnected);

  final RxBool isScanning = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;

  final RxList<BleDevice> discoveredDevices = RxList<BleDevice>([]);

  // Connected device info (for traceability)
  String? _deviceName;
  String? _deviceMac;

  // Session timing
  DateTime? _sessionStartedAt;

  // Hive persistence
  Box? _box;
  PaintGaugeRepository? _repository;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    AppLogger.info(_tag, 'onInit');
    _initPartMeasurements();
  }

  @override
  void onReady() async {
    super.onReady();
    AppLogger.info(_tag, 'onReady');

    await _openHiveBox();
    _loadFromCache();
  }

  @override
  void onClose() {
    AppLogger.info(_tag, 'onClose');
    _sessionStartedAt = null;
    _disconnect();
    _connectionStateSub?.cancel();
    _dataSub?.cancel();
    super.onClose();
  }

  // ── Initialization ───────────────────────────────────────────────────────────

  void _initPartMeasurements() {
    final map = <CarPart, PartMeasurement>{};
    for (final part in CarPart.values) {
      map[part] = PartMeasurement(part: part);
    }
    partMeasurements.assignAll(map);
    AppLogger.info(_tag, 'Initialized ${map.length} part measurements');
  }

  Future<void> _openHiveBox() async {
    try {
      _box = await Hive.openBox(PaintGaugeRepository.boxKey);
      final currentSlug = slug;
      if (currentSlug != null && _box != null) {
        _repository = PaintGaugeRepository(box: _box!, slug: currentSlug);
        AppLogger.info(_tag, 'Hive box opened, slug=$currentSlug');
      }
    } catch (e) {
      AppLogger.error(_tag, 'Failed to open Hive box', e);
    }
  }

  void _loadFromCache() {
    final result = _repository?.fetchFromCache();
    if (result == null) return;

    AppLogger.info(_tag, 'Loaded cached result: ${result.totalPanelsMeasured} panels measured');

    for (final entry in result.panels.entries) {
      final part = CarPart.values.firstWhereOrNull(
        (p) => '0x${p.value.toRadixString(16).toUpperCase()}' == entry.key ||
               entry.key == '0x${p.value.toRadixString(16)}',
      );
      if (part == null) continue;

      final reading = entry.value;
      final measurement = partMeasurements[part];
      if (measurement == null) continue;

      measurement.readings.clear();
      measurement.readings.addAll(reading.readings);
      if (reading.substrate.isNotEmpty) {
        measurement.substrate = SubstrateType.values.firstWhereOrNull(
          (s) => s.label == reading.substrate,
        );
      }
      measurement.measurementCount = reading.measurementCount;
    }

    partMeasurements.refresh();
    update();
  }

  // ── BLE Scanning ─────────────────────────────────────────────────────────────

  Future<void> startScan() async {
    if (isScanning.value) return;
    AppLogger.info(_tag, 'startScan');

    discoveredDevices.clear();
    isScanning.value = true;
    update();

    // Scanning is managed by the scan_view (DeviceScanPage logic) —
    // this controller exposes state that scan_view reacts to.
  }

  void stopScan() {
    if (!isScanning.value) return;
    AppLogger.info(_tag, 'stopScan');
    isScanning.value = false;
    update();
  }

  void addDiscoveredDevice(BleDevice device) {
    final idx = discoveredDevices.indexWhere((d) => d.mac == device.mac);
    if (idx >= 0) {
      discoveredDevices[idx] = device;
    } else {
      discoveredDevices.add(device);
    }
  }

  // ── BLE Connection ───────────────────────────────────────────────────────────

  Future<void> connectToDevice(String deviceId, {String? deviceName}) async {
    if (isConnecting.value || isConnected.value) return;
    AppLogger.info(_tag, 'connectToDevice: $deviceId');

    isConnecting.value = true;
    connectionState.value = BleConnectionState.connecting;
    update();

    _connectionService = BleConnectionService();
    _commandService = GaugeCommandService(
      writeFrame: _connectionService!.write,
      responses: _connectionService!.notifications,
    );

    _connectionStateSub?.cancel();
    _connectionStateSub = _connectionService!.connectionState.listen(_onConnectionStateChanged);

    _dataSub?.cancel();
    _dataSub = _connectionService!.notifications.listen(_onData);

    _deviceMac = deviceId;
    _deviceName = deviceName;
    _sessionStartedAt ??= DateTime.now();

    try {
      await _connectionService!.connect(deviceId);
    } catch (e) {
      AppLogger.error(_tag, 'Connection failed', e);
      isConnecting.value = false;
      connectionState.value = BleConnectionState.error;
      update();
    }
  }

  void _onConnectionStateChanged(BleConnectionState state) {
    AppLogger.info(_tag, 'BLE state changed: $state');
    connectionState.value = state;

    switch (state) {
      case BleConnectionState.connected:
        isConnected.value = true;
        isConnecting.value = false;
        // Default to Hood on first connection so device and UI are in sync
        selectPanel(CarPart.frontHatch);
        break;
      case BleConnectionState.disconnected:
      case BleConnectionState.error:
        isConnected.value = false;
        isConnecting.value = false;
        break;
      case BleConnectionState.lostConnection:
        isConnected.value = false;
        isConnecting.value = false;
        break;
      case BleConnectionState.connecting:
        isConnecting.value = true;
        break;
    }

    update();
  }

  Future<void> disconnect() async {
    AppLogger.info(_tag, 'disconnect called');
    _persistCurrentState();
    await _disconnect();
  }

  Future<void> _disconnect() async {
    _dataSub?.cancel();
    _dataSub = null;
    _connectionStateSub?.cancel();
    _connectionStateSub = null;

    await _connectionService?.disconnect();
    _connectionService?.dispose();
    _connectionService = null;
    _commandService = null;

    isConnected.value = false;
    isConnecting.value = false;
    connectionState.value = BleConnectionState.disconnected;
    update();
  }

  // ── Packet Handling ──────────────────────────────────────────────────────────

  void _onData(List<int> bytes) {
    if (bytes.isEmpty) return;
    final packet = PacketParser.parse(bytes);

    if (packet is MeasurementPacket) {
      _handleMeasurement(packet);
    } else if (packet is PartSelectionPacket) {
      _updateCurrentPanel(packet.carPart);
    } else if (packet is CurrentPanelResponse) {
      _updateCurrentPanel(packet.carPart);
    }
  }

  void _handleMeasurement(MeasurementPacket packet) {
    final part = packet.carPart;
    if (part == null) {
      AppLogger.info(_tag, 'Received measurement for unknown part id: 0x${packet.partId.toRadixString(16)}');
      return;
    }

    final measurement = partMeasurements[part];
    if (measurement == null) return;

    measurement.update(packet.measurement.thickness, packet.measurement.substrate);
    AppLogger.info(_tag, 'Measurement for ${part.label}: ${packet.measurement.thickness} μm (${packet.measurement.substrate.label})');

    recentlyUpdatedPart.value = null; // force trigger
    recentlyUpdatedPart.value = part;

    partMeasurements.refresh();
    update();

    _persistCurrentState();
  }

  void _updateCurrentPanel(CarPart? part) {
    if (currentDevicePanel.value == part) return;
    currentDevicePanel.value = part;
    AppLogger.info(_tag, 'Device panel changed to: ${part?.label}');
    update();
  }

  // ── Panel Actions ─────────────────────────────────────────────────────────────

  Future<void> selectPanel(CarPart part) async {
    selectedPanel.value = part;
    update();

    if (_commandService == null || !isConnected.value) return;

    try {
      await _commandService!.togglePanel(part);
      AppLogger.info(_tag, 'Toggled panel to: ${part.label}');
    } catch (e) {
      AppLogger.error(_tag, 'togglePanel failed', e);
    }
  }

  Future<void> clearPanel(CarPart part) async {
    AppLogger.info(_tag, 'clearPanel: ${part.label}');

    if (_commandService != null && isConnected.value) {
      try {
        await _commandService!.clearPanelData(part);
      } catch (e) {
        AppLogger.error(_tag, 'clearPanelData failed', e);
      }
    }

    partMeasurements[part]?.clear();
    partMeasurements.refresh();
    update();

    _persistCurrentState();
  }

  Future<void> clearAllPanels() async {
    AppLogger.info(_tag, 'clearAllPanels');
    for (final part in CarPart.values) {
      partMeasurements[part]?.clear();
    }
    partMeasurements.refresh();
    update();

    _persistCurrentState();
  }

  void resetMeasurements() {
    _initPartMeasurements();
    _persistCurrentState();
  }

  // ── Persistence ───────────────────────────────────────────────────────────────

  void _persistCurrentState() {
    final repo = _repository;
    final currentSlug = slug;
    if (repo == null || currentSlug == null) return;

    try {
      final panelsMap = <String, PaintGaugeReading>{};
      for (final entry in partMeasurements.entries) {
        final part = entry.key;
        final m = entry.value;
        if (m.readings.isEmpty) continue;

        final panelCode = '0x${part.value.toRadixString(16).toUpperCase()}';
        panelsMap[panelCode] = PaintGaugeReading.fromMeasurements(
          panelName: part.label,
          panelCode: panelCode,
          substrate: m.substrate?.label ?? '',
          readings: List<double>.from(m.readings),
        );
      }

      final result = PaintGaugeResult.fromReadings(
        inspectionSlug: currentSlug,
        panels: panelsMap,
        sessionStartedAt: _sessionStartedAt ?? DateTime.now(),
        deviceName: _deviceName,
        deviceMac: _deviceMac,
      );

      repo.saveToCache(result);
    } catch (e) {
      AppLogger.error(_tag, 'Failed to persist paint gauge state', e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  /// Number of panels that have at least one reading.
  int get measuredPanelCount =>
      partMeasurements.values.where((m) => m.hasMeasurement).length;

  /// Total number of panels (always 19).
  int get totalPanelCount => CarPart.values.length;

  /// Whether the panel has no readings (neutral state).
  bool panelIsEmpty(CarPart part) =>
      !(partMeasurements[part]?.hasMeasurement ?? false);

  /// Whether the panel has 1–5 readings (partial).
  bool panelIsPartial(CarPart part) {
    final count = partMeasurements[part]?.readings.length ?? 0;
    return count >= 1 && count < 6;
  }

  /// Whether the panel has all 6 readings (complete).
  bool panelIsComplete(CarPart part) =>
      (partMeasurements[part]?.readings.length ?? 0) >= 6;

  /// Whether this panel is currently selected by the user.
  bool panelIsSelected(CarPart part) => selectedPanel.value == part;

  /// Whether this panel is the device's active measurement panel.
  bool panelIsActiveOnDevice(CarPart part) => currentDevicePanel.value == part;
}
