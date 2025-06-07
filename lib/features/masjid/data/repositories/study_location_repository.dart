import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/exceptions.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';

import '../../../../core/error/failures.dart';
import '../../../kajian/domain/entities/study_location_entity.dart';
import '../../domain/repositories/study_location_repository.dart';
import '../dataSources/remote/study_location_remote_data_source.dart';
import '../models/study_location_query_model.codegen.dart';

@LazySingleton(as: StudyLocationRepository)
class StudyLocationRepositoryImpl implements StudyLocationRepository {
  final StudyLocationRemoteDataSource remoteDataSource;

  StudyLocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ServerFailure, StudyLocationsEntity>> getStudyLocations({
    StudyLocationQueryModel queries = const StudyLocationQueryModel(),
  }) async {
    try {
      final models = await remoteDataSource.getStudyLocations(queries: queries);
      if (models.isLeft()) {
        return Left(ServerFailure(message: models.asLeft().message));
      }
      final mosqueEntities = models.asRight();
      return Right(mosqueEntities.toEntity());
    } catch (e) {
      // Handle any unexpected errors
      final exception = ServerException(e as Exception);
      return Left(ServerFailure(message: exception.message));
    }
  }
}
