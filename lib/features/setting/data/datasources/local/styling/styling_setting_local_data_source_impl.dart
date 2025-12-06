import 'package:dartz/dartz.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/setting/data/datasources/local/styling/styling_setting_local_data_source.dart';

import '../../../../../../core/constants/font_constants.dart';
import '../../../../../../core/constants/hive_constants.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../domain/entities/last_read_reminder_mode_entity.dart';

@LazySingleton(as: StylingSettingLocalDataSource)
class StylingSettingLocalDataSourceImpl
    implements StylingSettingLocalDataSource {
  final HiveInterface hive;

  StylingSettingLocalDataSourceImpl({
    required this.hive,
  });

  @override
  Future<Either<Failure, String?>> getArabicFontFamily() async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      final String fontFamily = await box.get(
        HiveConst.arabicFontFamilyKey,
        defaultValue: FontConst.meQuran,
      );
      return right(fontFamily);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, double?>> getArabicFontSize() async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      final double? fontSize = await box.get(HiveConst.arabicFontSizeKey);
      return right(fontSize);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, double?>> getLatinFontSize() async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      final double? fontSize = await box.get(HiveConst.latinFontSizeKey);
      return right(fontSize);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, double?>> getTranslationFontSize() async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      final double? fontSize = await box.get(HiveConst.translationFontSizeKey);
      return right(fontSize);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setArabicFontFamily(String fontFamily) async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      await box.put(HiveConst.arabicFontFamilyKey, fontFamily);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setArabicFontSize(double fontSize) async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      await box.put(HiveConst.arabicFontSizeKey, fontSize);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setLatinFontSize(double fontSize) async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      await box.put(HiveConst.latinFontSizeKey, fontSize);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setTranslationFontSize(double fontSize) async {
    try {
      var box = await hive.openBox(HiveConst.languageBox);
      await box.put(HiveConst.translationFontSizeKey, fontSize);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setLastReadReminder(
      LastReadReminderModes mode) async {
    try {
      var box = await hive.openBox(HiveConst.settingBox);
      await box.put(HiveConst.lastReadRemindersModeKey, mode.name);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, LastReadReminderModes>> getLastReadReminder() async {
    try {
      var box = await hive.openBox(HiveConst.settingBox);
      final String mode = box.get(
        HiveConst.lastReadRemindersModeKey,
        defaultValue: LastReadReminderModes.autoSave.name,
      );
      final isReminders = LastReadReminderModes.values.firstWhere(
        (e) => e.name == mode,
      );
      return right(isReminders);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool?>> getShowLatin() async {
    try {
      var box = await hive.openBox(HiveConst.settingBox);
      final bool? isShowLatins = await box.get(HiveConst.latinLanguageKey);
      return right(isShowLatins);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool?>> getShowTranslation() async {
    try {
      var box = await hive.openBox(HiveConst.settingBox);
      final bool? isShowTranslations =
          await box.get(HiveConst.translationFontSizeKey);
      return right(isShowTranslations);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setShowLatin(bool isShow) async {
    try {
      var box = await hive.openBox(HiveConst.settingBox);
      await box.put(HiveConst.latinLanguageKey, isShow);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setShowTranslation(bool isShow) async {
    try {
      var box = await hive.openBox(HiveConst.settingBox);
      await box.put(HiveConst.translationFontSizeKey, isShow);
      return right(unit);
    } catch (e) {
      return left(
        CacheFailure(
          message: e.toString(),
        ),
      );
    }
  }
}
