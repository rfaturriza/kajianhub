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
  debugPrint('🔹 Before ensureInitialized');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🔹 After WidgetsFlutterBinding.ensureInitialized');

  EasyLocalization.ensureInitialized();
  debugPrint('🔹 After EasyLocalization.ensureInitialized');

  MobileAds.instance.initialize();
  debugPrint('🔹 MobileAds ensureInitialized');

  await Hive.initFlutter();
  debugPrint('🔹 After Hive.ensureInitialized');

  await registerHiveAdapter();
  debugPrint('🔹 After registerHiveAdapter.ensureInitialized');

  await configureDependencies();
  debugPrint('🔹 After configureDependencies.ensureInitialized');

  await dotenv.load(fileName: ".env");
  debugPrint('🔹 After dotenv.load.ensureInitialized');

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
    debugPrint('🔹 After  MobileAds.instance.ensureInitialized');

    await Firebase.initializeApp(
      options: firebase_debug.DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔹 After  Firebase.initializeApp.ensureInitialized');
  }
  await sl<RemoteConfigService>().initialize();
  debugPrint('🔹 After EasyLocalization.ensureInitialized');

  /// iOS skip this step because it's need Account in Apple Developer
  /// iOS also need to upload key to firebase
  await initializeFCM();
  await sl<LocalNotification>().init();
  debugPrint('🔹 After EasyLocalization.ensureInitialized');

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
  debugPrint('🔹 runApp() called');
}
