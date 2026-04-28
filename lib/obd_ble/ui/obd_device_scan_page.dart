import 'dart:async';
import 'dart:io';

import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';

/// Lightweight description of a discovered BLE device. Returned to the
/// caller via `Get.back(result: BleObdDevice)` when the user taps an entry.
class BleObdDevice {
  final String mac;
  final String name;
  final int rssi;
  const BleObdDevice({
    required this.mac,
    required this.name,
    required this.rssi,
  });
}

/// Veepeak / ELM327 scan picker rendered as the **body of a bottom sheet**
/// (matches the paint gauge UX). Connection itself is owned by
/// [InspectionObdController] so the OBD screen can show its own progress +
/// error states.
///
/// Tapping a device pops the sheet with `Get.back(result: BleObdDevice)`.
class ObdDeviceScanPage extends StatefulWidget {
  const ObdDeviceScanPage({super.key});

  @override
  State<ObdDeviceScanPage> createState() => _ObdDeviceScanPageState();
}

class _ObdDeviceScanPageState extends State<ObdDeviceScanPage> {
  final Map<String, BleObdDevice> _seen = {};
  bool _isScanning = false;
  StreamSubscription? _scanSub;

  @override
  void initState() {
    super.initState();
    // Auto-start scanning when the sheet opens — same UX as paint gauge.
    Future.microtask(_startScan);
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    if (_isScanning) FlutterBluePlus.stopScan();
    super.dispose();
  }

  bool _hasName(BleObdDevice d) => d.name != d.mac;

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;

    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return;
    }
    if (await Permission.location.request().isGranted) return;
    _showSnackBar(InspectionPage.obdBlePermissionDenied.tr, FColors.error);
  }

  Future<void> _startScan() async {
    await _requestPermissions();

    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      _showSnackBar(InspectionPage.obdBleNotSupported.tr, FColors.error);
      return;
    }
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _showSnackBar(InspectionPage.obdBleOff.tr, FColors.warning);
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
        _seen[d.remoteId.str] = BleObdDevice(
          mac: d.remoteId.str,
          name: name,
          rssi: r.rssi,
        );
        changed = true;
      }
      if (changed && mounted) setState(() {});
    });

    try {
      await FlutterBluePlus.startScan();
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(InspectionPage.obdBleOff.tr, FColors.warning);
      setState(() => _isScanning = false);
    }
  }

  Future<void> _stopScan() async {
    _scanSub?.cancel();
    _scanSub = null;
    await FlutterBluePlus.stopScan();
    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _selectDevice(BleObdDevice device) async {
    if (_isScanning) await _stopScan();
    if (!mounted) return;
    Get.back<BleObdDevice>(result: device);
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

  @override
  Widget build(BuildContext context) {
    final named = _seen.values.where(_hasName).toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // _Header(
        //   isScanning: _isScanning,
        //   onScanToggle: _isScanning ? _stopScan : _startScan,
        // ),
        _buildHeader(),
        Expanded(child: _buildBody(named)),
      ],
    );
  }

  Widget _buildBody(List<BleObdDevice> named) {
    if (!_isScanning && _seen.isEmpty) {
      return _EmptyState(
        icon: Iconsax.bluetooth,
        title: InspectionPage.obdScanEmptyTitle.tr,
        subtitle: InspectionPage.obdScanEmptyHint.tr,
      );
    }
    if (_isScanning && _seen.isEmpty) {
      return _EmptyState(
        icon: Iconsax.bluetooth_2,
        title: InspectionPage.obdScanScanningTitle.tr,
        subtitle: InspectionPage.obdScanScanningHint.tr,
        showSpinner: true,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: FSizes.xl),
      children: [
        if (named.isNotEmpty) ...[
          _SectionHeader(
            label: InspectionPage.obdScanSectionNamed.tr,
            count: named.length,
          ),
          ...named.map(
            (d) => _DeviceTile(device: d, onTap: () => _selectDevice(d)),
          ),
        ],
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
            InspectionPage.obdScanTitle.tr,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: FSizes.xxs),
          Text(
            InspectionPage.obdScanScanningHint.tr,
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
}

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
              vertical: FSizes.xxs,
            ),
            decoration: BoxDecoration(
              color: FColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: FColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Device tile ─────────────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  final BleObdDevice device;

  final VoidCallback onTap;
  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNamed = device.name != device.mac;
    final accent = isNamed ? FColors.primaryColor : FColors.darkGrey;

    return ListTile(
      leading: CircleAvatar(
        radius: FSizes.iconInlineSm,
        backgroundColor: accent.withValues(alpha: 0.12),
        child: Icon(Iconsax.bluetooth, size: FSizes.iconSm, color: accent),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              isNamed ? device.name : InspectionPage.obdScanUnknownDevice.tr,
              style: TextStyle(
                fontWeight: isNamed ? FontWeight.w600 : FontWeight.normal,
                fontSize: FSizes.fontSizeSm,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

// ── Signal strength ─────────────────────────────────────────────────────────

class _SignalBars extends StatelessWidget {
  final int rssi;
  const _SignalBars({required this.rssi});

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    final bars = rssi >= -60
        ? 4
        : rssi >= -70
        ? 3
        : rssi >= -80
        ? 2
        : 1;
    final color = rssi >= -70
        ? FColors.success
        : rssi >= -80
        ? FColors.warning
        : FColors.error;
    final inactive = (isDark ? FColors.light : FColors.darkGrey).withValues(
      alpha: 0.25,
    );

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
            color: i < bars ? color : inactive,
            borderRadius: BorderRadius.circular(FSizes.dividerHeight),
          ),
        ),
      ),
    );
  }
}

// ── Empty / scanning state ──────────────────────────────────────────────────

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
    final isDark = FHelper.isDarkMode(context);
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
              Icon(
                icon,
                size: FSizes.buttonHeightLg,
                color: (isDark ? FColors.light : FColors.darkGrey).withValues(
                  alpha: 0.4,
                ),
              ),
            const SizedBox(height: FSizes.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? FColors.light : FColors.dark,
              ),
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
