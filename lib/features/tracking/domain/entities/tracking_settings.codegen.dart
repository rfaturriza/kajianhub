import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/hive_constants.dart';

part 'tracking_settings.codegen.freezed.dart';
part 'tracking_settings.codegen.g.dart';

@freezed
@HiveType(typeId: HiveTypeConst.trackingSettings)
abstract class TrackingSettings with _$TrackingSettings {
  const TrackingSettings._();

  const factory TrackingSettings({
    @HiveField(0) @Default(30) int defaultDailyAyahGoal,
    @HiveField(1) @Default(20) int defaultDailyMinuteGoal,
    @HiveField(2) @Default(true) bool autoCreateDailyTracking,
    @HiveField(3) @Default(true) bool showProgress,
    @HiveField(4) required DateTime createdAt,
    @HiveField(5) DateTime? updatedAt,
  }) = _TrackingSettings;

  factory TrackingSettings.fromJson(Map<String, dynamic> json) =>
      _$TrackingSettingsFromJson(json);

  factory TrackingSettings.defaultSettings() => TrackingSettings(
        createdAt: DateTime.now(),
      );
}
