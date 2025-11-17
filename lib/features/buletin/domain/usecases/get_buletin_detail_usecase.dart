import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';
import 'package:quranku/features/buletin/domain/repositories/buletin_repository.dart';

@injectable
class GetBuletinDetailUsecase {
  final BuletinRepository _repository;

  GetBuletinDetailUsecase(this._repository);

  Future<Either<Failure, Buletin>> call(int id) {
    return _repository.getBuletinDetail(id);
  }
}
