import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fahis_inspector/common/widgets/loaders/loaders.dart';
import 'package:fahis_inspector/util/helpers/logger.dart';
import 'package:fahis_inspector/util/popups/full_screen_loader.dart';
import 'package:get/get.dart';

class ConnectionService extends GetxController {
  static ConnectionService get instance =>
      Get.find<ConnectionService>(tag: 'ConnectionService');

  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  RxBool isConnectionGood = false.obs;
  RxBool isLoading = false.obs;

  // Fires whenever connectivity transitions from offline → online.
  // Feature controllers subscribe to this to flush pending writes.
  final Rx<DateTime?> onReconnect = Rx<DateTime?>(null);

  // True once the user has been online at least once this session.
  // Exposed so call-sites can differentiate "never connected" from
  // "was online, then dropped" when needed.
  bool _hasEverBeenOnline = false;
  bool get hasEverBeenOnline => _hasEverBeenOnline;

  // The very first _applyStatus call is the boot-time seed from
  // checkConnectivity(), not a real adapter transition. We must not treat it
  // as offline → online (which would flash the "Back online" snackbar and
  // trigger every feature's flush worker on every cold boot / hot restart).
  bool _hasAppliedInitialStatus = false;

  // Guards stopLoading() so it only calls Get.back() when we actually
  // opened a full-screen loader — prevents accidentally popping routes.
  bool _offlineDialogOpen = false;

  @override
  void onInit() {
    super.onInit();

    // Seed initial state so the first consumer sees the correct value
    // instead of the default `false`.
    _connectivity.checkConnectivity().then((results) {
      _applyStatus(_isOnline(results));
    });

    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      _applyStatus(_isOnline(results));
    });
  }

  /// Online = any reported interface other than `none`.
  /// `wifi`, `mobile`, `ethernet`, `vpn`, `bluetooth`, `other` all count.
  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Handles OS-reported adapter state changes from `connectivity_plus`.
  /// This is a passive, event-driven signal — no HTTP polling. When the
  /// adapter reports "connected" we trust the OS; if the internet is
  /// actually broken (captive portal, ISP outage), the next API call will
  /// fail and the pending-write system handles retry on subsequent events.
  void _applyStatus(bool online) {
    // First emission is the seeded boot value, not a real transition.
    // Apply state silently so we don't fire onReconnect / show the
    // "Back online" snackbar / kick every feature's flush worker on a
    // cold boot or hot restart that started already-online.
    if (!_hasAppliedInitialStatus) {
      _hasAppliedInitialStatus = true;
      isConnectionGood.value = online;
      if (online) _hasEverBeenOnline = true;
      AppLogger.info(
        '[STATE]',
        'adapter: initial state → ${online ? 'online' : 'offline'}',
      );
      return;
    }

    if (!online) {
      AppLogger.info('[STATE]', 'adapter: connected → disconnected');
      // Never auto-open the full-screen OfflineScreen on cold boot.
      // The persistent OfflineStatusBar gives the user the connectivity
      // signal while cached home content remains accessible.
      isConnectionGood.value = false;
    } else {
      // Only dismiss the dialog if we actually opened one. Without this
      // guard, Get.back() pops the current route instead of a dialog.
      if (_offlineDialogOpen) {
        FFullScreenLoader.stopLoading();
        _offlineDialogOpen = false;
      }
      final wasOffline = !isConnectionGood.value;
      isConnectionGood.value = true;
      _hasEverBeenOnline = true;
      if (wasOffline) {
        AppLogger.info(
          '[Offline]',
          'adapter: disconnected → connected — flush starting',
        );
        onReconnect.value = DateTime.now();
        FLoader.infoSnackBar(
          title: 'back_online_title'.tr,
          message: 'back_online_message'.tr,
        );
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
      final results = await _connectivity.checkConnectivity();
      return _isOnline(results);
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
    _connectivitySub.cancel();
    super.onClose();
  }
}
