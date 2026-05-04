import 'dart:async';

import 'package:fahis_inspector/obd_ble/ui/obd_device_scan_page.dart'
    show BleObdDevice;
import 'package:fahis_inspector/obd_ble/util/obd_logger.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// iOS BLE scanner for ELM327-class OBD-II adapters (Veepeak OBDCheck BLE et
/// al.).
///
/// Why no `withServices` filter: iOS' CoreBluetooth matches that filter
/// against the **advertisement packet** only, not against post-connect
/// service discovery. The BT5050 / ISSC chip family used by Veepeak doesn't
/// fit the 128-bit OBD service UUID into its 31-byte advertisement, so a
/// service filter would silently drop every Veepeak adapter from the list
/// (verified in the field — paint-gauge scan saw VEEPEAK with no filter,
/// OBD scan saw nothing with the filter). Instead we mirror the paint-gauge
/// approach: scan everything, sort OBD-looking names to the top, and let
/// `BleTransport.connect()` validate the OBD GATT service after connection.
///
/// Returns the chosen device to the caller as [BleObdDevice] (the same model
/// the Android bonded-device picker emits) so `connectToDevice(mac, name)` in
/// the controller stays platform-agnostic.
class ObdBleScanPageIos extends StatefulWidget {
  const ObdBleScanPageIos({super.key});

  @override
  State<ObdBleScanPageIos> createState() => _ObdBleScanPageIosState();
}

class _ObdBleScanPageIosState extends State<ObdBleScanPageIos> {
  final Map<String, ScanResult> _seen = <String, ScanResult>{};
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  bool _isScanning = false;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      var changed = false;
      for (final r in results) {
        final id = r.device.remoteId.str;
        final prev = _seen[id];
        if (prev == null || prev.rssi != r.rssi) {
          if (prev == null) {
            ObdLogger.info(
              'Scan saw "${_displayName(r)}" ($id) ${r.rssi} dBm',
            );
          }
          _seen[id] = r;
          changed = true;
        }
      }
      if (changed && mounted) setState(() {});
    });
    _isScanningSub = FlutterBluePlus.isScanning.listen((v) {
      if (!mounted) return;
      setState(() => _isScanning = v);
    });
    Future.microtask(_startScan);
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (!mounted) return;
    setState(() {
      _errorKey = null;
      _seen.clear();
    });

    try {
      final supported = await FlutterBluePlus.isSupported;
      if (!supported) {
        ObdLogger.error('BLE not supported on this device');
        if (!mounted) return;
        setState(() => _errorKey = InspectionPage.obdBleNotSupported);
        return;
      }
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        ObdLogger.warn('BLE adapter not on: $adapterState');
        if (!mounted) return;
        setState(() => _errorKey = InspectionPage.obdBleOff);
        return;
      }

      await FlutterBluePlus.stopScan();
      // No `withServices` filter: BT5050-class OBD adapters don't advertise
      // the OBD service UUID, so an iOS-side filter rejects them. Service
      // identity is enforced post-connect inside `BleTransport`.
      // No `timeout`: scan stays alive while the sheet is open;
      // `dispose()` and `_selectDevice()` both stop it.
      ObdLogger.info('Starting BLE scan (no filter, no timeout)');
      await FlutterBluePlus.startScan();
    } catch (e) {
      ObdLogger.error('startScan failed: $e');
      if (!mounted) return;
      setState(() => _errorKey = InspectionPage.obdBleNotSupported);
    }
  }

  // ── Name-based hinting ────────────────────────────────────────────────
  // BT5050 adapters don't advertise the OBD service UUID, so we can only
  // tell them apart from random nearby BLE devices by their broadcast name.
  // Mirrors the Android bonded-picker helpers in `obd_device_scan_page.dart`.

  static bool _isVeepeak(String name) =>
      name.toUpperCase().contains('VEEPEAK');

  static bool _looksLikeObd(String name) {
    final n = name.toUpperCase();
    return n.contains('OBD') ||
        n.contains('ELM') ||
        n.contains('VEEPEAK') ||
        n.contains('VLINKER') ||
        n.contains('OBDLINK');
  }

  void _selectDevice(ScanResult result) {
    if (!mounted) return;
    final name = _displayName(result);
    FlutterBluePlus.stopScan();
    Get.back<BleObdDevice>(
      result: BleObdDevice(
        mac: result.device.remoteId.str,
        name: name,
        rssi: result.rssi,
      ),
    );
  }

  String _displayName(ScanResult r) {
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    if (r.advertisementData.advName.isNotEmpty) {
      return r.advertisementData.advName;
    }
    return r.device.remoteId.str;
  }

  @override
  Widget build(BuildContext context) {
    final results = _seen.values.toList()
      ..sort((a, b) {
        // Tier 1: Veepeak first (the recommended adapter).
        final aVeepeak = _isVeepeak(_displayName(a));
        final bVeepeak = _isVeepeak(_displayName(b));
        if (aVeepeak != bVeepeak) return aVeepeak ? -1 : 1;
        // Tier 2: other OBD-looking names next.
        final aObd = _looksLikeObd(_displayName(a));
        final bObd = _looksLikeObd(_displayName(b));
        if (aObd != bObd) return aObd ? -1 : 1;
        // Tier 3: tie-break by RSSI desc (closest device on top).
        return b.rssi.compareTo(a.rssi);
      });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(isScanning: _isScanning, onRefresh: _startScan),
        Expanded(child: _buildBody(results)),
      ],
    );
  }

  Widget _buildBody(List<ScanResult> results) {
    if (_errorKey != null) {
      return _EmptyState(
        icon: Iconsax.bluetooth_2,
        title: _errorKey!.tr,
        subtitle: InspectionPage.obdScanEmptyHint.tr,
      );
    }
    if (_isScanning && results.isEmpty) {
      return _EmptyState(
        icon: Iconsax.bluetooth_2,
        title: InspectionPage.obdScanScanningTitle.tr,
        subtitle: InspectionPage.obdScanScanningHint.tr,
        showSpinner: true,
      );
    }
    if (results.isEmpty) {
      return _EmptyState(
        icon: Iconsax.bluetooth,
        title: InspectionPage.obdScanEmptyTitle.tr,
        subtitle: InspectionPage.obdScanEmptyHint.tr,
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: FSizes.xl),
      children: [
        _SectionHeader(
          label: InspectionPage.obdScanSectionNamed.tr,
          count: results.length,
        ),
        ...results.map(
          (r) {
            final name = _displayName(r);
            return _DeviceTile(
              name: name,
              id: r.device.remoteId.str,
              rssi: r.rssi,
              isVeepeak: _isVeepeak(name),
              onTap: () => _selectDevice(r),
            );
          },
        ),
      ],
    );
  }
}

