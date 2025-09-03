part of 'qibla_bloc.dart';

@freezed
abstract class QiblaState with _$QiblaState {
  const factory QiblaState({
    Either<Failure, LocationStatus>? locationStatusResult,
    @Default(true) bool isLoading,
    Either<Failure, QiblahDirection>? qiblaDirectionResult,
  }) = _QiblaState;
}
