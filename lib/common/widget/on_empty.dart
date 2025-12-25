import 'package:fahis_inspector/util/constants/image_strings.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnEmptyWithBtn extends StatelessWidget {
  final void fun;
  const OnEmptyWithBtn({super.key, this.fun});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          children:[
            const SizedBox(height: 100,),
            Image.asset(FImages.onEmpty),
            const SizedBox(height: 20,),
            Text(HomePage.onEmpty.tr,style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: () => fun, child: Text(FTexts.refresh.tr,style: Theme.of(context).textTheme.titleLarge,)),
          ]),
    );
  }
}

class OnEmpty extends StatelessWidget {
  const OnEmpty({super.key, this.title = FImages.onEmpty});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
            children:[
              const SizedBox(height: 100,),
              Image.asset(FImages.onEmpty),
              const SizedBox(height: 20,),
              Text(title.tr,style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20,),
            ]),
      ),
    );
  }
}
