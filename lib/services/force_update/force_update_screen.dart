import 'dart:io';

import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/common/styles/spacing_style.dart';
import 'package:fahis_inspector/services/force_update/force_update_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && Platform.isAndroid) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor:
            FHelper.isDarkMode(context) ? FColors.dark : FColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: FSpacingStyle.paddingWithAppBarHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ── Top: logo + text ──────────────────────────
                        Column(
                          children: [
                            Logo(height: FHelper.screenHeight() * 0.12),
                            const SizedBox(height: FSizes.spaceBtwSections),
                            Text(
                              FTexts.forceUpdateTitle.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: FSizes.spaceBtwItems),
                            Text(
                              FTexts.forceUpdateMessage.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: FColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // ── Bottom: button ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                ForceUpdateService.instance.openStore(),
                            child: Text(
                              FTexts.forceUpdateButton.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.apply(color: FColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
