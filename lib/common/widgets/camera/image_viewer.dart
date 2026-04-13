import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:fahis_inspector/util/constants/image_strings.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key,
      this.image,
      this.height = 100,
      this.width = 100,
      this.placeHolder});

  final String? image;
  final double height;
  final double width;
  final Widget? placeHolder;
  final Widget defaultPlaceHolder =
    const Icon(Icons.camera_alt, size: FSizes.iconCircleMd, color: Colors.grey);
  @override
  Widget build(BuildContext context) {
    if(image == null){
      if (placeHolder == null) {
        return EasyImageView(
          imageProvider: Image.asset(
            FImages.appIcon,
            fit: BoxFit.cover,
            width: double.infinity, 
            height: double.infinity,
          ).image
        );
      }
      else{
        return placeHolder!;
      }
    }
    else{ 
      if (image!.startsWith('https://') || image!.startsWith('http://')){
        return EasyImageView(
          imageProvider: CachedNetworkImageProvider(image!),
        );
      }
      else if (image!.startsWith('//s3')){
        return EasyImageView(
          imageProvider: CachedNetworkImageProvider('https:${image!}'),
        );
      }
      else{
        return EasyImageView(
          imageProvider: Image.memory(
            base64Decode(Helpers.base64FromValid(image!)[0]),
            fit: BoxFit.contain,
            width: double.infinity, 
            height: double.infinity,
          ).image
        );
      }
    }
  
  }
}
