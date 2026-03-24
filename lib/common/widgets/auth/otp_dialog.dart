import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTPDialog extends StatefulWidget {
  const OTPDialog({super.key});

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> with CodeAutoFill {
  final _otpController = TextEditingController();
  final int _timerKey = 0;

  @override
  void initState() {
    super.initState();
    // Start listening for the incoming OTP SMS.

    SmsAutoFill().listenForCode();
  }

  // Called automatically by the CodeAutoFill mixin when the SMS arrives.
  @override
  void codeUpdated() {
    if (code != null && code!.length == 4) {
      // Push the extracted code into the pin-field controller so
      // PinFieldAutoFill renders it visually.
      _otpController.text = code!;
      // Then immediately verify so the dialog closes without user interaction.
      _verify(code);
    }
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verify(String? code) {
    if (code != null && code.length == 4) {
      Get.back(result: {'action': 'verify', 'code': code});
    }
  }

  void _resend() {
    Get.back(result: {'action': 'resent'});
  }

  void _submit() {
    final code = _otpController.text.trim();
    if (code.length == 4) {
      _verify(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 120 : 24,
        vertical: 40,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: FColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'enterOTP'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Iconsax.close_circle, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: isDark ? FColors.grey : FColors.darkGrey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'otpSentMessage'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? FColors.grey : FColors.darkGrey,
              ),
            ),
            const SizedBox(height: 24),

            // ── OTP Input ─────────────────────────────────────
            PinFieldAutoFill(
              textInputAction: TextInputAction.done,
              codeLength: 4,
              autoFocus: true,
              decoration: BoxLooseDecoration(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: FColors.primaryColor,
                ),
                strokeColorBuilder: PinListenColorBuilder(
                  FColors.primaryColor,
                  isDark
                      ? FColors.grey.withValues(alpha: 0.4)
                      : FColors.grey.withValues(alpha: 0.6),
                ),
                bgColorBuilder: FixedColorBuilder(
                  isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : FColors.grey.withValues(alpha: 0.06),
                ),
                strokeWidth: 1.5,
                radius: const Radius.circular(FSizes.borderRadiusMd),
              ),
              onCodeSubmitted: _verify,
              controller: _otpController,
              onCodeChanged: (code) {
                if (code != null && code.length == 4) {
                  _verify(code);
                }
              },
            ),
            const SizedBox(height: 24),

            // ── Actions ───────────────────────────────────────
            Row(
              children: [
                // Resend / countdown
                Countdown(
                  key: ValueKey(_timerKey),
                  seconds: 60,
                  build: (context, remaining) {
                    if (remaining == 0) {
                      return TextButton.icon(
                        onPressed: _resend,
                        icon: const Icon(Iconsax.redo, size: 16),
                        label: Text('resendOTP'.tr),
                        style: TextButton.styleFrom(
                          foregroundColor: FColors.primaryColor,
                          padding: EdgeInsets.zero,
                        ),
                      );
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 14,
                          color: isDark ? FColors.grey : FColors.darkGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${remaining.toInt()}s',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark ? FColors.grey : FColors.darkGrey,
                              ),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),

                // Verify button
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Iconsax.arrow_right_3, size: 16),
                    label: Text('verify'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primaryColor,
                      foregroundColor: FColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          FSizes.borderRadiusMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
