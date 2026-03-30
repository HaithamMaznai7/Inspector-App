import 'dart:io';

import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:timer_count_down/timer_count_down.dart';

class OTPDialog extends StatefulWidget {
  const OTPDialog({super.key});

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> with WidgetsBindingObserver {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final int _timerKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      _listenWithConsent();
    }
  }

  /// Re-focus the pin field when the user returns from another app so the
  /// keyboard reappears and can show its OTP autofill suggestion.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  Future<void> _listenWithConsent() async {
    AppLogger.trace('OTP', 'Starting SMS User Consent API listener');
    final result = await SmartAuth.instance.getSmsWithUserConsentApi(
      matcher: r'\d{4}',
    );
    AppLogger.trace('OTP', 'User Consent API result', result);
    if (!mounted) return;
    if (result.hasData) {
      final code = result.requireData.code;
      AppLogger.info('OTP', 'Extracted code from SMS', code);
      if (code != null && code.length == 4) {
        _pinController.text = code;
      }
    } else if (result.isCanceled) {
      AppLogger.warn('OTP', 'User dismissed the SMS consent dialog');
    } else if (result.hasError) {
      AppLogger.error('OTP', 'SMS User Consent API failed', result.error);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isAndroid) {
      SmartAuth.instance.removeUserConsentApiListener();
    }
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verify(String code) {
    Get.back(result: {'action': 'verify', 'code': code});
  }

  void _resend() {
    Get.back(result: {'action': 'resent'});
  }

  void _submit() {
    final code = _pinController.text.trim();
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

    // ── Pin Themes ──────────────────────────────────────
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: FColors.primaryColor,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : FColors.grey.withValues(alpha: 0.06),
        border: Border.all(
          color: isDark
              ? FColors.grey.withValues(alpha: 0.4)
              : FColors.grey.withValues(alpha: 0.6),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: FColors.primaryColor, width: 1.5),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: FColors.primaryColor, width: 1.5),
    );

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
            AutofillGroup(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 4,
                  controller: _pinController,
                  focusNode: _focusNode,
                  autofocus: true,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  keyboardType: TextInputType.number,
                  closeKeyboardWhenCompleted: false,
                  onCompleted: _verify,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Actions ───────────────────────────────────────
            Row(
              children: [
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
