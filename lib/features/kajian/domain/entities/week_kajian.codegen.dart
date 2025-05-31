import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/generated/locale_keys.g.dart';

part 'week_kajian.codegen.freezed.dart';

@freezed
abstract class WeekKajian with _$WeekKajian {
  const factory WeekKajian({
    required String id,
    required String name,
  }) = _WeekKajian;

  const WeekKajian._();

  static List<WeekKajian> get weeks => <WeekKajian>[
        WeekKajian(id: '1', name: '${LocaleKeys.week.tr()} 1'),
        WeekKajian(id: '2', name: '${LocaleKeys.week.tr()} 2'),
        WeekKajian(id: '3', name: '${LocaleKeys.week.tr()} 3'),
        WeekKajian(id: '4', name: '${LocaleKeys.week.tr()} 4'),
      ];
}