// ── Header (sheet drag handle + title + refresh) ──────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isScanning, required this.onRefresh});

  final bool isScanning;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(FSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      InspectionPage.obdScanTitle.tr,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: FSizes.xs),
                    Text(
                      InspectionPage.obdScanEmptyHint.tr,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: FColors.darkGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Container(
                decoration: BoxDecoration(
                  color: FColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: InspectionPage.obdScanStart.tr,
                  onPressed: isScanning ? null : onRefresh,
                  icon: isScanning
                      ? const SizedBox(
                          width: FSizes.iconSm,
                          height: FSizes.iconSm,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: FColors.primaryColor,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: FColors.primaryColor,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});

  final String label;
  final int count;

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

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.name,
    required this.id,
    required this.rssi,
    required this.isVeepeak,
    required this.onTap,
  });

  final String name;
  final String id;
  final int rssi;
  final bool isVeepeak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: FSizes.md,
        vertical: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: isVeepeak
            ? FColors.primaryColor.withValues(alpha: 0.05)
            : Colors.transparent,
        border: Border.all(
          color: isVeepeak
              ? FColors.primaryColor.withValues(alpha: 0.3)
              : (isDark ? FColors.darkerGrey : FColors.borderPrimary)
                  .withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.xs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(FSizes.sm),
          decoration: BoxDecoration(
            color: isVeepeak
                ? FColors.primaryColor.withValues(alpha: 0.15)
                : FColors.primaryColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.bluetooth,
            size: FSizes.iconMd,
            color: FColors.primaryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isVeepeak) ...[
              const SizedBox(width: FSizes.xs),
              const _RecommendedPill(),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: FSizes.xxs),
          child: Row(
            children: [
              _SignalBars(rssi: rssi),
              const SizedBox(width: FSizes.xs),
              Text(
                '$rssi dBm',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: FColors.darkGrey,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(FSizes.xxs),
          decoration: BoxDecoration(
            color: isDark
                ? FColors.darkGrey.withValues(alpha: 0.2)
                : FColors.lightGrey,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_right_rounded,
            color: FColors.darkGrey,
            size: FSizes.iconSm,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _RecommendedPill extends StatelessWidget {
  const _RecommendedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xxs,
      ),
      decoration: BoxDecoration(
        color: FColors.primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: Text(
        InspectionPage.obdScanRecommended.tr,
        style: const TextStyle(
          fontSize: FSizes.fontSizeXs,
          fontWeight: FontWeight.w700,
          color: FColors.primaryColor,
        ),
      ),
    );
  }
}

/// Three-bar signal-strength indicator. Rough RSSI buckets — close enough for
/// the inspector to tell the device sitting in the OBD port apart from one
/// across the room.
class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.rssi});

  final int rssi;

  @override
  Widget build(BuildContext context) {
    final filled = rssi >= -60
        ? 3
        : rssi >= -75
            ? 2
            : 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final active = i < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Container(
            width: 3,
            height: 4 + (i * 3).toDouble(),
            decoration: BoxDecoration(
              color: active
                  ? FColors.primaryColor
                  : FColors.darkGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.xl),
              decoration: BoxDecoration(
                color: (isDark ? FColors.light : FColors.darkGrey).withValues(
                  alpha: 0.05,
                ),
                shape: BoxShape.circle,
              ),
              child: showSpinner
                  ? const SizedBox(
                      width: FSizes.iconLg * 1.5,
                      height: FSizes.iconLg * 1.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: FColors.primaryColor,
                      ),
                    )
                  : Icon(
                      icon,
                      size: FSizes.iconLg * 2,
                      color: (isDark ? FColors.light : FColors.darkGrey)
                          .withValues(alpha: 0.5),
                    ),
            ),
            const SizedBox(height: FSizes.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDark ? FColors.light : FColors.dark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FColors.darkGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
