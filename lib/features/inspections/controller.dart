import 'dart:async';
import 'package:fahis_inspector/main.dart';
import 'package:fahis_inspector/models/inspection.dart';
import 'package:fahis_inspector/enums/inspection_stages.dart';
import 'package:fahis_inspector/resources/inspection_repository.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/device/device_utility.dart';
import 'package:fahis_inspector/util/http/network_exception.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InspectionsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late InspectionsRepository repository;
  late final Box<Map> box;
  final ScrollController scrollController = ScrollController();
  RxList<Inspection> inspections = <Inspection>[].obs;
  var isLoading = true.obs;

  Stream<List<Inspection>> get stream => inspections.stream;

  RxList<InspectionStage> stages = RxList<InspectionStage>(
    InspectionStage.allStages,
  );

  var count = 0.obs;
  Rx<InspectionStage> selectedStage = Rx<InspectionStage>(InspectionStage.all);

  @override
  void onInit() async {
    super.onInit();

    box = await Hive.openBox<Map>("Inspections_User_${auth().user?.uid}");

    repository = InspectionsRepository(box: box, stage: selectedStage.value);

    await load(
      load: inspections.isEmpty,
      stage: selectedStage.value,
    );
  }

  @override
  void onReady() {
    super.onReady();

    inspections.listen((inspections) {
      update();
    });

    // Listen to route param changes
    // load(load: inspections.isEmpty, stage: selectedStage.value);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        repository.fetchNextPage().then((data) {
          inspections.assignAll(data); // update UI
        });
      }
    });
  }

  void changeStatus({InspectionStage newStage = InspectionStage.all}) async {
    selectedStage.value = newStage;

    await load(reset: true, stage: newStage);

    Get.back();
  }

  Future<void> load({
    String? query,
    InspectionStage? stage,
    bool reset = false,
    bool load = true,
    bool cache = true,
  }) async {
    // reload cached + api
    stage ??= selectedStage.value;

    if (cache) {
      inspections.assignAll(repository.fetchFromCache(stage: stage));
      update();
      if (load) {
        isLoading.value = inspections.isEmpty;
        update();
      }
    }

    try {
      while (auth().token == null) {
        await Future.delayed(Duration(seconds: 3));
      }

      inspections.assignAll(
        await repository.fetchFromApi(query: query, stage: stage, reset: reset),
      );
    } finally {
      if (load) {
        isLoading.value = false;
        update();
      }
    }
  }

  Future<void> refreshPage() async {
    if (await FDeviceUtils.hasInternetConnection()) {
      inspections.value = [];
      isLoading.value = true;
      await load(reset: true, cache: false);
    }
  }

  Future<void> openInspection(Inspection inspection) async {
    try {
      await Get.toNamed(
        '${RoutingUrl.inspections}/${inspection.slug}',
        arguments: inspection,
      );
      // Refresh list when returning from details so stage labels are up to date
      load(reset: true);
    } on FNetworkException catch (e) {
      e.notify();
    } catch (e) {
      dd(e.toString());
    }
  }
}
