import 'dart:async';

import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/features/inspection_details/controller.dart';
import 'package:fahis_inspector/models/paint_panel.dart';
import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/paint_gauge/protocol/packet_parser.dart';
import 'package:fahis_inspector/paint_gauge/services/ble_connection_service.dart';
import 'package:fahis_inspector/paint_gauge/services/gauge_command_service.dart';
import 'package:fahis_inspector/paint_gauge/ui/device_scan_page.dart';
import 'package:fahis_inspector/resources/paint_gauge_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaintGaugeController extends GetxController {
  static const _tag = 'PaintGaugeController';
  static const _saveDebounceMs = 3000;

  InspectionDetailsController get mainController =>
      InspectionDetailsBinding().instance;
  String? get slug => mainController.slug;

  // ── BLE services ────────────────────────────────────────────────────────────
  BleConnectionService? _connectionService;
  GaugeCommandService? _commandService;
  StreamSubscription<BleConnectionState>? _connectionStateSub;
  StreamSubscription<List<int>>? _dataSub;

  // ── Backend panel values (keyed by backend id = CarPart.backendId) ──────────
  final RxMap<int, PaintPanel> _backendMap = RxMap<int, PaintPanel>({});
  final RxBool isPanelsLoading = true.obs;

  // ── Session measurement state (ephemeral, per-connection) ──────────────────
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

  // ── Dirty tracking & save debounce ─────────────────────────────────────────
  final Set<int> _dirtyPanelIds = {};
  final Set<int> _postingPanelIds = {};
  Timer? _saveDebounceTimer;

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
    await _fetchPanels();
  }

  @override
  void onClose() {
    AppLogger.info(_tag, 'onClose');
    _saveDebounceTimer?.cancel();
    _flushAllDirty();
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

  // ── Backend Panel Fetching (cache-first + API refresh) ─────────────────────

  Future<void> _fetchPanels() async {
    isPanelsLoading.value = true;

    // 1. Show cached immediately
    final cached = _repository?.fetchPanelsFromCache() ?? [];
    if (cached.isNotEmpty) {
      _backendMap.assignAll({for (final row in cached) row.id: row});
      isPanelsLoading.value = false;
      update();
    }

    // 2. Refresh from API
    try {
      final fresh = await _repository!.fetchPanelsFromApi();
      _backendMap.assignAll({for (final row in fresh) row.id: row});
    } on FNetworkException catch (e) {
      if (_backendMap.isEmpty) e.notify();
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch panels', e);
    } finally {
      isPanelsLoading.value = false;
      update();
    }
  }

  // ── BLE Scanning ─────────────────────────────────────────────────────────────

  Future<void> startScan() async {
    if (isScanning.value) return;
    AppLogger.info(_tag, 'startScan');

    discoveredDevices.clear();
    isScanning.value = true;
    update();
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
    await _flushAllDirty();
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

    // Mark dirty
    final bp = backendPanelFor(part);
    if (bp != null) {
      _dirtyPanelIds.add(bp.id);
    } else {
      AppLogger.info(_tag, 'No backend panel for ${part.label} — reading will not be saved');
    }

    // Reset debounce timer
    _resetSaveDebounce(part);

    partMeasurements.refresh();
    update();
  }

  void _updateCurrentPanel(CarPart? part) {
    if (currentDevicePanel.value == part) return;
    currentDevicePanel.value = part;
    AppLogger.info(_tag, 'Device panel changed to: ${part?.label}');
    update();
  }

  // ── Save Strategy ────────────────────────────────────────────────────────────

  void _resetSaveDebounce(CarPart part) {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(
      const Duration(milliseconds: _saveDebounceMs),
      () => _saveIfReady(part),
    );
  }

  Future<void> _saveIfReady(CarPart part) async {
    final m = partMeasurements[part];
    final bp = backendPanelFor(part);
    if (m == null || bp == null) return;
    if (m.readings.length < 2) return;
    if (!_dirtyPanelIds.contains(bp.id)) return;

    await _postPanel(bp, m);
  }

  Future<void> _postPanel(PaintPanel panel, PartMeasurement m) async {
    if (m.readings.length < 2) return;
    if (_postingPanelIds.contains(panel.id)) return;

    _postingPanelIds.add(panel.id);

    try {
      await _repository!.updatePanel(
        panel,
        thickness: m.average!,
        substrate: m.substrate?.label ?? 'Fe',
        measurementCount: m.readings.length,
      );
      _dirtyPanelIds.remove(panel.id);

      // Update reactive map so UI reflects saved state
      final existing = _backendMap[panel.id];
      if (existing != null) {
        existing.thickness = m.average;
        existing.substrate = m.substrate?.label;
        existing.measurementCount = m.readings.length;
        _backendMap.refresh();
      }
    } on FNetworkException catch (e) {
      AppLogger.error(_tag, 'POST failed for panel ${panel.name}', e);
      FLoader.warningSnackBar(
        title: PaintGaugePage.clearFailed.tr,
        message: panel.name,
      );
    } catch (e) {
      AppLogger.error(_tag, 'POST failed for panel ${panel.name}', e);
    } finally {
      _postingPanelIds.remove(panel.id);
    }
  }

  Future<void> _flushAllDirty() async {
    final futures = <Future>[];
    for (final panelId in _dirtyPanelIds.toList()) {
      final bp = _backendMap[panelId];
      if (bp == null) continue;
      final carPart = CarPart.values.firstWhereOrNull(
        (p) => p.backendId == panelId,
      );
      if (carPart == null) continue;
      final m = partMeasurements[carPart];
      if (m == null || m.readings.length < 2) continue;
      futures.add(_postPanel(bp, m));
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  // ── Panel Actions ─────────────────────────────────────────────────────────────

  Future<void> selectPanel(CarPart part) async {
    final previousPart = selectedPanel.value;

    // Before switching: save outgoing dirty panel or warn about incomplete
    if (previousPart != null && previousPart != part) {
      _saveDebounceTimer?.cancel();

      final prevM = partMeasurements[previousPart];
      final prevBp = backendPanelFor(previousPart);

      if (prevM != null && prevBp != null && _dirtyPanelIds.contains(prevBp.id)) {
        if (prevM.readings.length >= 2) {
          _postPanel(prevBp, prevM); // fire-and-forget
        } else if (prevM.readings.length == 1) {
          FLoader.infoSnackBar(
            title: PaintGaugePage.noMeasurementYet.tr,
            message: PaintGaugePage.sessionReadingsOnly.tr,
          );
        }
      }
    }

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

    // Clear backend state
    final bp = backendPanelFor(part);
    if (bp != null) {
      _dirtyPanelIds.remove(bp.id);
      try {
        await _repository!.updatePanel(
          bp,
          thickness: 0,
          substrate: '',
          measurementCount: 0,
        );
        bp.thickness = null;
        bp.substrate = null;
        bp.measurementCount = 0;
        _backendMap.refresh();
      } catch (e) {
        AppLogger.error(_tag, 'Failed to clear panel on backend', e);
      }
    }

    partMeasurements.refresh();
    update();
  }

  Future<void> clearAllPanels() async {
    AppLogger.info(_tag, 'clearAllPanels');
    for (final part in CarPart.values) {
      partMeasurements[part]?.clear();
    }
    _dirtyPanelIds.clear();
    partMeasurements.refresh();
    update();
  }

  void resetMeasurements() {
    _dirtyPanelIds.clear();
    _postingPanelIds.clear();
    _saveDebounceTimer?.cancel();
    _initPartMeasurements();
    _repository?.clearCache();
    _fetchPanels();
  }

  // ── Display Helpers (merge backend + session state) ──────────────────────────

  /// Find the backend panel matching a [CarPart] by backend ID.
  PaintPanel? backendPanelFor(CarPart part) {
    return _backendMap[part.backendId];
  }

  /// Display thickness: session average if session has readings, else backend.
  double? displayThickness(CarPart part) {
    final m = partMeasurements[part];
    if (m != null && m.hasMeasurement) return m.average;
    return backendPanelFor(part)?.thickness;
  }

  /// Display substrate: session if available, else backend.
  String? displaySubstrate(CarPart part) {
    final m = partMeasurements[part];
    if (m != null && m.substrate != null) return m.substrate!.label;
    return backendPanelFor(part)?.substrate;
  }

  /// Display reading count: session if measuring, else backend.
  int displayMeasurementCount(CarPart part) {
    final m = partMeasurements[part];
    if (m != null && m.hasMeasurement) return m.readings.length;
    return backendPanelFor(part)?.measurementCount ?? 0;
  }

  /// Whether this panel has backend data (previously saved).
  bool panelHasBackendData(CarPart part) {
    final bp = backendPanelFor(part);
    return bp != null && bp.thickness != null;
  }

  /// Whether this panel has unsaved session changes.
  bool panelIsDirty(CarPart part) {
    return _dirtyPanelIds.contains(part.backendId);
  }

  // ── Existing Helpers ─────────────────────────────────────────────────────────

  /// Number of panels that have data (session or backend).
  int get measuredPanelCount {
    int count = 0;
    for (final part in CarPart.values) {
      final m = partMeasurements[part];
      if (m != null && m.hasMeasurement) {
        count++;
        continue;
      }
      if (panelHasBackendData(part)) count++;
    }
    return count;
  }

  /// Whether backend data has been loaded.
  bool get isPanelsEmpty => _backendMap.isEmpty;

  /// Total number of panels (always matches CarPart enum).
  int get totalPanelCount => CarPart.values.length;

  bool panelIsSelected(CarPart part) => selectedPanel.value == part;

  bool panelIsActiveOnDevice(CarPart part) => currentDevicePanel.value == part;
}
