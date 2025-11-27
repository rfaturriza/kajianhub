import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/hive_constants.dart';

part 'daily_tracking_model.codegen.freezed.dart';
part 'daily_tracking_model.codegen.g.dart';

@freezed
@HiveType(typeId: HiveTypeConst.dailyTrackingModel)
abstract class DailyTrackingModel with _$DailyTrackingModel {
  const factory DailyTrackingModel({
    @HiveField(0) required String date, // Format: 'yyyy-MM-dd'
    @HiveField(1) @Default(false) bool fajr,
    @HiveField(2) @Default(false) bool dhuhr,
    @HiveField(3) @Default(false) bool asr,
    @HiveField(4) @Default(false) bool maghrib,
    @HiveField(5) @Default(false) bool isha,
    @HiveField(6) @Default(0) int ayahsRead,
    @HiveField(7) @Default(0) int minutesRead,
    @HiveField(8) @Default(30) int dailyAyahGoal,
    @HiveField(9) @Default(20) int dailyMinuteGoal,
    @HiveField(10) required DateTime createdAt,
    @HiveField(11) DateTime? updatedAt,
  }) = _DailyTrackingModel;

  const DailyTrackingModel._();

  factory DailyTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$DailyTrackingModelFromJson(json);

  int get completedPrayers {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    return count;
  }

  bool get isQuranGoalAchieved {
    return ayahsRead >= dailyAyahGoal && minutesRead >= dailyMinuteGoal;
  }

  double get ayahProgress => ayahsRead / dailyAyahGoal;
  double get minuteProgress => minutesRead / dailyMinuteGoal;

  DateTime get dateTime => DateTime.parse(date);
}
