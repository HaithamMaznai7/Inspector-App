import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FAnimationLoaderWidget extends StatelessWidget {
  const FAnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPressed,
  });

  final String text;
  final String animation;
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FHelper.isDarkMode(Get.context!) ? FColors.dark : FColors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(animation, width: MediaQuery.of(context).size.width * .8),
            const SizedBox(height: FSizes.defaultSpace,),
            Text(
              text.tr,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.defaultSpace,),
            showAction
                ? SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: onActionPressed,
                style:  OutlinedButton.styleFrom(backgroundColor: FColors.dark),
                child: Text(
                  actionText!,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(color: FColors.light),
                ),
              ),
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
