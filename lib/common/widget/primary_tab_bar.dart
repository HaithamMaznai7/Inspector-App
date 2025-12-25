/*
import 'package:fahis_inspector/features/requests/controllers/home_controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrimaryTabBar extends StatelessWidget{

  final List<Tab> tabs;
  const PrimaryTabBar({super.key,required this.tabs});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final HomeController controller = Get.find<HomeController>();

    return Container(
      width: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: FColors.primaryColor.withOpacity(.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: GetBuilder<HomeController>(
              builder: (_){
                return TabBar(
                    unselectedLabelColor: FColors.primaryColor,
                    labelColor: Colors.white,
                    unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
                    labelStyle: Theme.of(context).textTheme.labelLarge ,
                    indicatorColor: Colors.white,
                    indicatorWeight: 5,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: FColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    controller: controller.tabController,
                    tabs: tabs,
                );
              },
            ),
          )
        ],
      ),
    );
  }

}*/
