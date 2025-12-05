import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/network/dio_config.dart';
import 'package:quranku/features/kajian/data/models/cities_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/kajian_schedule_request_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/kajian_schedules_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/kajian_themes_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/study_locations_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/provinces_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/prayer_kajian_schedules_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/ustadz_response_model.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../../core/error/exceptions.dart';
import '../../models/kajian_schedule_response_model.codegen.dart';
import '../../models/prayer_kajian_schedule_request_model.codegen.dart';
import 'kajianhub_remote_data_source.dart';

@LazySingleton(as: KajianHubRemoteDataSource)
class KajianHubRemoteDataSourceImpl implements KajianHubRemoteDataSource {
  final Dio _dio;

  KajianHubRemoteDataSourceImpl()
      : _dio = NetworkConfig.getDioCustom(
          NetworkConfig.baseUrlKajianHub,
        );

  @override
  Future<Either<ServerException, KajianSchedulesResponseModel>>
      getKajianSchedules({
    required KajianScheduleRequestModel request,
  }) async {
    const endpoint = 'mobile/kajian/schedules';
    try {
      final queryParameters = request.toJson();
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final data = response.data;
      return right(KajianSchedulesResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(ServerException(
        Exception(LocaleKeys.defaultErrorMessage.tr()),
      ));
    }
  }

  @override
  Future<Either<ServerException, KajianScheduleResponseModel>>
      getKajianScheduleById({
    required String id,
    String? relations,
  }) async {
    final endpoint = 'kajian/schedules/$id';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'relations': relations ??
              'ustadz,studyLocation.province,studyLocation.city,dailySchedules,customSchedules,themes',
        },
      );

      final data = response.data;
      return right(KajianScheduleResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }

  @override
  Future<Either<ServerException, CitiesResponseModel>> getCities({
    String? type = 'collection',
    String? orderBy = 'name',
    String? sortBy = 'asc',
    String? relations = 'province',
  }) async {
    const endpoint = 'public/cities';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'type': type ?? 'collection',
          'order_by': orderBy ?? 'name',
          'sort_by': sortBy ?? 'asc',
          'relations': relations ?? 'province',
        },
      );

      final data = response.data;
      return right(CitiesResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }

  @override
  Future<Either<ServerException, KajianThemesResponseModel>> getKajianThemes({
    String? type = 'collection',
    String? orderBy = 'name',
    String? sortBy = 'asc',
  }) async {
    const endpoint = 'kajian/themes';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'type': type ?? 'collection',
          'order_by': orderBy ?? 'name',
          'sort_by': sortBy ?? 'asc',
        },
      );

      final data = response.data;
      return right(KajianThemesResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }

  @override
  Future<Either<ServerException, StudyLocationResponseModel>> getMosques({
    String? type = 'collection',
    String? orderBy = 'name',
    String? sortBy = 'asc',
    String? relations = 'province,city',
  }) async {
    const endpoint = 'kajian/study-locations';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'type': type ?? 'collection',
          'order_by': orderBy ?? 'name',
          'sort_by': sortBy ?? 'asc',
          'relations': relations ?? 'province,city',
        },
      );

      final data = response.data;
      return right(StudyLocationResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }

  @override
  Future<Either<ServerException, ProvincesResponseModel>> getProvinces({
    String? type = 'collection',
    String? orderBy = 'name',
    String? sortBy = 'asc',
    String? relations = 'cities',
  }) async {
    const endpoint = 'public/provinces';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'type': type ?? 'collection',
          'order_by': orderBy ?? 'name',
          'sort_by': sortBy ?? 'asc',
          'relations': relations ?? 'cities',
        },
      );

      final data = response.data;
      return right(ProvincesResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }

  @override
  Future<Either<ServerException, PrayerKajianSchedulesByMosqueResponseModel>>
      getPrayerKajianSchedulesByMosque({
    required PrayerKajianScheduleByMosqueRequestModel request,
  }) async {
    const endpoint = 'kajian/prayer-schedules/ramadhan';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: request.toJson(),
      );

      final data = response.data;
      return right(PrayerKajianSchedulesByMosqueResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }

  @override
  Future<Either<ServerException, UstadzResponseModel>> getUstadz({
    String? type = 'collection',
    String? orderBy = 'name',
    String? sortBy = 'asc',
  }) async {
    const endpoint = 'kajian/ustadz';
    try {
      _dio.options.receiveTimeout = const Duration(seconds: 10);
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'type': type ?? 'collection',
          'order_by': orderBy ?? 'name',
          'sort_by': sortBy
        },
      );

      final data = response.data;
      return right(UstadzResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }

  @override
  Future<Either<ServerException, PrayerKajianSchedulesResponseModel>>
      getPrayerSchedules({
    required PrayerKajianScheduleRequestModel request,
  }) async {
    const endpoint = 'kajian/prayer-schedules';
    try {
      final queryParameters = request.copyWith(
        options: [...request.options ?? []],
      ).toJson();
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final data = response.data;
      return right(PrayerKajianSchedulesResponseModel.fromJson(data));
    } on Exception catch (e) {
      return left(ServerException(e));
    } catch (e) {
      return left(
        ServerException(Exception(LocaleKeys.defaultErrorMessage.tr())),
      );
    }
  }
}
