import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/ustadz_query_model.codegen.dart';
import '../repositories/ustadz_repository.dart';

@injectable
class GetUstadzListUseCase
    implements UseCase<UstadzListEntity, GetUstadzListParams> {
  final UstadzRepository repository;

  GetUstadzListUseCase(this.repository);

  @override
  Future<Either<Failure, UstadzListEntity>> call(
    GetUstadzListParams params,
  ) {
    return repository.getUstadz(
      queries: params.queries ?? const UstadzQueryModel(),
    );
  }
}

class GetUstadzListParams {
  final UstadzQueryModel? queries;

  GetUstadzListParams({
    this.queries,
  });
}
