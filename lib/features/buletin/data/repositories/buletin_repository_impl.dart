import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/buletin/data/datasources/buletin_remote_data_source.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';
import 'package:quranku/features/buletin/domain/repositories/buletin_repository.dart';

@LazySingleton(as: BuletinRepository)
class BuletinRepositoryImpl implements BuletinRepository {
  final BuletinRemoteDataSource _remoteDataSource;

  BuletinRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Buletin>>> getBuletins({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'desc',
  }) async {
    final result = await _remoteDataSource.getBuletins(
      query: query,
      page: page,
      limit: limit,
      orderBy: orderBy,
      sortBy: sortBy,
    );

    return result.fold(
      (exception) => Left(ServerFailure(message: exception.message)),
      (responseModel) => Right(responseModel.toEntities()),
    );
  }

  @override
  Future<Either<Failure, Buletin>> getBuletinDetail(int id) async {
    final result = await _remoteDataSource.getBuletinDetail(id);

    return result.fold(
      (exception) => Left(ServerFailure(message: exception.message)),
      (model) => Right(model.toEntity()),
    );
  }
}
