import 'package:dartz/dartz.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';

abstract class PrayRepository {
  Future<Either<Failure, List<Prayer>>> getPrayers({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'asc',
  });

  Future<Either<Failure, Prayer>> getPrayerDetail(int id);
}
