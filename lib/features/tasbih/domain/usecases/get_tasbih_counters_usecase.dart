import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/tasbih_counter.codegen.dart';
import '../repositories/tasbih_repository.dart';

@injectable
class GetTasbihCountersUseCase {
  final TasbihRepository _repository;

  GetTasbihCountersUseCase(this._repository);

  Future<Either<Failure, List<TasbihCounter>>> call() async {
    return await _repository.getTasbihCounters();
  }
}
