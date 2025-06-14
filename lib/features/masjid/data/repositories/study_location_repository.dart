import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/exceptions.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';

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
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: LocaleKeys.defaultErrorMessage.tr()));
    }
  }
}
