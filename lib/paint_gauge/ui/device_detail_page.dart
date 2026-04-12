import 'dart:async';

import 'package:fahis_inspector/paint_gauge/protocol/models.dart';
import 'package:fahis_inspector/paint_gauge/protocol/packet_parser.dart';
import 'package:fahis_inspector/paint_gauge/services/ble_connection_service.dart';
import 'package:fahis_inspector/paint_gauge/services/gauge_command_service.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:flutter/material.dart';

class DeviceDetailPage extends StatefulWidget {
  final String deviceId;
  const DeviceDetailPage({super.key, required this.deviceId});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  late final BleConnectionService _ble;
  late final GaugeCommandService _commands;
  StreamSubscription<BleConnectionState>? _stateSub;
  StreamSubscription<List<int>>? _dataSub;

  String _status = 'Connecting...';

  final List<String> _debugLog = [];

  late Map<CarPart, PartMeasurement> _partMeasurements;
  CarPart? _recentlyUpdatedPart;
  Timer? _highlightTimer;

  /// Which panel the device is currently measuring (from BD 70 notifications).
  CarPart? _currentDevicePanel;

  /// Parts the user has manually collapsed. All other parts with data are open.
  final Set<CarPart> _userCollapsed = {};

  final _listController = ScrollController();

  // Approximate tile height for scroll-to-panel. Tiles with no measurement
  // are ~56 dp; tiles with measurement are taller (~80 dp). Using 72 as a
  // reasonable middle value — close enough for auto-scroll.
  static const double _tileHeight = 72.0;

  @override
  void initState() {
    super.initState();
    _partMeasurements = {
      for (final part in CarPart.values) part: PartMeasurement(part: part),
    };

    _ble = BleConnectionService();
    _commands = GaugeCommandService(
      writeFrame: _ble.write,
      responses: _ble.notifications,
    );

    _stateSub = _ble.connectionState.listen(_onStateChange);
    _dataSub = _ble.notifications.listen(_onData);

    _ble.connect(widget.deviceId).catchError((e) {
      _addDebugLog('Connection failed: $e');
    });
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _stateSub?.cancel();
    _dataSub?.cancel();
    _listController.dispose();
    _ble.disconnect().then((_) => _ble.dispose());
    super.dispose();
  }

  // ── BLE event handlers ──

  void _onStateChange(BleConnectionState state) {
    if (!mounted) return;
    setState(() {
      _status = switch (state) {
        BleConnectionState.connecting => 'Connecting...',
        BleConnectionState.connected => 'Connected ',
        BleConnectionState.disconnected => 'Disconnected',
        BleConnectionState.lostConnection => 'Connection lost',
        BleConnectionState.error => 'Connection error',
      };
    });
    _addDebugLog('State: ${state.name}');

    if (state == BleConnectionState.lostConnection) {
      _showConnectionLostBanner();
    }
  }

