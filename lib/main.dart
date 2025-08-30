import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:quranku/features/config/remote_config.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app.dart';
import 'core/constants/admob_constants.dart';
import 'core/utils/bloc_observe.dart';
import 'core/utils/firebase_cloud_message.dart';
import 'core/utils/local_notification.dart';
import 'firebase_options_debug.dart' as firebase_debug;
import 'firebase_options.dart' as firebase_release;
import 'hive_adapter_register.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.ensureInitialized();
  MobileAds.instance.initialize();

  await Hive.initFlutter();
  await registerHiveAdapter();
  await configureDependencies();
  await dotenv.load(fileName: ".env");
  if (kReleaseMode) {
    await Firebase.initializeApp(
      options: firebase_release.DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: kDebugMode ? AdMobConst.testDevice : [],
      ),
    );
    await Firebase.initializeApp(
      options: firebase_debug.DefaultFirebaseOptions.currentPlatform,
    );
  }
  // Initialize remote config and FCM without blocking app startup
  // These services will work in background and handle failures gracefully
  sl<RemoteConfigService>().initialize().catchError((e) {
    if (kDebugMode) {
      print('Remote config initialization failed: $e');
    }
  });

  /// iOS skip this step because it's need Account in Apple Developer
  /// iOS also need to upload key to firebase
  initializeFCM().catchError((e) {
    if (kDebugMode) {
      print('FCM initialization failed: $e');
    }
  });
  await sl<LocalNotification>().init();

  timeago.setLocaleMessages('id', timeago.IdMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: const App(),
    ),
  );
}
