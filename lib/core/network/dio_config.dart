import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_alice/alice.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/app.dart';

@injectable
class NetworkConfig {
  static final alice = Alice(
    navigatorKey: App.navigatorKey,
    showNotification: true,
    showInspectorOnShake: true,
  );

  static const baseUrlQuran = 'https://rizz-quran-api.vercel.app/';
  static const baseUrlShalat = 'https://api.myquran.com/';
  static const baseUrlKajianHub = 'https://kajianhub.com/api/';
  static const baseImageUrl = 'https://kajianhub.com/storage/images/';

  static final _baseOptions = BaseOptions(
    baseUrl: baseUrlQuran,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  static Dio getDio() {
    final dio = Dio(_baseOptions);
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ));
      dio.interceptors.add(alice.getDioInterceptor());
    }
    return dio;
  }

  static Dio getDioCustom(String baseUrl) {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ));
      dio.interceptors.add(alice.getDioInterceptor());
    }
    return dio;
  }
}
