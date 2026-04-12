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
  final VoidCallback? onConnectTap;

  const ConnectionStatusCard({
    super.key,
    required this.controller,
    this.onConnectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.connectionState.value;
      final isAutoConnecting = controller.isAutoConnecting.value;
      final measured = controller.measuredPanelCount;
      final total = controller.totalPanelCount;

      // Searching = auto-connect scan in progress (before connect handshake begins)
      final isSearching =
          isAutoConnecting && state == BleConnectionState.disconnected;
      // Tappable whenever we're not connected/connecting and not already auto-scanning
      final canConnect =
          !isAutoConnecting &&
          state != BleConnectionState.connected &&
          state != BleConnectionState.connecting;
      final isDisconnected = canConnect;

      return GestureDetector(
        onTap: isDisconnected ? onConnectTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: FSizes.lg,
            vertical: FSizes.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          decoration: BoxDecoration(
            color: _bgColor(context, state, isSearching),
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          ),
          child: Row(
            children: [
              _StatusIcon(state: state, isSearching: isSearching),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stateLabel(state, isSearching),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _textColor(state, isSearching),
                      ),
                    ),
                    Text(
                      isDisconnected
                          ? PaintGaugePage.connectHint.tr
                          : '$measured/$total ${PaintGaugePage.measuredPanels.tr}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDisconnected
                            ? FColors.primaryColor.withValues(alpha: 0.7)
                            : FColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (state == BleConnectionState.connected)
                TextButton.icon(
                  onPressed: controller.disconnect,
                  icon: const Icon(
                    Iconsax.bluetooth_circle,
                    size: FSizes.iconSm,
                  ),
                  label: Text(PaintGaugePage.goBack.tr),
                  style: TextButton.styleFrom(
                    foregroundColor: FColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.sm,
                      vertical: FSizes.xs,
                    ),
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                )
              else if (isDisconnected)
                TextButton(
                  onPressed: onConnectTap,
                  style: TextButton.styleFrom(
                    foregroundColor: FColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.sm,
                      vertical: FSizes.xs,
                    ),
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  child: Text(PaintGaugePage.connectButton.tr),
                ),
            ],
          ),
        ),
      );
    });
  }

  Color _bgColor(
    BuildContext context,
    BleConnectionState state,
    bool isSearching,
  ) {
    if (isSearching) return FColors.warning.withValues(alpha: 0.08);
    switch (state) {
      case BleConnectionState.connected:
        return FColors.success.withValues(alpha: 0.08);
      case BleConnectionState.lostConnection:
      case BleConnectionState.error:
        return FColors.error.withValues(alpha: 0.08);
      case BleConnectionState.connecting:
        return FColors.warning.withValues(alpha: 0.08);
      case BleConnectionState.disconnected:
        return FColors.primaryColor.withValues(alpha: 0.08);
    }
  }

  Color _textColor(BleConnectionState state, bool isSearching) {
    if (isSearching) return FColors.warning;
    switch (state) {
      case BleConnectionState.connected:
        return FColors.success;
      case BleConnectionState.lostConnection:
      case BleConnectionState.error:
        return FColors.error;
      case BleConnectionState.connecting:
        return FColors.warning;
      case BleConnectionState.disconnected:
        return FColors.primaryColor;
    }
  }

  String _stateLabel(BleConnectionState state, bool isSearching) {
    if (isSearching) return PaintGaugePage.scanning.tr;
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
  final bool isSearching;
  const _StatusIcon({required this.state, this.isSearching = false});

  @override
  Widget build(BuildContext context) {
    if (isSearching || state == BleConnectionState.connecting) {
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
        color = FColors.primaryColor;
    }

    return Icon(icon, size: FSizes.iconInlineSm, color: color);
  }
}
