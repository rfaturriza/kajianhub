import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tasbih_counter.codegen.dart';

abstract class TasbihRepository {
  Future<Either<Failure, List<TasbihCounter>>> getTasbihCounters();
  Future<Either<Failure, TasbihCounter>> incrementCounter(String counterId);
  Future<Either<Failure, TasbihCounter>> resetCounter(String counterId);
  Future<Either<Failure, TasbihCounter>> updateTarget(
      String counterId, int newTarget);
  Future<Either<Failure, List<TasbihSession>>> getTasbihSessions();
  Future<Either<Failure, TasbihSession>> startSession(List<String> counterIds);
  Future<Either<Failure, TasbihSession>> endSession(String sessionId);
  Future<Either<Failure, void>> resetAllCounters();
  Future<Either<Failure, TasbihCounter>> createCustomCounter({
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    required int target,
  });
  Future<Either<Failure, void>> deleteCustomCounter(String counterId);
}
