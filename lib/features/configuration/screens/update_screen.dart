import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 60,horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('there_update'.tr,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 28
                ),textAlign: TextAlign.center,),
                const SizedBox(height: 20,),
                // Lottie.asset(
                //   'assets/animations/update_animation.json',
                //   height: 300,
                // ),
                Text('update_message'.trParams({
                  // 'newVer': "${appConfig!.lastVersion}",
                  'isShould': Get.parameters['isShould'] == 'true' ? 'have_to'.tr : 'can'.tr
                }),style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Tajawal'
                ),textAlign: TextAlign.center,),
                InkWell(
                  onTap: () async {
                    // final url = Uri.parse(appConfig!.appUrl);
                    // //final url = Uri.parse(sharePref.getString('updateAppUrl')!);
                    // if (!await launchUrl(url)) {
                    // throw Exception('Could not launch $url');
                    // }
                  },
                  child: Container(
                    width: Get.mediaQuery.size.width * .6,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF56969), Color(0xFFFF7D41)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Update'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Get.parameters['isShould'] == 'true' ? const SizedBox() : ElevatedButton(
                  onPressed: () {
                    Get.offNamed(RoutingUrl.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Color(0xFFFF7D41),
                        width: 229,
                      ),
                    ),
                  ),
                  child: Container(
                    width: Get.mediaQuery.size.width * .6,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Skip'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}