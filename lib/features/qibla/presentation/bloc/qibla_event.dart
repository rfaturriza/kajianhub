part of 'qibla_bloc.dart';

@freezed
abstract class QiblaEvent with _$QiblaEvent {
  const factory QiblaEvent.streamLocationEvent(
    Either<Failure, LocationStatus>? locationStatus,
  ) = StreamLocationEvent;
  const factory QiblaEvent.streamQiblaEvent(
    Either<Failure, QiblahDirection>? qiblaDirection,
  ) = StreamQiblaEvent;
}
