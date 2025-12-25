import 'dart:async';
import 'package:fahis_inspector/features/inspections/models/inspection.dart';
import 'package:fahis_inspector/features/inspections/models/inspection_stages.dart';
import 'package:fahis_inspector/features/inspections/repository/repository.dart';
import 'package:fahis_inspector/services/authentication/auth.dart';
import 'package:fahis_inspector/services/authentication/models/team.dart';
import 'package:fahis_inspector/util/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static HomeController get instance => Get.find<HomeController>();

  late InspectionsRepository repository;
  late final Box box;
  final ScrollController scrollController = ScrollController();
  RxList<Inspection> inspections = <Inspection>[].obs;
  var isLoading = false.obs;

  final sideController = SideMenuController();
  Stream<List<Inspection>> get stream => inspections.stream;

  RxList<InspectionStage> statuses = RxList<InspectionStage>(
    InspectionStage.allStages,
  );

  var count = 0.obs;
  Rx<InspectionStage> selectedStatus = Rx<InspectionStage>(InspectionStage.all);

  @override
  void onInit() async {
    super.onInit();

    final userId = Auth.user?.id;
    if (userId == null) {
      Auth.logout();
      return;
    }

    box = await Hive.openBox("Inspections_User_$userId");

    repository = InspectionsRepository(box: box, status: selectedStatus.value);

    // 1. Show cached first
    inspections.assignAll(repository.fetchFromCache());

    // 2. Then refresh from API
    isLoading.value = inspections.isEmpty;
    try {
      inspections.assignAll(
        await repository.fetchFromApi(status: selectedStatus.value),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        repository.fetchNextPage().then((data) {
          inspections.assignAll(data); // update UI
        });
      }
    });
  }

  void changeStatus({InspectionStage newStatus = InspectionStage.all}) async {
    selectedStatus.value = newStatus;

    Get.back();

    // reinitialize repo with new status
    repository = InspectionsRepository(box: box, status: selectedStatus.value);

    // reload cached + api
    inspections.assignAll(repository.fetchFromCache());
    isLoading.value = inspections.length == 0;
    try {
      inspections.assignAll(await repository.fetchFromApi(status: newStatus));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await repository.fetchFromApi(status: selectedStatus.value);
  }

  void clearSearch() {
    
  }

  void openSearch() {
    Get.toNamed(RoutingUrl.search);
  }

  changeTeam(Team team) async {
    Get.back();
    try {
      await Auth.setTeam(team);
    } finally {
      repository.fetchFromApi();
      Get.back();
    }
  }
}
