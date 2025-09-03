import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T?>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

abstract class StreamUseCase<ReturnType, Params> {
  const StreamUseCase();
  Stream<Either<Failure, ReturnType>> call(Params params);
}