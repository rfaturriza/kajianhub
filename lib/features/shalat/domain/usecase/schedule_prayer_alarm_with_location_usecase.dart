import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/shalat/domain/entities/geolocation.codegen.dart';
import 'package:quranku/features/shalat/domain/repositories/prayer_alarm_repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@injectable
class SchedulePrayerAlarmWithLocationUseCase extends UseCase<Unit, SchedulePrayerAlarmWithLocationParams> {
  final PrayerAlarmRepository _repository;

  SchedulePrayerAlarmWithLocationUseCase(this._repository);

  @override
  Future<Either<Failure, Unit?>> call(
    SchedulePrayerAlarmWithLocationParams params,
  ) async {
    // First check if we need to update notifications based on location change
    final shouldUpdateResult = await _repository.shouldUpdateNotifications(params.location);
    
    if (shouldUpdateResult.isLeft()) {
      return shouldUpdateResult.fold((l) => left(l), (r) => right(unit));
    }
    
    final shouldUpdate = shouldUpdateResult.getOrElse(() => false);
    
    // If location hasn't changed significantly, no need to update
    if (!shouldUpdate && !params.forceUpdate) {
      return right(unit);
    }
    
    // Schedule prayer alarms with the new location
    return _repository.schedulePrayerAlarmWithLocation(params.location);
  }
}

class SchedulePrayerAlarmWithLocationParams extends Equatable {
  final GeoLocation location;
  final bool forceUpdate;

  const SchedulePrayerAlarmWithLocationParams({
    required this.location,
    this.forceUpdate = false,
  });

  @override
  List<Object?> get props => [location, forceUpdate];
}