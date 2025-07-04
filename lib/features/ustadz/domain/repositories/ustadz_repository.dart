import 'package:dartz/dartz.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/ustadz_query_model.codegen.dart';

abstract class UstadzRepository {
  Future<Either<Failure, UstadzListEntity>> getUstadz({
    UstadzQueryModel queries = const UstadzQueryModel(),
  });
}
