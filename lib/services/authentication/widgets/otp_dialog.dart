import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
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

class _OTPDialogState extends State<OTPDialog> {
  String _code = '';

  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return Dialog(
      child: Container(
        height: FDeviceUtils.getScreenHeight() * .4,
        width: FDeviceUtils.getScreenWidth() * .6,
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Spacer(), // pushes content to vertical center
            Text(
              'Enter OTP',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(color: FColors.primaryColor),
            ),

            /// ================= Centered Input & Text Buttons =================
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PinFieldAutoFill(
                  textInputAction: TextInputAction.done,
                  codeLength: 4,
                  autoFocus: true,
                  decoration: BoxLooseDecoration(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: FColors.primaryColor,
                    ),
                    strokeColorBuilder: FixedColorBuilder(
                      isDark ? FColors.white : FColors.primaryColor,
                    ),
                    bgColorBuilder: FixedColorBuilder(
                      FColors.grey.withOpacity(.2),
                    ),
                    strokeWidth: 1,
                  ),
                  onCodeSubmitted: _verify,
                  controller: _otpController,
                  currentCode: _code,
                  onCodeChanged: _verify,
                ),
                const SizedBox(height: FSizes.lg),

                /// ================= Bottom Login Button =================
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: FColors.primaryColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(FSizes.borderRadiusMd),
                            bottomRight: Radius.circular(FSizes.borderRadiusMd),
                          ),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: _check,
                            icon: Icon(
                              Iconsax.arrow_right_3,
                              color: FColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: FSizes.sm),

                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: FColors.lightGrey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(FSizes.borderRadiusMd),
                          bottomLeft: Radius.circular(FSizes.borderRadiusMd),
                        ),
                      ),
                      child: Center(
                        child: Countdown(
                          seconds: 60,
                          // interval: const Duration(seconds: 60),
                          build: (context, currentRemainingTime) {
                            if (currentRemainingTime == .0) {
                              return IconButton(
                                onPressed: _resent,
                                icon: Icon(
                                  Iconsax.redo,
                                  color: FColors.primaryColor,
                                ),
                              );
                            } else {
                              return Text(
                                currentRemainingTime.toString(),
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(color: FColors.primaryColor),
                                textAlign: TextAlign.center,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: isDark ? FColors.dark : FColors.white,
    );
  }

  _verify(String? code) async {
    if (code != null && code.length == 4) {
      Get.back(result: {'action': 'verify', 'code': code});
    }
  }

  _resent() {
    Get.back(result: {'action': 'resent'});
  }

  _check() async {
    _code = _otpController.text.trim();
    _verify(_code);
  }
}
