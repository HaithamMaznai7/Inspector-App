import 'package:fahis_inspector/services/connection/connection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    Get.put<ConnectionService>(ConnectionService(), permanent: true);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
    print('AppController onReady'); // runs after widget build
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        print('App inactive');
        break;
      case AppLifecycleState.detached:
        print('App detached');
        break;
      case AppLifecycleState.hidden:
        print('App hidden');
        break;
      case AppLifecycleState.resumed:
        print('App resumed');
        doSomethingOnResume();
        break;
      case AppLifecycleState.paused:
        print('App paused');
        doSomethingOnPause();
        break;
    }
  }

  void doSomethingOnResume() {
    // Fetch or refresh data
  }

  void doSomethingOnPause() {
    // Save data, pause tasks, etc.
  }
}
