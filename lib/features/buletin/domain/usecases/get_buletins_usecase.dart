import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';
import 'package:quranku/features/buletin/domain/repositories/buletin_repository.dart';

@injectable
class GetBuletinsUsecase {
  final BuletinRepository _repository;

  GetBuletinsUsecase(this._repository);

  Future<Either<Failure, List<Buletin>>> call({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'desc',
  }) {
    return _repository.getBuletins(
      query: query,
      page: page,
      limit: limit,
      orderBy: orderBy,
      sortBy: sortBy,
    );
  }
}
