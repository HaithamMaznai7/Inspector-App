import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FNotification {

  final String id;
  final String title;
  final String description;
  final String type;
  final String audio;
  final String icon;
  final String actionBtn;
  final String url;

  FNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.audio,
    required this.icon,
    required this.actionBtn,
    required this.url,
  });

  factory FNotification.fromData(Map map){
    return FNotification(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      audio: map['audio'],
      icon: map['icon'],
      actionBtn: map['actionBtn'],
      url: map['url'],
    );
  }

  notify() {
    Get.snackbar(
      title,
      description,
      isDismissible: true,
      shouldIconPulse: true,
      titleText: null,
      messageText: null,
      margin: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.sm),
      borderRadius: FSizes.borderRadiusSm,
      colorText: FColors.dark,
      backgroundColor: FColors.light,
      snackPosition:  SnackPosition.TOP,
      duration: Duration(seconds: 5),
      icon: Icon(Iconsax.notification)
    );
    Get.dialog(
      Dialog(
        backgroundColor: FColors.lightGrey,
        child: Container(
          width: FDeviceUtils.getScreenWidth() * .8,
          height: FDeviceUtils.getScreenHeight() * .6,
          child: Column(
            children: [
              Header(

              ),

              Body(

              ),

              Footer(
                children: [
                  SizedBox(),
                ]
              )
            ],
          ),
        ),
      ),
      // name: 'Hello',
      useSafeArea: true,
      barrierDismissible: true,
      // transitionDuration: Duration(seconds: 3)
    );
  }
}


class Header extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox();
  }
}
class Body extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox();
  }
}
class Footer extends StatelessWidget{
  final List<Widget> children;
  const Footer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox();
  }
}