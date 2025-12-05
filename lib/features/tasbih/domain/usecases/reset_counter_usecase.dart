import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/tasbih_counter.codegen.dart';
import '../repositories/tasbih_repository.dart';

@injectable
class ResetCounterUseCase {
  final TasbihRepository _repository;

  ResetCounterUseCase(this._repository);

  Future<Either<Failure, TasbihCounter>> call(String counterId) async {
    return await _repository.resetCounter(counterId);
  }
}