  void _showConnectionLostBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.red.shade700,
        leading: const Icon(
          Icons.bluetooth_disabled,
          color: Colors.white,
          size: 28,
        ),
        content: const Text(
          'Connection lost — Try again',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              Navigator.of(context).pop();
            },
            child: const Text(
              'GO BACK',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _onData(List<int> bytes) {
    if (!mounted) return;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    _addDebugLog('RX ${bytes.length}B: $hex');

    final packet = PacketParser.parse(bytes);
    AppLogger.log(
      'Parsed: $packet'
          '(${packet.runtimeType})',
      'Packet parsed from device data',
    );

    if (packet is MeasurementPacket) {
      _handleMeasurement(packet);
    } else if (packet is CurrentPanelResponse ||
        packet is PartSelectionPacket) {
      final label = _panelLabel(packet);
      _addDebugLog('Panel: $label');
      _updateCurrentPanel(
        packet is CurrentPanelResponse
            ? packet.carPart
            : (packet as PartSelectionPacket).carPart,
      );
    }
  }

  void _updateCurrentPanel(CarPart? part) {
    if (part == null || part == _currentDevicePanel) return;
    setState(() => _currentDevicePanel = part);
    _scrollToPanel(part);
  }

  void _scrollToPanel(CarPart part) {
    final index = CarPart.values.indexOf(part);
    if (index < 0 || !_listController.hasClients) return;
    final target = (index * _tileHeight).clamp(
      0.0,
      _listController.position.maxScrollExtent,
    );
    _listController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onPanelTapped(CarPart part) async {
    if (!_ble.canWrite) return;
    try {
      await _commands.togglePanel(part);
      // Optimistically update — the device will also send a BD 70 confirming it
      _updateCurrentPanel(part);
      _addDebugLog('Switched device to: ${part.label}');
    } catch (e) {
      AppLogger.error('togglePanel failed', e.toString());
    }
  }

  void _handleMeasurement(MeasurementPacket packet) {
    final carPart = packet.carPart;
    if (carPart == null) {
      _addDebugLog('Unknown part ID: 0x${packet.partId.toRadixString(16)}');
      return;
    }

    _addDebugLog(
      '✓ ${carPart.label} = ${packet.measurement.thickness} μm '
      '(${packet.measurement.substrate.label})',
    );

    setState(() {
      _partMeasurements[carPart]!.update(
        packet.measurement.thickness,
        packet.measurement.substrate,
      );
      _recentlyUpdatedPart = carPart;
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _recentlyUpdatedPart = null);
      });
    });
  }

  /// Clears session readings for [panel] locally and on the device.
  Future<void> _onDeletePanel(CarPart panel) async {
    if (!_ble.canWrite) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear ${panel.label}?'),
        content: const Text('This will clear session readings for this panel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _commands.clearPanelData(panel);
      if (!mounted) return;
      setState(() {
        _partMeasurements[panel]!.clear();
        _userCollapsed.remove(
          panel,
        ); // reset so it auto-expands on next reading
      });
      _addDebugLog('Cleared panel: ${panel.label}');
    } catch (e) {
      AppLogger.error('clearPanelData failed for ${panel.label}', e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to clear ${panel.label}')));
    }
  }

  void _addDebugLog(String message) {
    AppLogger.log('$message (see debug log)', 'Debug log updated');
    if (!mounted) return;
    setState(() {
      _debugLog.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} $message',
      );
      if (_debugLog.length > 50) _debugLog.removeLast();
    });
  }

  String _panelLabel(ParsedPacket packet) {
    if (packet is CurrentPanelResponse) {
      return packet.carPart?.label ?? '0x${packet.partId.toRadixString(16)}';
    }
    if (packet is PartSelectionPacket) {
      return packet.carPart?.label ?? '0x${packet.partId.toRadixString(16)}';
    }
    return '?';
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final measuredCount = _partMeasurements.values
        .where((m) => m.hasMeasurement)
        .length;
    final isConnected = _ble.currentState == BleConnectionState.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Gauge Measurements'),
        actions: [
          if (isConnected && _ble.canWrite)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all panels',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all panels?'),
                    content: const Text(
                      'This will remove all session readings from every panel.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'CLEAR ALL',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !mounted) return;
                setState(() {
                  for (final part in CarPart.values) {
                    _partMeasurements[part] = PartMeasurement(part: part);
                  }
                  _userCollapsed.clear();
                  _debugLog.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _StatusCard(
            status: _status,
            measuredCount: measuredCount,
            totalCount: CarPart.values.length,
          ),

          const Divider(height: 1),
          Expanded(child: _buildPartsList()),
        ],
      ),
    );
  }

  Widget _buildPartsList() {
    return ListView.builder(
      controller: _listController,
      itemCount: CarPart.values.length,
      itemBuilder: (context, index) {
        final part = CarPart.values[index];
        final measurement = _partMeasurements[part]!;

        return _PartTile(
          index: index,
          measurement: measurement,
          isRecentlyUpdated: _recentlyUpdatedPart == part,
          isCurrentDevicePanel: _currentDevicePanel == part,
          isExpanded:
              measurement.hasMeasurement && !_userCollapsed.contains(part),
          canWrite: _ble.canWrite,
          onTap: () {
            if (measurement.hasMeasurement) {
              setState(() {
                if (_userCollapsed.contains(part)) {
                  _userCollapsed.remove(part);
                } else {
                  _userCollapsed.add(part);
                }
              });
            }
            _onPanelTapped(part);
          },
          onDelete: measurement.hasMeasurement
              ? () => _onDeletePanel(part)
              : null,
        );
      },
    );
  }
}

