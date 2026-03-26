import 'dart:io';

import 'package:fahis_inspector/util/constants/api_endpoints.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateService {
  ForceUpdateService._();

  static final ForceUpdateService instance = ForceUpdateService._();

  late final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  Future<bool> check() async {
    try {
      if (!_initialized) {
        _remoteConfig = FirebaseRemoteConfig.instance;
        await _remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(seconds: 3600),
        ));
        await _remoteConfig.setDefaults({
          'force_update_min_version': '0.0.0',
          'store_url_ios': '',
          'store_url_android': '',
          'api_domain': EndPoints.domain,
        });
        _initialized = true;
      }

      await _remoteConfig.fetchAndActivate();
      ApiConfig.init(_remoteConfig.getString('api_domain'));

      final minVersion = _remoteConfig.getString('force_update_min_version');
      final packageInfo = await PackageInfo.fromPlatform();

      return _compareVersions(packageInfo.version, minVersion) < 0;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

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

    final length =
        partsA.length > partsB.length ? partsA.length : partsB.length;
    for (var i = 0; i < length; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}
