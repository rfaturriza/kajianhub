import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/tasbih_counter.codegen.dart';
import '../repositories/tasbih_repository.dart';

@injectable
class IncrementCounterUseCase {
  final TasbihRepository _repository;

  IncrementCounterUseCase(this._repository);

  Future<Either<Failure, TasbihCounter>> call(String counterId) async {
    return await _repository.incrementCounter(counterId);
  }
}
