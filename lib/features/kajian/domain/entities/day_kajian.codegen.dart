import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/generated/locale_keys.g.dart';

part 'day_kajian.codegen.freezed.dart';

@freezed
abstract class DayKajian with _$DayKajian {
  const factory DayKajian({
    required String id,
    required String name,
  }) = _DayKajian;

  const DayKajian._();

  static List<DayKajian> get days => <DayKajian>[
        DayKajian(id: '1', name: LocaleKeys.monday.tr()),
        DayKajian(id: '2', name: LocaleKeys.tuesday.tr()),
        DayKajian(id: '3', name: LocaleKeys.wednesday.tr()),
        DayKajian(id: '4', name: LocaleKeys.thursday.tr()),
        DayKajian(id: '5', name: LocaleKeys.friday.tr()),
        DayKajian(id: '6', name: LocaleKeys.saturday.tr()),
        DayKajian(id: '7', name: LocaleKeys.sunday.tr()),
      ];
}
