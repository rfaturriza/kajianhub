import 'package:hive_ce/hive.dart';
import 'package:quranku/features/shalat/domain/entities/geolocation.codegen.dart';
import 'package:quranku/features/shalat/domain/entities/schedule.codegen.dart';
import 'package:quranku/features/tracking/data/models/daily_tracking_model.codegen.dart';
import 'package:quranku/features/tracking/domain/entities/tracking_settings.codegen.dart';

import 'features/quran/presentation/utils/tajweed_rule.dart';
import 'features/quran/presentation/utils/tajweed_subrule.dart';
import 'features/quran/presentation/utils/tajweed_token.dart';
import 'features/quran/presentation/utils/tajweed_word.dart';
import 'features/shalat/data/models/prayer_schedule_setting_model.codegen.dart';

Future<void> registerHiveAdapter() async {
  Hive.registerAdapter(TajweedTokenAdapter());
  Hive.registerAdapter(TajweedWordAdapter());
  Hive.registerAdapter(TajweedWordListAdapter());
  Hive.registerAdapter(TajweedRuleAdapter());
  Hive.registerAdapter(TajweedSubruleAdapter());
  Hive.registerAdapter(PrayerScheduleSettingModelAdapter());
  Hive.registerAdapter(PrayerAlarmModelAdapter());
  Hive.registerAdapter(GeoLocationAdapter());
  Hive.registerAdapter(CoordinateAdapter());
  Hive.registerAdapter(DailyTrackingModelAdapter());
  Hive.registerAdapter(TrackingSettingsAdapter());
}
