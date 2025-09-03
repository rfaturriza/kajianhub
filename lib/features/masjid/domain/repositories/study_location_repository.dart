import 'package:dartz/dartz.dart';
import 'package:quranku/features/kajian/domain/entities/study_location_entity.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/study_location_query_model.codegen.dart';

abstract class StudyLocationRepository {
  Future<Either<Failure, StudyLocationsEntity>> getStudyLocations({
    StudyLocationQueryModel queries = const StudyLocationQueryModel(),
  });
}
