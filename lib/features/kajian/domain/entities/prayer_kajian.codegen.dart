import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/shalat/presentation/helper/helper_time_shalat.dart';

part 'prayer_kajian.codegen.freezed.dart';

@freezed
abstract class PrayerKajian with _$PrayerKajian {
  const factory PrayerKajian({
    required String id,
    required String name,
  }) = _PrayerKajian;

  const PrayerKajian._();

  static List<PrayerKajian> get prayersId => <PrayerKajian>[
        const PrayerKajian(id: 'subuh', name: 'Subuh'),
        const PrayerKajian(id: 'dhuha', name: 'Dhuha'),
        const PrayerKajian(id: 'dzuhur', name: 'Dzuhur'),
        const PrayerKajian(id: 'ashar', name: 'Ashar'),
        const PrayerKajian(id: 'maghrib', name: 'Maghrib'),
        const PrayerKajian(id: 'isya', name: 'Isya'),
      ];

  static List<PrayerKajian> prayersByLocale(Locale? locale) {
    final prayerName = HelperTimeShalat.prayerNameByLocale(locale);

    /// Remove Imsak and Terbit
    prayerName.removeAt(0);
    prayerName.removeAt(1);

    return prayersId.asMap().entries.map((e) {
      return PrayerKajian(id: e.value.id, name: prayerName[e.key]);
    }).toList();
  }

  static List<PrayerKajian> prayersRamadhan() {
    /// Just Subuh and Tarawih
    /// 1/2 -> 1 = Tarawih, 2 = Subuh
    final prayerName = {
      1: 'Tarawih',
      2: 'Subuh',
    };

    return prayerName.entries.map((e) {
      return PrayerKajian(id: e.key.toString(), name: e.value);
    }).toList();
  }

  static List<PrayerKajian> prayersKajian() {
    final prayerName = {
      // Using by {type_id}:{subtype_id} format
      "1:": 'Jum\'at',
      "2:2": 'Subuh',
      "2:1": 'Terawih',
      "3:": 'Qiyamul Lail',
      ":3": 'Idul Fitri',
      ":4": 'Idul Adha',
    };

    // ignore: unused_local_variable
    final prayerCategoryName = {
      1: 'Jum\'at',
      2: 'Tarawih',
      3: 'Subuh',
      4: 'Qiyamul Lail',
      5: 'Idul Fitri',
      6: 'Idul Adha',
    };

    return prayerName.entries.map((e) {
      return PrayerKajian(id: e.key.toString(), name: e.value);
    }).toList();
  }
}
