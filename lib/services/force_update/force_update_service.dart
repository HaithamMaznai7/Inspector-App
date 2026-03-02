import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateService {
  ForceUpdateService._();

  static final ForceUpdateService instance = ForceUpdateService._();

  late final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  /// Initializes Remote Config and fetches values.
  /// Returns `true` if the app must be force-updated (i.e. current < min).
  /// Returns `false` on any error so the user is never blocked.

  // Duration.zero
  Future<bool> check() async {
    try {
      if (!_initialized) {
        _remoteConfig = FirebaseRemoteConfig.instance;
        await _remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: kDebugMode
                ? const Duration(seconds: 3600)
                : const Duration(seconds: 3600),
          ),
        );
        await _remoteConfig.setDefaults({
          'force_update_min_version': '0.0.0',
          'store_url_ios': '',
          'store_url_android': '',
          'update_message': '',
        });
        _initialized = true;
      }

      await _remoteConfig.fetchAndActivate();

      final minVersion = _remoteConfig.getString('force_update_min_version');
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      return _compareVersions(currentVersion, minVersion) < 0;
    } catch (e) {
      debugPrint('ForceUpdateService: check failed — $e');
      return false;
    }
  }

  /// Remote Config update message (may be empty).
  String get updateMessage =>
      _initialized ? _remoteConfig.getString('update_message') : '';

  /// Opens the appropriate store URL for the current platform.
  Future<void> openStore() async {
    if (!_initialized) return;
    final url = Platform.isIOS
        ? _remoteConfig.getString('store_url_ios')
        : _remoteConfig.getString('store_url_android');
    if (url.isNotEmpty) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Semantic version comparison.
  /// Returns negative if [a] < [b], 0 if equal, positive if [a] > [b].
  static int _compareVersions(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final length = partsA.length > partsB.length
        ? partsA.length
        : partsB.length;
    for (var i = 0; i < length; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}
