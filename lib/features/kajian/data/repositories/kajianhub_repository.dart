import 'package:dartz/dartz.dart';
import 'package:quranku/features/kajian/data/models/study_locations_response_model.codegen.dart';
import 'package:quranku/features/kajian/data/models/prayer_kajian_schedules_response_model.codegen.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';
import 'package:quranku/features/kajian/domain/entities/prayer_kajian_schedules.codegen.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';

import '../../../../core/error/failures.dart';
import '../models/kajian_schedule_request_model.codegen.dart';
import '../models/prayer_kajian_schedule_request_model.codegen.dart';

abstract class KajianHubRepository {
  Future<Either<Failure, KajianSchedules>> getKajianList({
    required KajianScheduleRequestModel request,
  });

  Future<Either<Failure, DataKajianSchedule>> getKajianScheduleById({
    required String id,
    String? relations,
  });

  Future<Either<Failure, KajianSchedules>> getNearbyKajianList({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, DataPrayerKajianScheduleModel?>>
      getPrayerKajianSchedulesByMosque({
    required PrayerKajianScheduleByMosqueRequestModel request,
  });

  Future<Either<Failure, PrayerkajianSchedules>> getPrayerKajianSchedules({
    required PrayerKajianScheduleRequestModel request,
  });

  Future<Either<Failure, List<DataStudyLocationModel>>> getMosqueList({
    String? type,
    String? orderBy,
    String? sortBy,
  });

  Future<Either<Failure, List<Province>>> getProvincesList({
    String? type,
    String? orderBy,
    String? sortBy,
    String? relations,
  });

  Future<Either<Failure, List<City>>> getCitiesList({
    String? type,
    String? orderBy,
    String? sortBy,
    String? relations,
  });

  Future<Either<Failure, List<UstadzEntity>>> getUstadzList({
    String? type,
    String? orderBy,
    String? sortBy,
  });

  Future<Either<Failure, List<KajianTheme>>> getKajianThemesList({
    String? type,
    String? orderBy,
    String? sortBy,
  });
}
