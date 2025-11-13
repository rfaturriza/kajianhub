import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/core/usecases/usecase.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';
import 'package:quranku/features/pray/domain/repositories/pray_repository.dart';

@injectable
class GetPrayersUsecase extends UseCase<List<Prayer>, GetPrayersParams> {
  final PrayRepository repository;

  GetPrayersUsecase(this.repository);

  @override
  Future<Either<Failure, List<Prayer>>> call(GetPrayersParams params) async {
    return await repository.getPrayers(
      query: params.query,
      page: params.page,
      limit: params.limit,
      orderBy: params.orderBy,
      sortBy: params.sortBy,
    );
  }
}

class GetPrayersParams extends Equatable {
  final String? query;
  final int page;
  final int limit;
  final String orderBy;
  final String sortBy;

  const GetPrayersParams({
    this.query,
    this.page = 1,
    this.limit = 12,
    this.orderBy = 'id',
    this.sortBy = 'asc',
  });

  @override
  List<Object?> get props => [query, page, limit, orderBy, sortBy];
}
