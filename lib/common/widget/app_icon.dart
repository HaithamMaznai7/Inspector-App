import 'package:fahis_inspector/util/constants/image_strings.dart';
import 'package:flutter/cupertino.dart';

class AppIcon extends StatelessWidget{
  const AppIcon({super.key,this.width,this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context){

    return Image.asset(
      FImages.appIcon,
      width: width,
      height: height,
    );
  }
}