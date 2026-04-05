import 'package:fahis_inspector/features/paint_gauge/controller.dart';
import 'package:fahis_inspector/paint_gauge/services/ble_connection_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ConnectionStatusCard extends StatelessWidget {
  final PaintGaugeController controller;

  const ConnectionStatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.connectionState.value;
      final measured = controller.measuredPanelCount;
      final total = controller.totalPanelCount;

      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: FSizes.md, vertical: FSizes.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md, vertical: FSizes.sm),
        decoration: BoxDecoration(
          color: _bgColor(context, state),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
          border: Border.all(color: _borderColor(state)),
        ),
        child: Row(
          children: [
            _StatusIcon(state: state),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stateLabel(state),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _textColor(state),
                        ),
                  ),
                  Text(
                    '$measured/$total ${PaintGaugePage.measuredPanels.tr}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FColors.darkGrey,
                        ),
                  ),
                ],
              ),
            ),
            if (controller.isConnected.value)
              TextButton.icon(
                onPressed: controller.disconnect,
                icon: const Icon(Iconsax.bluetooth_circle, size: FSizes.iconSm),
                label: Text(PaintGaugePage.goBack.tr),
                style: TextButton.styleFrom(
                  foregroundColor: FColors.error,
                  padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.sm, vertical: FSizes.xs),
                  textStyle: Theme.of(context).textTheme.labelSmall,
                ),
              ),
          ],
        ),
      );
    });
  }

  Color _bgColor(BuildContext context, BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return FColors.success.withValues(alpha: 0.08);
      case BleConnectionState.lostConnection:
      case BleConnectionState.error:
        return FColors.error.withValues(alpha: 0.08);
      case BleConnectionState.connecting:
        return FColors.warning.withValues(alpha: 0.08);
      case BleConnectionState.disconnected:
        return Theme.of(context).cardColor;
    }
  }

  Color _borderColor(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return FColors.success.withValues(alpha: 0.3);
      case BleConnectionState.lostConnection:
      case BleConnectionState.error:
        return FColors.error.withValues(alpha: 0.3);
      case BleConnectionState.connecting:
        return FColors.warning.withValues(alpha: 0.3);
      case BleConnectionState.disconnected:
        return FColors.borderSecondary;
    }
  }

  Color _textColor(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return FColors.success;
      case BleConnectionState.lostConnection:
      case BleConnectionState.error:
        return FColors.error;
      case BleConnectionState.connecting:
        return FColors.warning;
      case BleConnectionState.disconnected:
        return FColors.darkGrey;
    }
  }

  String _stateLabel(BleConnectionState state) {
    switch (state) {
      case BleConnectionState.connected:
        return PaintGaugePage.connected.tr;
      case BleConnectionState.connecting:
        return PaintGaugePage.connecting.tr;
      case BleConnectionState.disconnected:
        return PaintGaugePage.disconnected.tr;
      case BleConnectionState.lostConnection:
        return PaintGaugePage.lostConnection.tr;
      case BleConnectionState.error:
        return PaintGaugePage.connectionError.tr;
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final BleConnectionState state;
  const _StatusIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state == BleConnectionState.connecting) {
      return const SizedBox(
        width: FSizes.iconMd,
        height: FSizes.iconMd,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: FColors.warning,
        ),
      );
    }

    IconData icon;
    Color color;
    switch (state) {
      case BleConnectionState.connected:
        icon = Iconsax.bluetooth_2;
        color = FColors.success;
        break;
      case BleConnectionState.lostConnection:
      case BleConnectionState.error:
        icon = Iconsax.bluetooth_circle;
        color = FColors.error;
        break;
      default:
        icon = Iconsax.bluetooth;
        color = FColors.darkGrey;
    }

    return Icon(icon, size: FSizes.iconMd, color: color);
  }
}
