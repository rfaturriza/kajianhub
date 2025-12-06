import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/pray/data/dataSources/pray_remote_data_source.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';
import 'package:quranku/features/pray/domain/repositories/pray_repository.dart';

@LazySingleton(as: PrayRepository)
class PrayRepositoryImpl implements PrayRepository {
  final PrayRemoteDataSource remoteDataSource;

  PrayRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Prayer>>> getPrayers({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'asc',
  }) async {
    try {
      final result = await remoteDataSource.getPrayers(
        query: query,
        page: page,
        limit: limit,
        orderBy: orderBy,
        sortBy: sortBy,
      );
      return Right(result.data?.map((model) => model.toEntity()).toList() ?? []);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Prayer>> getPrayerDetail(int id) async {
    try {
      final result = await remoteDataSource.getPrayerDetail(id);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
