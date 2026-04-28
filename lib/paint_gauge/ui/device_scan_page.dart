import 'dart:async';
import 'dart:io';

import 'package:fahis_inspector/paint_gauge/ui/device_detail_page.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple data model for a discovered BLE device.
class BleDevice {
  final String mac;
  final String name;
  final int rssi;
  const BleDevice({required this.mac, required this.name, required this.rssi});
}

class DeviceScanPage extends StatefulWidget {
  const DeviceScanPage({super.key});

  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage> {
  final Map<String, BleDevice> _seen = {};
  bool _isScanning = false;
  StreamSubscription? _scanSub;

  @override
  void dispose() {
    _scanSub?.cancel();
    if (_isScanning) FlutterBluePlus.stopScan();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool _hasName(BleDevice d) => d.name != d.mac;

  // ── BLE actions ──────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    // iOS: BLE permissions are granted via Info.plist and requested automatically
    // by CoreBluetooth when scanning starts — no runtime request needed.
    if (!Platform.isAndroid) return;

    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return;
    }
    // Android < 12 fallback
    if (await Permission.location.request().isGranted) return;
    _showSnackBar('Bluetooth permissions required', Colors.red);
  }

  Future<void> _startScan() async {
    await _requestPermissions();

    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      _showSnackBar('Bluetooth not supported on this device', Colors.red);
      return;
    }
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _showSnackBar('Please enable Bluetooth', Colors.orange);
      return;
    }

    setState(() {
      _isScanning = true;
      _seen.clear();
    });

    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();

    // Subscribe BEFORE startScan to avoid race condition
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      bool changed = false;
      for (final r in results) {
        final d = r.device;
        final adv = r.advertisementData;
        final name = d.platformName.isNotEmpty
            ? d.platformName
            : adv.advName.isNotEmpty
            ? adv.advName
            : d.remoteId.str;
        _seen[d.remoteId.str] = BleDevice(
          mac: d.remoteId.str,
          name: name,
          rssi: r.rssi,
        );
        changed = true;
      }
      if (changed && mounted) setState(() {});
    });

    // No timeout — scan runs until _stopScan() is called
    FlutterBluePlus.startScan();
  }

  Future<void> _stopScan() async {
    _scanSub?.cancel();
    _scanSub = null;
    await FlutterBluePlus.stopScan();
    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _connectToDevice(BleDevice device) async {
    if (_isScanning) await _stopScan();
    if (!mounted) return;
    // DeviceDetailPage owns the full BLE lifecycle (connect → subscribe → disconnect)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeviceDetailPage(deviceId: device.mac)),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final named = _seen.values.where(_hasName).toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Gauge Devices'),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(FSizes.md),
              child: SizedBox(
                width: FSizes.iconInlineSm,
                height: FSizes.iconInlineSm,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(named),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? _stopScan : _startScan,
        icon: Icon(_isScanning ? Icons.stop : Icons.search),
        label: Text(_isScanning ? 'Stop Scan' : 'Scan Devices'),
      ),
    );
  }

  Widget _buildBody(List<BleDevice> named) {
    if (!_isScanning && _seen.isEmpty) {
      return const _EmptyState(
        icon: Icons.bluetooth_searching,
        title: 'No devices found',
        subtitle: 'Tap "Scan Devices" to start',
      );
    }
    if (_isScanning && _seen.isEmpty) {
      return const _EmptyState(
        icon: Icons.radar,
        title: 'Scanning...',
        subtitle: 'Looking for nearby Bluetooth devices',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: FSizes.imageThumbSize),
      children: [
        if (named.isNotEmpty) ...[
          _SectionHeader(label: 'Named Devices', count: named.length),
          ...named.map(
            (d) => _DeviceTile(device: d, onTap: () => _connectToDevice(d)),
          ),
        ],
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FSizes.md,
        FSizes.borderRadiusLg,
        FSizes.md,
        FSizes.xs,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.sm,
              vertical: FSizes.xxs,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: FSizes.fontSizeXs,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BleDevice device;
  final VoidCallback onTap;
  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNamed = device.name != device.mac;
    return ListTile(
      leading: Icon(
        Icons.bluetooth,
        color: isNamed ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      title: Text(
        isNamed ? device.name : 'Unknown Device',
        style: TextStyle(
          fontWeight: isNamed ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        device.mac,
        style: const TextStyle(fontSize: FSizes.fontSizeXs),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SignalBars(rssi: device.rssi),
          const SizedBox(width: FSizes.sm),
          Text(
            '${device.rssi} dBm',
            style: const TextStyle(
              fontSize: FSizes.fontSizeXs,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int rssi;
  const _SignalBars({required this.rssi});

  @override
  Widget build(BuildContext context) {
    final bars = rssi >= -60
        ? 4
        : rssi >= -70
        ? 3
        : rssi >= -80
        ? 2
        : 1;
    final color = rssi >= -60
        ? Colors.green
        : rssi >= -70
        ? Colors.lightGreen
        : rssi >= -80
        ? Colors.orange
        : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        4,
        (i) => Container(
          width: FSizes.xs,
          height: FSizes.xs + (i * FSizes.xs),
          margin: const EdgeInsets.symmetric(horizontal: FSizes.dividerHeight),
          decoration: BoxDecoration(
            color: i < bars ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(FSizes.dividerHeight),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: FSizes.iconXl, color: Colors.grey.shade400),
          const SizedBox(height: FSizes.md),
          Text(
            title,
            style: TextStyle(
              fontSize: FSizes.fontSizeMd,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: FSizes.fontSizeSm,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
