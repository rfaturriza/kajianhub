import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'data/model/menu_config_model.dart';

@lazySingleton
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({required FirebaseRemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 10)
              : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        debugPrint('Remote config updated: ${event.updatedKeys.join(',')}');
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print(
          'Unable to fetch remote config. Cached or default values will be used',
        );
      }
      if (kDebugMode) {
        print(e);
      }
    }
  }

  get webViewDonationUrl => _remoteConfig.getString('webview_donation_url');
  get imageRandomUrl => _remoteConfig.getString('image_random_url');
  get saweriaUrl => _remoteConfig.getString('saweria_url');
  get githubUrl => _remoteConfig.getString('github_url');
  MenusConfig get menuConfigs {
    final rawJson = _remoteConfig.getString('menu_config');
    if (rawJson.isEmpty) {
      return MenusConfig({});
    }
    final parsed = jsonDecode(rawJson);
    return MenusConfig.fromJson(parsed as Map<String, dynamic>);
  }
}
