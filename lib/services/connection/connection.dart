import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fahis_inspector/services/connection/connection_screen.dart';
import 'package:fahis_inspector/util/popups/full_screen_loader.dart';
import 'package:get/get.dart';

class ConnectionService extends GetxController {
  static ConnectionService get instance =>
      Get.find<ConnectionService>(tag: 'ConnectionService');

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<List<ConnectivityResult>> _connectivityStatus = Rx([
    ConnectivityResult.none,
  ]);
  RxBool isConnectionGood = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectivityStatus.value = result;
    if (_connectivityStatus.value.first == ConnectivityResult.none) {
      FFullScreenLoader.openPage(page: OfflineScreen());
      isConnectionGood.value = false;
    } else if (_connectivityStatus.value.first == ConnectivityResult.wifi ||
        _connectivityStatus.value.first == ConnectivityResult.mobile ||
        _connectivityStatus.value.first == ConnectivityResult.vpn) {
      FFullScreenLoader.stopLoading();
      isConnectionGood.value = true;
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.first == ConnectivityResult.none) {
        return false;
      } else if (result.first == ConnectivityResult.wifi ||
          result.first == ConnectivityResult.mobile ||
          result.first == ConnectivityResult.vpn) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> reload() async {
    isLoading = true.obs;
    update();
    if (await isConnected()) {
      Get.offNamed(Get.previousRoute);
    } else {
      Future.delayed(const Duration(seconds: 2)).then((value) {
        isLoading.value = false;
        update();
      });
    }
  }

  // continueOffline()async {
  //   // await NetworkHelper.offlineMood();
  //   // if (fStorage.read(StorageKey.enableOfflineMode)) {
  //   //   fStorage.write(StorageKey.offlineMode, true);
  //   //   Get.offNamed(Get.parameters['route']!);
  //   // }
  // }

  void restartApp() {
    // Process.runSync('flutter', ['run']);
    // if (Process.runSync('flutter', ['doctor']).exitCode == 0) {
    //   // Restart the app
    // }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
