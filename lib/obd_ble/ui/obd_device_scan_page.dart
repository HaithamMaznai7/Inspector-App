import 'dart:io';

import 'package:fahis_inspector/obd_ble/transport/spp.dart';
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

/// Bonded-device picker rendered as the **body of a bottom sheet**. We list
/// devices the user has already paired through Android Bluetooth settings —
/// SPP requires bonding, so live discovery would only confuse the inspector.
/// A "Pair new device" tile opens the system Bluetooth settings so the user
/// can complete pairing and come back.
class ObdDeviceScanPage extends StatefulWidget {
  const ObdDeviceScanPage({super.key});

  @override
  State<ObdDeviceScanPage> createState() => _ObdDeviceScanPageState();
}

class _ObdDeviceScanPageState extends State<ObdDeviceScanPage> {
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
      padding: const EdgeInsets.fromLTRB(FSizes.md, FSizes.sm, FSizes.md, 0),
      child: Column(
        children: [
          Container(
            width: FSizes.iconLg,
            height: FSizes.dividerHeight * 2,
            margin: const EdgeInsets.only(bottom: FSizes.sm),
            decoration: BoxDecoration(
              color: FColors.darkGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(FSizes.dividerHeight),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      InspectionPage.obdScanTitle.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: FSizes.xxs),
                    Text(
                      InspectionPage.obdScanEmptyHint.tr,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: FColors.darkGrey),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: InspectionPage.obdScanStart.tr,
                onPressed: isLoading ? null : onRefresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: FColors.primaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onOpenSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                ),
                icon: const Icon(Icons.settings_bluetooth, size: FSizes.iconSm),
                label: Text(
                  InspectionPage.obdPairNewDevice.tr,
                  style: const TextStyle(
                    fontSize: FSizes.fontSizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
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
    return Container(
      color: isVeepeak
          ? FColors.primaryColor.withValues(alpha: 0.06)
          : Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          radius: FSizes.iconInlineSm,
          backgroundColor: FColors.primaryColor.withValues(alpha: 0.12),
          child: const Icon(
            Iconsax.bluetooth,
            size: FSizes.iconSm,
            color: FColors.primaryColor,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                device.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: FSizes.fontSizeSm,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isVeepeak) ...[
              const SizedBox(width: FSizes.xs),
              const _RecommendedPill(),
            ],
          ],
        ),
        subtitle: Text(
          device.mac,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: FColors.darkGrey),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: FColors.darkGrey,
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
