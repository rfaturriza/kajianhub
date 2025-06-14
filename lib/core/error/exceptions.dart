import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quranku/generated/locale_keys.g.dart';

class ServerException implements Exception {
  final Exception _exception;

  ServerException(Exception exception) : _exception = exception;

  String get message {
    if (_exception is DioException) {
      return _dioMessage;
    } else if (_exception is SocketException) {
      return LocaleKeys.noInternetConnection.tr();
    } else {
      return LocaleKeys.unknownErrorException.tr();
    }
  }

  String get _dioMessage {
    switch ((_exception as DioException).type) {
      case DioExceptionType.connectionTimeout:
        return LocaleKeys.connectionTimeoutException.tr();
      case DioExceptionType.sendTimeout:
        return LocaleKeys.sendTimeoutException.tr();
      case DioExceptionType.receiveTimeout:
        return LocaleKeys.receiveTimeoutException.tr();
      case DioExceptionType.badResponse:
        return LocaleKeys.badResponseException.tr();
      case DioExceptionType.cancel:
        return LocaleKeys.cancelException.tr();
      case DioExceptionType.badCertificate:
        return LocaleKeys.badCertificateException.tr();
      case DioExceptionType.connectionError:
        return LocaleKeys.noInternetConnection.tr();
      default:
        return LocaleKeys.unknownErrorException.tr();
    }
  }

  @override
  String toString() {
    return message;
  }
}

class CacheException implements Exception {}
