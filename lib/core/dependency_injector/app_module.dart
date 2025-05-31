import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hive_ce/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/network/dio_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  @injectable
  Dio get dioConfig => NetworkConfig.getDio();

  @injectable
  AudioPlayer get audioPlayer => AudioPlayer(playerId: "VersePlayer");

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @injectable
  InAppPurchase get inAppPurchase => InAppPurchase.instance;

  @injectable
  HiveInterface get hive => Hive;

  @injectable
  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  @injectable
  FirebaseAnalytics get firebaseAnalytics => FirebaseAnalytics.instance;
}
