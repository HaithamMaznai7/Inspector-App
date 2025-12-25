import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnError extends StatelessWidget {
  const OnError({super.key, this.message});

  final RxString? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Center(child: Text(HomePage.onError));
    } else {
      return Center(child: Text(message.toString()));
    }
  }
}
