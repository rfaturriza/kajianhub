import 'package:dartz/dartz.dart';
import 'package:quranku/core/error/exceptions.dart';
import 'package:quranku/features/kajian/data/models/cities_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/kajian_schedule_request_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/kajian_schedule_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/kajian_schedules_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/kajian_themes_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/study_locations_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/provinces_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/prayer_kajian_schedule_request_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/prayer_kajian_schedules_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/ustadz_response_model.codegen.dart';

abstract class KajianHubRemoteDataSource {
  Future<Either<ServerException, KajianSchedulesResponseModel>>
      getKajianSchedules({
    required KajianScheduleRequestModel request,
  });

  Future<Either<ServerException, KajianScheduleResponseModel>>
      getKajianScheduleById({
    required String id,
    String? relations,
  });

  Future<Either<ServerException, PrayerKajianSchedulesByMosqueResponseModel>>
      getPrayerKajianSchedulesByMosque({
    required PrayerKajianScheduleByMosqueRequestModel request,
  });

  Future<Either<ServerException, PrayerKajianSchedulesResponseModel>>
      getPrayerSchedules({
    required PrayerKajianScheduleRequestModel request,
  });

  Future<Either<ServerException, UstadzResponseModel>> getUstadz({
    String? type,
    String? orderBy,
    String? sortBy,
  });

  Future<Either<ServerException, KajianThemesResponseModel>> getKajianThemes({
    String? type,
    String? orderBy,
    String? sortBy,
  });

  Future<Either<ServerException, StudyLocationResponseModel>> getMosques({
    String? type,
    String? orderBy,
    String? sortBy,
    String? relations,
  });

  Future<Either<ServerException, ProvincesResponseModel>> getProvinces({
    String? type,
    String? orderBy,
    String? sortBy,
    String? relations,
  });

  Future<Either<ServerException, CitiesResponseModel>> getCities({
    String? type,
    String? orderBy,
    String? sortBy,
    String? relations,
  });
}
