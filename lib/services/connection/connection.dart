import 'dart:async';
import 'package:fahis_inspector/services/connection/connection_screen.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/popups/full_screen_loader.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionService extends GetxController {
  static ConnectionService get instance =>
      Get.find<ConnectionService>(tag: 'ConnectionService');

  late final InternetConnection _internetChecker;
  late final StreamSubscription<InternetStatus> _internetSub;

  RxBool isConnectionGood = false.obs;
  RxBool isLoading = false.obs;

  // Fires whenever connectivity transitions from offline → online.
  // Feature controllers subscribe to this to flush pending writes.
  final Rx<DateTime?> onReconnect = Rx<DateTime?>(null);

  // True once the user has been online at least once this session.
  // Used to decide whether to show the full-screen OfflineScreen (first boot)
  // or just the thin offline bar (already loaded cached data).
  bool _hasEverBeenOnline = false;
  bool get hasEverBeenOnline => _hasEverBeenOnline;

  @override
  void onInit() {
    super.onInit();
    _internetChecker = InternetConnection();
    _internetSub = _internetChecker.onStatusChange.listen(_onStatusChange);
  }

  /// Handles verified internet status changes from
  /// `internet_connection_checker_plus`. Unlike raw `connectivity_plus`,
  /// this stream only emits `connected` after real HTTP checks confirm
  /// the device can actually reach the internet.
  void _onStatusChange(InternetStatus status) {
    if (status == InternetStatus.disconnected) {
      AppLogger.info('[Offline]', 'internet: connected → disconnected');
      if (!_hasEverBeenOnline) {
        FFullScreenLoader.openPage(page: OfflineScreen());
      }
      isConnectionGood.value = false;
    } else {
      // InternetStatus.connected — verified via real HTTP checks
      FFullScreenLoader.stopLoading();
      final wasOffline = !isConnectionGood.value;
      isConnectionGood.value = true;
      _hasEverBeenOnline = true;
      if (wasOffline) {
        AppLogger.info(
          '[Offline]',
          'internet: disconnected → connected — flush starting',
        );
        onReconnect.value = DateTime.now();
      }
    }
  }

  /// Called by AppService.onResumed to trigger a flush when the app comes to
  /// the foreground while already connected (handles "backgrounded offline,
  /// resumed online" case).
  void triggerReconnectIfOnline() {
    if (isConnectionGood.value) {
      AppLogger.info('[Offline]', 'resume: already online — flush starting');
      onReconnect.value = DateTime.now();
    }
  }

  Future<bool> isConnected() async {
    try {
      return await _internetChecker.hasInternetAccess;
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

  void restartApp() {
    // Process.runSync('flutter', ['run']);
    // if (Process.runSync('flutter', ['doctor']).exitCode == 0) {
    //   // Restart the app
    // }
  }

  @override
  void onClose() {
    _internetSub.cancel();
    super.onClose();
  }
}
