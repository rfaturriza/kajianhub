import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../dataSources/local/tasbih_local_data_source.dart';
import '../../domain/entities/tasbih_counter.codegen.dart';
import '../../domain/repositories/tasbih_repository.dart';

@LazySingleton(as: TasbihRepository)
class TasbihRepositoryImpl implements TasbihRepository {
  final TasbihLocalDataSource _localDataSource;

  TasbihRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<TasbihCounter>>> getTasbihCounters() async {
    try {
      final counters = await _localDataSource.getTasbihCounters();
      return Right(counters.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TasbihCounter>> incrementCounter(
      String counterId) async {
    try {
      final counterModel = await _localDataSource.incrementCounter(counterId);
      return Right(counterModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TasbihCounter>> resetCounter(String counterId) async {
    try {
      final counterModel = await _localDataSource.resetCounter(counterId);
      return Right(counterModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TasbihCounter>> updateTarget(
      String counterId, int newTarget) async {
    try {
      final counterModel =
          await _localDataSource.updateTarget(counterId, newTarget);
      return Right(counterModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TasbihSession>>> getTasbihSessions() async {
    try {
      final sessions = await _localDataSource.getTasbihSessions();
      return Right(sessions.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TasbihSession>> startSession(
      List<String> counterIds) async {
    try {
      final sessionModel = await _localDataSource.startSession(counterIds);
      return Right(sessionModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TasbihSession>> endSession(String sessionId) async {
    try {
      final sessionModel = await _localDataSource.endSession(sessionId);
      return Right(sessionModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetAllCounters() async {
    try {
      await _localDataSource.resetAllCounters();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TasbihCounter>> createCustomCounter({
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    required int target,
  }) async {
    try {
      final counterModel = await _localDataSource.createCustomCounter(
        name: name,
        arabicText: arabicText,
        transliteration: transliteration,
        translation: translation,
        target: target,
      );
      return Right(counterModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomCounter(String counterId) async {
    try {
      await _localDataSource.deleteCustomCounter(counterId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
