import 'package:fahis_inspector/features/authentication/controllers/login_controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageToggleBtn extends GetView<LoginController> {
  const PageToggleBtn({super.key, required this.btnTitle, required this.onPressed});
  final String btnTitle ;
  final void Function()? onPressed ;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child:  OutlinedButton(
          onPressed: onPressed ,
          child: Text(
              btnTitle,
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                  color: FColors.primaryColor
              )
          )
      )
  );
}