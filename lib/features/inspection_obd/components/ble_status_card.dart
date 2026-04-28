import 'package:fahis_inspector/features/inspection_obd/controller.dart';
import 'package:fahis_inspector/obd_ble/services/obd_ble_connection_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Shows the BLE device connection state and action buttons (Connect /
/// Disconnect / Read from device / Reconnect) above the OBD codes list.
///
/// All state is read from [controller] observables; all actions delegate back
/// to controller methods so no business logic lives here.
class BleStatusCard extends StatelessWidget {
  const BleStatusCard({super.key, required this.controller});

  final InspectionObdController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.bleState.value;
      final isReading = controller.isReadingFromDevice.value;
      final deviceName = controller.connectedDeviceName.value;

      return switch (state) {
        ObdBleConnectionState.disconnected => _DisconnectedRow(
          onConnect: controller.pickAndConnectDevice,
        ),
        ObdBleConnectionState.connecting => const _ConnectingRow(),
        ObdBleConnectionState.connected => _ConnectedRow(
          deviceName: deviceName,
          isReading: isReading,
          onDisconnect: controller.disconnectDevice,
          onRead: controller.readCodesFromDevice,
        ),
        ObdBleConnectionState.lostConnection ||
        ObdBleConnectionState.error => _ReconnectRow(
          onReconnect: controller.pickAndConnectDevice,
        ),
      };
    });
  }
}

// ── Disconnected ─────────────────────────────────────────────────────────────

class _DisconnectedRow extends StatelessWidget {
  const _DisconnectedRow({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return _BleRow(
      leading: Icon(
        Iconsax.bluetooth,
        size: FSizes.iconInlineSm,
        color: FColors.darkGrey,
      ),
      label: InspectionPage.obdConnectDevice.tr,
      trailing: _BleButton(
        label: InspectionPage.obdConnectDevice.tr,
        icon: Iconsax.bluetooth,
        color: FColors.primaryColor,
        onTap: onConnect,
      ),
    );
  }
}

// ── Connecting ───────────────────────────────────────────────────────────────

class _ConnectingRow extends StatelessWidget {
  const _ConnectingRow();

  @override
  Widget build(BuildContext context) {
    return _BleRow(
      leading: const SizedBox(
        width: FSizes.iconInlineSm,
        height: FSizes.iconInlineSm,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: FColors.primaryColor,
        ),
      ),
      label: InspectionPage.obdConnecting.tr,
    );
  }
}

// ── Connected ─────────────────────────────────────────────────────────────────

class _ConnectedRow extends StatelessWidget {
  const _ConnectedRow({
    required this.deviceName,
    required this.isReading,
    required this.onDisconnect,
    required this.onRead,
  });

  final String? deviceName;
  final bool isReading;
  final VoidCallback onDisconnect;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    return _BleRow(
      leading: const Icon(
        Iconsax.bluetooth,
        size: FSizes.iconInlineSm,
        color: FColors.success,
      ),
      label: deviceName != null
          ? InspectionPage.obdConnectedTo.trParams({'name': deviceName!})
          : InspectionPage.obdConnectDevice.tr,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BleButton(
            label: InspectionPage.obdDisconnect.tr,
            icon: Iconsax.bluetooth_2,
            color: FColors.error,
            onTap: onDisconnect,
          ),
          const SizedBox(width: FSizes.xs),
          isReading
              ? const SizedBox(
                  width: FSizes.iconInlineSm,
                  height: FSizes.iconInlineSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: FColors.primaryColor,
                  ),
                )
              : _BleButton(
                  label: InspectionPage.obdReadFromDevice.tr,
                  icon: Iconsax.cpu,
                  color: FColors.primaryColor,
                  onTap: onRead,
                ),
        ],
      ),
    );
  }
}

// ── Lost / Error ─────────────────────────────────────────────────────────────

class _ReconnectRow extends StatelessWidget {
  const _ReconnectRow({required this.onReconnect});

  final VoidCallback onReconnect;

  @override
  Widget build(BuildContext context) {
    return _BleRow(
      leading: const Icon(
        Iconsax.bluetooth_2,
        size: FSizes.iconInlineSm,
        color: FColors.error,
      ),
      label: InspectionPage.obdDeviceDisconnected.tr,
      trailing: _BleButton(
        label: InspectionPage.obdReconnect.tr,
        icon: Iconsax.refresh,
        color: FColors.warning,
        onTap: onReconnect,
      ),
    );
  }
}

// ── Shared atoms ─────────────────────────────────────────────────────────────

class _BleRow extends StatelessWidget {
  const _BleRow({required this.leading, required this.label, this.trailing});

  final Widget leading;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? FColors.darkGrey.withValues(alpha: 0.15)
            : FColors.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(
          color: FColors.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? FColors.light : FColors.dark,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: FSizes.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _BleButton extends StatelessWidget {
  const _BleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm,
          vertical: FSizes.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: FSizes.fontSizeSm, color: color),
            const SizedBox(width: FSizes.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: FSizes.fontSizeXs,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
