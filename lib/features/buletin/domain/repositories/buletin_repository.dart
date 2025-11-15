import 'package:dartz/dartz.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';

abstract class BuletinRepository {
  Future<Either<Failure, List<Buletin>>> getBuletins({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'desc',
  });

  Future<Either<Failure, Buletin>> getBuletinDetail(int id);
}
