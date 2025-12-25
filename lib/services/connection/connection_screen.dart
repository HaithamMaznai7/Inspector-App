import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ListView(
                children: [
                  SizedBox(height: FDeviceUtils.getAppBarHeight()* .5,),
                  const SizedBox(height: FSizes.spaceBtwSections ,),
                  Text('network_connection'.tr,style: Theme.of(context).textTheme.headlineMedium,textAlign: TextAlign.center,),
                  const SizedBox(height: FSizes.spaceBtwItems ,),
                  Lottie.asset(
                    'assets/animations/disconnected_animation.json',
                    height: 300,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems ,),
                  Text('disconnected_message'.tr,style: Theme.of(context).textTheme.headlineSmall,textAlign: TextAlign.center,),
                  const SizedBox(height: FSizes.spaceBtwSections ,),
                  GetBuilder<ConnectionService>(builder: (controller){
                    return SizedBox(height: 60, width: double.infinity , child: ElevatedButton(onPressed: controller.reload, child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: FColors.white,)
                        : const Text('Reload'),
                    ));
                    /// return Buttons().progresBtn(controller.isLoading.value, () => controller.reload(),'Reload');
                  }),
                  // const SizedBox(height: FSizes.spaceBtwItems,),
                  // fStorage.read<bool>(StorageKey.enableOfflineMode) == true
                  //     ? SizedBox(height: 60, width: double.infinity , child: ElevatedButton(
                  //   onPressed: NetworkManager.instance.continueOffline,
                  //   child: Text('Continue with offline'.tr),
                  // ))
                  //     : const SizedBox(),
                ],
            )
          ),
        ),
      ),
    );
  }
}
