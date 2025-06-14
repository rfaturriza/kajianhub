import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/kajian/domain/entities/study_location_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/study_location_query_model.codegen.dart';
import '../repositories/study_location_repository.dart';

@injectable
class GetStudyLocationListUseCase
    implements UseCase<StudyLocationsEntity, GetStudyLocationListParams> {
  final StudyLocationRepository repository;

  GetStudyLocationListUseCase(this.repository);

  @override
  Future<Either<Failure, StudyLocationsEntity>> call(
    GetStudyLocationListParams params,
  ) {
    return repository.getStudyLocations(
      queries: params.queries ?? const StudyLocationQueryModel(),
    );
  }
}

class GetStudyLocationListParams {
  final StudyLocationQueryModel? queries;

  GetStudyLocationListParams({
    this.queries,
  });
}
