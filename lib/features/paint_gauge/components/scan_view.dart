import 'dart:async';
import 'dart:io';

import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/paint_gauge/ui/device_scan_page.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';

class PaintGaugeScanView extends StatefulWidget {
  const PaintGaugeScanView({super.key});

  @override
  State<PaintGaugeScanView> createState() => _PaintGaugeScanViewState();
}

class _PaintGaugeScanViewState extends State<PaintGaugeScanView> {
  final Map<String, BleDevice> _seen = {};
  bool _isScanning = false;
  StreamSubscription? _scanSub;

  PaintGaugeController get _controller =>
      Get.find<PaintGaugeController>(tag: 'PaintGauge');

  @override
  void initState() {
    super.initState();
    // Auto-start scanning when bottom sheet opens
    Future.microtask(() => _startScan());
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    if (_isScanning) FlutterBluePlus.stopScan();
    super.dispose();
  }

  bool _hasName(BleDevice d) => d.name != d.mac;

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;

    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return;
    }
    if (await Permission.location.request().isGranted) return;
    _showError(PaintGaugePage.btPermissionRequired.tr);
  }

  Future<void> _startScan() async {
    await _requestPermissions();

    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      _showError(PaintGaugePage.btNotSupported.tr);
      return;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _showError(PaintGaugePage.btNotEnabled.tr);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _seen.clear();
    });

    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();

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
    if (mounted) Navigator.of(context).pop();
    await _controller.connectToDevice(device.mac, deviceName: device.name);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final named = _seen.values.where(_hasName).toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    final unnamed = _seen.values.where((d) => !_hasName(d)).toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));

    return Column(
      children: [
        // const SizedBox(height: FSizes.sm),
        // Center(
        //   child: Container(
        //     width: 40,
        //     height: 4,
        //     decoration: BoxDecoration(
        //       color: FColors.darkGrey.withValues(alpha: 0.3),
        //       borderRadius: BorderRadius.circular(2),
        //     ),
        //   ),
        // ),
        _buildHeader(),
        Expanded(child: _buildBody(named, unnamed)),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FSizes.md, FSizes.md, FSizes.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PaintGaugePage.scanTitle.tr,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            PaintGaugePage.scanSubtitle.tr,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: FColors.darkGrey),
          ),
          const SizedBox(height: FSizes.sm),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildBody(List<BleDevice> named, List<BleDevice> unnamed) {
    if (!_isScanning && _seen.isEmpty) {
      return _EmptyState(
        icon: Iconsax.bluetooth,
        title: PaintGaugePage.noDevicesFound.tr,
        subtitle: PaintGaugePage.noDevicesSubtitle.tr,
      );
    }
    if (_isScanning && _seen.isEmpty) {
      return _EmptyState(
        icon: Iconsax.bluetooth_2,
        title: PaintGaugePage.scanning.tr,
        subtitle: PaintGaugePage.scanningSubtitle.tr,
        showSpinner: true,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: FSizes.xl),
      children: [
        if (named.isNotEmpty) ...[
          _SectionHeader(
            label: PaintGaugePage.namedDevices.tr,
            count: named.length,
          ),
          ...named.map(
            (d) => _DeviceTile(device: d, onTap: () => _connectToDevice(d)),
          ),
        ],
      ],
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FSizes.md,
        FSizes.sm,
        FSizes.md,
        FSizes.xs,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: FColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: FSizes.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: FColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: FColors.primaryColor,
                fontWeight: FontWeight.w600,
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
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: (isNamed ? FColors.primaryColor : FColors.darkGrey)
            .withValues(alpha: 0.12),
        child: Icon(
          Iconsax.bluetooth,
          size: FSizes.iconSm,
          color: isNamed ? FColors.primaryColor : FColors.darkGrey,
        ),
      ),
      title: Text(
        isNamed ? device.name : 'Unknown Device',
        style: TextStyle(
          fontWeight: isNamed ? FontWeight.w600 : FontWeight.normal,
          fontSize: FSizes.fontSizeSm,
        ),
      ),
      subtitle: Text(
        device.mac,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: FColors.darkGrey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SignalBars(rssi: device.rssi),
          const SizedBox(width: FSizes.xs),
          Text(
            '${device.rssi} dBm',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: FColors.darkGrey),
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
        ? FColors.success
        : rssi >= -70
        ? FColors.success
        : rssi >= -80
        ? FColors.warning
        : FColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        4,
        (i) => Container(
          width: 4,
          height: 4.0 + (i * 4),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: i < bars ? color : FColors.grey,
            borderRadius: BorderRadius.circular(1),
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
  final bool showSpinner;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpinner)
              const SizedBox(
                width: FSizes.iconCircleMd,
                height: FSizes.iconCircleMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: FColors.primaryColor,
                ),
              )
            else
              Icon(icon, size: FSizes.buttonHeightLg, color: FColors.grey),
            const SizedBox(height: FSizes.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: FColors.darkGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
