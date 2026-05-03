import 'dart:io';

import 'package:fahis_inspector/obd_ble/transport/spp.dart';
import 'package:fahis_inspector/obd_ble/ui/obd_ble_scan_page_ios.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';

/// Lightweight description of a paired Bluetooth Classic device. Returned to
/// the caller via `Get.back(result: BleObdDevice)` when the user taps an
/// entry. The class name is kept from the BLE era to avoid cascading renames
/// — internally this is now a Classic SPP device.
class BleObdDevice {
  final String mac;
  final String name;

  /// Bluetooth Classic doesn't surface RSSI from the bonded-device list, so
  /// this stays at 0. Kept on the model only because callers reference it.
  final int rssi;

  const BleObdDevice({required this.mac, required this.name, this.rssi = 0});
}

/// Platform-aware OBD device picker rendered as the body of a bottom sheet.
///
///  - **Android**: bonded-device list (SPP requires bonding before connect,
///    so live discovery would only confuse the inspector). A "Pair new
///    device" tile opens system Bluetooth settings.
///  - **iOS**: live BLE scan filtered by the ELM327 vendor service UUID —
///    bonding is not part of the BLE flow, and Apple forbids RFCOMM, so a
///    BLE adapter (Veepeak OBDCheck BLE) is the only path on iOS.
///
/// In both cases the sheet returns a [BleObdDevice] to the caller via
/// `Get.back()` so the controller can stay platform-agnostic.
class ObdDeviceScanPage extends StatelessWidget {
  const ObdDeviceScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const ObdBleScanPageIos();
    }
    return const _AndroidBondedScanPage();
  }
}

/// Android-only bonded-device picker. Listed devices are pre-paired adapters
/// — SPP can't open a socket to anything else, so showing the full discovery
/// list would just produce dead-end taps.
class _AndroidBondedScanPage extends StatefulWidget {
  const _AndroidBondedScanPage();

  @override
  State<_AndroidBondedScanPage> createState() => _AndroidBondedScanPageState();
}

class _AndroidBondedScanPageState extends State<_AndroidBondedScanPage> {
  List<BleObdDevice> _bonded = const [];
  bool _isLoading = true;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadBonded);
  }

  bool _isVeepeak(BleObdDevice d) => d.name.toUpperCase().contains('VEEPEAK');

  /// Soft-detect adapters likely to be ELM327. Used purely for sort priority
  /// and the "Recommended" pill — never blocks selection.
  bool _looksLikeObd(BleObdDevice d) {
    final n = d.name.toUpperCase();
    return n.contains('OBD') ||
        n.contains('ELM') ||
        n.contains('VEEPEAK') ||
        n.contains('VLINKER');
  }

  Future<bool> _ensurePermissions() async {
    if (!Platform.isAndroid) return false;

    // Android 12+ uses BLUETOOTH_CONNECT for socket connections to bonded
    // devices. Older devices fall through to legacy BLUETOOTH (granted at
    // install time) — the Permission API silently returns granted for those.
    final connect = await Permission.bluetoothConnect.request();
    if (connect.isGranted) return true;

    if (mounted) {
      setState(() {
        _errorKey = InspectionPage.obdBlePermissionDenied;
      });
    }
    return false;
  }

  Future<void> _loadBonded() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorKey = null;
    });

    if (!await _ensurePermissions()) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final isOn = await Spp.isEnabled();
      if (!isOn) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorKey = InspectionPage.obdBleOff;
          });
        }
        return;
      }

      final devices = await Spp.bondedDevices();
      final mapped =
          devices
              .map(
                (d) => BleObdDevice(
                  mac: d.id,
                  name: d.name.isNotEmpty ? d.name : d.id,
                ),
              )
              .toList()
            ..sort((a, b) {
              if (_isVeepeak(a) != _isVeepeak(b)) return _isVeepeak(a) ? -1 : 1;
              if (_looksLikeObd(a) != _looksLikeObd(b)) {
                return _looksLikeObd(a) ? -1 : 1;
              }
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });

      if (!mounted) return;
      setState(() {
        _bonded = mapped;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorKey = InspectionPage.obdBleNotSupported;
        });
      }
    }
  }

  Future<void> _openSystemBluetoothSettings() async {
    try {
      await Spp.openSettings();
    } catch (_) {
      // Non-critical: a few OEM ROMs reject the intent. The inspector can
      // pair via their own Bluetooth UI and come back.
    }
  }

  void _selectDevice(BleObdDevice device) {
    if (!mounted) return;
    Get.back<BleObdDevice>(result: device);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          isLoading: _isLoading,
          onRefresh: _loadBonded,
          onOpenSettings: _openSystemBluetoothSettings,
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _EmptyState(
        icon: Iconsax.bluetooth_2,
        title: InspectionPage.obdScanScanningTitle.tr,
        subtitle: InspectionPage.obdScanScanningHint.tr,
        showSpinner: true,
      );
    }

    if (_errorKey != null) {
      return _EmptyState(
        icon: Iconsax.bluetooth_2,
        title: _errorKey!.tr,
        subtitle: InspectionPage.obdScanEmptyHint.tr,
      );
    }

    if (_bonded.isEmpty) {
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
          count: _bonded.length,
        ),
        ..._bonded.map(
          (d) => _DeviceTile(
            device: d,
            isVeepeak: _isVeepeak(d),
            onTap: () => _selectDevice(d),
          ),
        ),
      ],
    );
  }
}

// ── Header (sheet drag handle + title + refresh / open-settings buttons) ───

class _Header extends StatelessWidget {
  const _Header({
    required this.isLoading,
    required this.onRefresh,
    required this.onOpenSettings,
  });

  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onOpenSettings;

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
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primaryColor.withValues(alpha: 0.1),
                foregroundColor: FColors.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                ),
              ),
              icon: const Icon(Icons.settings_bluetooth, size: FSizes.iconMd),
              label: Text(
                InspectionPage.obdPairNewDevice.tr,
                style: const TextStyle(
                  fontSize: FSizes.fontSizeMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: FSizes.md),
          const Divider(height: 1),
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

class _DeviceTile extends StatelessWidget {
  final BleObdDevice device;
  final bool isVeepeak;
  final VoidCallback onTap;
  const _DeviceTile({
    required this.device,
    required this.isVeepeak,
    required this.onTap,
  });

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
                device.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
          child: Text(
            device.mac,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: FColors.darkGrey,
              letterSpacing: 0.5,
            ),
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
