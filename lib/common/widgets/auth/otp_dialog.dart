import 'dart:io';

import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:fahis_inspector/util/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:timer_count_down/timer_count_down.dart';

class OTPDialog extends StatefulWidget {
  const OTPDialog({
    super.key,
    this.phoneNumber,
    this.sendOtpFuture,
    this.onResend,
  });

  /// The phone number to display (masked automatically).
  final String? phoneNumber;

  /// Future that resolves with the verify token when the send-OTP API completes.
  /// When provided, the OTP screen shows a "Sending..." state until it resolves.
  /// When null, the PIN input is immediately enabled (legacy/retry mode).
  final Future<String>? sendOtpFuture;

  /// Callback to resend OTP. Should register SMS listener and fire the API.
  /// Returns the new verify token. When null, resend falls back to returning
  /// `{'action': 'resent'}` for the controller to handle externally.
  final Future<String> Function()? onResend;

  // ── Pre-send SMS listener ───────────────────────────────────────────
  static Future<SmartAuthResult<SmartAuthSms>>? _pendingSmsResult;

  /// Call BEFORE the API that sends the OTP.
  static void startSmsListener() {
    if (!Platform.isAndroid) return;
    AppLogger.trace(
      'OTP',
      'Pre-registering SMS User Consent listener (before API call)',
    );
    _pendingSmsResult = SmartAuth.instance.getSmsWithUserConsentApi(
      matcher: r'\d{4}',
    );
    AppLogger.trace('OTP', 'Listener Future obtained — waiting for SMS');
  }

