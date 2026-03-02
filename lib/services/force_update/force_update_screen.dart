import 'dart:io';

import 'package:fahis_inspector/common/widgets/app/logo.dart';
import 'package:fahis_inspector/services/force_update/force_update_service.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
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
        if (!didPop) {
          // Android back button → exit the app entirely
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // App logo
                const Logo(height: FSizes.logoHeightLg),
                const SizedBox(height: 40),

                // Title
                Text(
                  FTexts.forceUpdateTitle.tr,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message — prefer Remote Config value, fall back to localized
                Text(
                  _getMessage(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: FColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 3),

                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => ForceUpdateService.instance.openStore(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      FTexts.forceUpdateButton.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMessage() {
    final remoteMessage = ForceUpdateService.instance.updateMessage;
    if (remoteMessage.isNotEmpty) return remoteMessage;
    return FTexts.forceUpdateMessage.tr;
  }
}
