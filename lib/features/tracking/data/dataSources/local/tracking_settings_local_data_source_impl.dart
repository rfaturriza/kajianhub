import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/constants/hive_constants.dart';
import 'package:quranku/core/error/failures.dart';
import '../../../domain/entities/tracking_settings.codegen.dart';
import 'tracking_settings_local_data_source.dart';

@LazySingleton(as: TrackingSettingsLocalDataSource)
class TrackingSettingsLocalDataSourceImpl
    implements TrackingSettingsLocalDataSource {
  static const String _settingsBox = HiveConst.trackingSettingsBox;
  static const String _settingsKey = 'tracking_settings';

  @override
  Future<Either<Failure, TrackingSettings?>> getTrackingSettings() async {
    try {
      var box = await Hive.openBox(_settingsBox);
      final jsonString = box.get(_settingsKey);
      if (jsonString == null) return right(null);

      final json = jsonDecode(jsonString);
      final settings = TrackingSettings.fromJson(json);
      return right(settings);
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to get tracking settings: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> saveTrackingSettings(
      TrackingSettings settings) async {
    try {
      var box = await Hive.openBox(_settingsBox);
      final updatedSettings = settings.copyWith(
        updatedAt: DateTime.now(),
      );
      final jsonString = jsonEncode(updatedSettings.toJson());
      await box.put(_settingsKey, jsonString);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to save tracking settings: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrackingSettings() async {
    try {
      var box = await Hive.openBox(_settingsBox);
      await box.delete(_settingsKey);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: 'Failed to delete tracking settings: ${e.toString()}',
        ),
      );
    }
  }
}
