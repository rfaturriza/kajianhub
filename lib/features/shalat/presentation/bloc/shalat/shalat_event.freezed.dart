import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/shalat/domain/entities/geolocation.codegen.dart';
import 'package:quranku/features/shalat/domain/entities/prayer_schedule_setting.codegen.dart';

part 'shalat_event.dart';

@freezed
class ShalatEvent with _$ShalatEvent {
  const factory ShalatEvent.init(Locale? locale) = _Init;
  
  const factory ShalatEvent.schedulePrayerAlarmWithLocationEvent({
    required GeoLocation location,
    @Default(false) bool forceUpdate,
  }) = _SchedulePrayerAlarmWithLocationEvent;
  
  const factory ShalatEvent.checkAndUpdateNotificationsEvent() =
      _CheckAndUpdateNotificationsEvent;
  
  const factory ShalatEvent.schedulePrayerAlarmEvent() = _SchedulePrayerAlarmEvent;
  
  // ... other event factories ...
}