  /// Cancel any pending listener (e.g. if the API call fails).
  static void cancelSmsListener() {
    if (!Platform.isAndroid) return;
    AppLogger.trace('OTP', 'Cancelling pre-registered SMS listener');
    _pendingSmsResult = null;
    SmartAuth.instance.removeUserConsentApiListener();
  }

  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 7) return phone;
    final prefix = digits.substring(0, 4);
    final suffix = digits.substring(digits.length - 3);
    final masked = '*' * (digits.length - 7);
    return '$prefix $masked $suffix';
  }

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> with WidgetsBindingObserver {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  int _timerKey = 0;

  /// True while waiting for the send-OTP API to respond.
  bool _isSending = false;

  /// The verify token returned by the send-OTP API.
  String? _verifyToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _consumeSmsListener();
    _awaitOtpSend();
  }

  // ── API await ──────────────────────────────────────────────────────

  Future<void> _awaitOtpSend() async {
    if (widget.sendOtpFuture == null) {
      // No future → PIN is ready immediately (retry or legacy usage).
      return;
    }

    setState(() => _isSending = true);

    try {
      final token = await widget.sendOtpFuture!;
      if (!mounted) return;
      AppLogger.info('OTP', 'Send-OTP API succeeded, token received');
      setState(() {
        _verifyToken = token;
        _isSending = false;
      });
    } on FNetworkException catch (e) {
      if (!mounted) return;
      AppLogger.error('OTP', 'Send-OTP API failed (network)', e);
      e.notify();
      Get.back();
    } catch (e) {
      if (!mounted) return;
      AppLogger.error('OTP', 'Send-OTP API failed', e);
      Get.back();
    }
  }

  // ── SMS listener ───────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      AppLogger.trace('OTP', 'App resumed — re-requesting focus');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  Future<void> _consumeSmsListener() async {
    if (!Platform.isAndroid) return;

    final pending = OTPDialog._pendingSmsResult;
    OTPDialog._pendingSmsResult = null;

    if (pending != null) {
      AppLogger.trace('OTP', 'Consuming pre-registered SMS listener');
      await _handleSmsResult(pending);
    } else {
      AppLogger.warn(
        'OTP',
        'No pre-registered listener found — starting fresh (SMS may have '
            'already arrived, consent dialog might not appear)',
      );
      final fresh = SmartAuth.instance.getSmsWithUserConsentApi(
        matcher: r'\d{4}',
      );
      await _handleSmsResult(fresh);
    }
  }

  Future<void> _handleSmsResult(
    Future<SmartAuthResult<SmartAuthSms>> future,
  ) async {
    try {
      final result = await future;

      if (!mounted) {
        AppLogger.warn('OTP', 'Widget disposed before SMS result arrived');
        return;
      }

      if (result.hasData) {
        final sms = result.requireData;
        AppLogger.info('OTP', 'SMS received via consent', {
          'code': sms.code,
          'sms': sms.sms.substring(0, sms.sms.length.clamp(0, 40)),
        });
        final code = sms.code;
        if (code != null && code.length == 4) {
          _pinController.text = code;
        } else {
          AppLogger.warn(
            'OTP',
            'Extracted code is null or unexpected length',
            code,
          );
        }
      } else if (result.isCanceled) {
        AppLogger.warn('OTP', 'User tapped Deny on the consent dialog');
      } else if (result.hasError) {
        AppLogger.error('OTP', 'SMS Consent API error', result.error);
      } else {
        AppLogger.warn('OTP', 'SMS Consent returned with no data/error', {
          'hasData': result.hasData,
          'isCanceled': result.isCanceled,
          'hasError': result.hasError,
        });
      }
    } catch (e, st) {
      AppLogger.error('OTP', 'Exception in SMS consent handler', e);
      AppLogger.trace('OTP', 'Stack trace', st);
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

  // ── Actions ────────────────────────────────────────────────────────

  void _verify(String code) {
    if (_isSending) return; // Guard: API hasn't responded yet
    AppLogger.info('OTP', 'Submitting OTP', code);
    Get.back(
      result: {
        'action': 'verify',
        'code': code,
        if (_verifyToken != null) 'token': _verifyToken,
      },
    );
  }

  Future<void> _resend() async {
    if (widget.onResend == null) {
      // Legacy: let the controller handle resend externally.
      AppLogger.trace('OTP', 'User tapped Resend (legacy mode)');
      Get.back(result: {'action': 'resent'});
      return;
    }

    AppLogger.trace('OTP', 'User tapped Resend — calling onResend callback');
    setState(() {
      _isSending = true;
      _pinController.clear();
    });

    try {
      final token = await widget.onResend!();
      if (!mounted) return;
      AppLogger.info('OTP', 'Resend succeeded, new token received');
      setState(() {
        _verifyToken = token;
        _isSending = false;
        _timerKey++; // Reset the countdown timer
      });
    } on FNetworkException catch (e) {
      if (!mounted) return;
      AppLogger.error('OTP', 'Resend failed (network)', e);
      setState(() => _isSending = false);
      e.notify();
    } catch (e) {
      if (!mounted) return;
      AppLogger.error('OTP', 'Resend failed', e);
      setState(() => _isSending = false);
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final subtitleColor = isDark ? FColors.grey : FColors.darkGrey;

    // ── Pin Themes ──────────────────────────────────────
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : FColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : FColors.softGrey,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : FColors.borderSecondary,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        border: Border.all(color: FColors.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: isDark
            ? FColors.primaryColor.withValues(alpha: 0.12)
            : FColors.primaryColor.withValues(alpha: 0.06),
        border: Border.all(
          color: FColors.primaryColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
    );

    final disabledPinTheme = defaultPinTheme.copyWith(
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: (isDark ? Colors.white : FColors.textPrimary).withValues(
          alpha: 0.3,
        ),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : FColors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : FColors.borderSecondary.withValues(alpha: 0.5),
        ),
      ),
    );

    final maskedPhone = widget.phoneNumber != null
        ? OTPDialog.maskPhone(widget.phoneNumber!)
        : null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 120 : FSizes.lg,
            ),
            child: Column(
              children: [
                const SizedBox(height: FSizes.sm),

                // ── Top bar with close button ──
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : FColors.softGrey,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Lock icon ──
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: FColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.lock_1,
                    size: 32,
                    color: FColors.primaryColor,
                  ),
                ),
                const SizedBox(height: FSizes.lg),

                // ── Title ──
                Text(
                  'otpTitle'.tr,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: FSizes.sm),

                // ── Subtitle + phone number ──
                Text(
                  _isSending ? 'otpSending'.tr : 'otpSentTo'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (maskedPhone != null) ...[
                  const SizedBox(height: FSizes.xs),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      maskedPhone,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: FSizes.xl + FSizes.sm),

                // ── OTP Input ──
                AnimatedOpacity(
                  opacity: _isSending ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AutofillGroup(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        length: 4,
                        controller: _pinController,
                        focusNode: _focusNode,
                        autofocus: true,
                        enabled: !_isSending,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        defaultPinTheme: _isSending
                            ? disabledPinTheme
                            : defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        keyboardType: TextInputType.number,
                        closeKeyboardWhenCompleted: false,
                        separatorBuilder: (_) => const SizedBox(width: 16),
                        onCompleted: _verify,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: FSizes.xl),

                if(_isSending)
                  const SizedBox(height: FSizes.xl)
                else
                  Countdown(
                    key: ValueKey(_timerKey),
                    seconds: 60,
                    build: (context, remaining) {
                      if (remaining == 0) {
                        return TextButton.icon(
                          onPressed: _resend,
                          icon: const Icon(Iconsax.refresh, size: 16),
                          label: Text('resendOTP'.tr),
                          style: TextButton.styleFrom(
                            foregroundColor: FColors.primaryColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return Text(
                        '${'resendIn'.tr} ${remaining.toInt()}${'secondsShort'.tr}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      );
                    },
                  ),

                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