// ── Supporting widgets ──

class _StatusCard extends StatelessWidget {
  final String status;
  final int measuredCount;
  final int totalCount;

  const _StatusCard({
    required this.status,
    required this.measuredCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isOk = status.contains('Connected');
    final isError =
        status.contains('error') ||
        status.contains('Error') ||
        status.contains('lost');
    final color = isOk
        ? Colors.green.shade50
        : isError
        ? Colors.red.shade50
        : null;
    final iconData = isOk
        ? Icons.check_circle
        : isError
        ? Icons.error
        : Icons.info;
    final iconColor = isOk
        ? Colors.green
        : isError
        ? Colors.red
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.all(8),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Measured: $measuredCount / $totalCount parts',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _PartTile extends StatelessWidget {
  final int index;
  final PartMeasurement measurement;
  final bool isRecentlyUpdated;
  final bool isCurrentDevicePanel;
  final bool isExpanded;
  final bool canWrite;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PartTile({
    required this.index,
    required this.measurement,
    required this.isRecentlyUpdated,
    required this.isCurrentDevicePanel,
    required this.isExpanded,
    required this.canWrite,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    if (isCurrentDevicePanel) {
      bgColor = Colors.blueGrey.shade50;
    } else if (isRecentlyUpdated) {
      bgColor = Colors.amber.shade100;
    }

    return Container(
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          if (isExpanded && measurement.hasMeasurement) _buildExpandedBody(),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      onTap: canWrite ? onTap : null,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: measurement.hasMeasurement
                ? _thicknessColor(measurement.average!)
                : Colors.grey.shade300,
            child: measurement.hasMeasurement
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text('${index + 1}', style: const TextStyle(fontSize: 12)),
          ),
          if (isCurrentDevicePanel)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              measurement.part.label,
              style: TextStyle(
                fontWeight: measurement.hasMeasurement
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          if (isCurrentDevicePanel) _hereChip(),
        ],
      ),
      subtitle: measurement.hasMeasurement
          ? Text(
              'Average: ${_formatValue(measurement.average)} μm  ·  '
              '${measurement.readings.length}/6 readings',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            )
          : Text(
              canWrite ? 'Tap to move device here' : 'No measurement yet',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: canWrite && isCurrentDevicePanel
                    ? Colors.blue.shade700
                    : Colors.grey.shade600,
              ),
            ),
      trailing: measurement.hasMeasurement
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecentlyUpdated)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.fiber_manual_record,
                      color: Colors.red,
                      size: 10,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Clear readings',
                ),
              ],
            )
          : Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
    );
  }

  Widget _buildExpandedBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (measurement.substrate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Substrate: ${measurement.substrate!.label}',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          Row(children: List.generate(6, _readingBox)),
        ],
      ),
    );
  }

  Widget _readingBox(int i) {
    final readings = measurement.readings;
    final hasValue = i < readings.length;
    final isLatest = hasValue && i == readings.length - 1;
    final value = hasValue ? readings[i] : null;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        height: 40,
        decoration: BoxDecoration(
          color: isLatest
              ? Colors.blue.shade100
              : hasValue
              ? Colors.grey.shade100
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isLatest ? Colors.blue : Colors.grey.shade300,
            width: isLatest ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            value != null ? _formatValue(value) : '—',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
              color: isLatest
                  ? Colors.blue.shade800
                  : hasValue
                  ? Colors.black87
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hereChip() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }

  String _formatValue(double? value) {
    if (value == null) return '—';
    return value.abs() < 99.95
        ? value.toStringAsFixed(1)
        : value.round().toString();
  }

  Color _thicknessColor(double thickness) {
    final abs = thickness.abs();
    if (abs < 50) return Colors.red;
    if (abs < 100) return Colors.orange;
    if (abs < 150) return Colors.green;
    return Colors.blue;
  }
}
