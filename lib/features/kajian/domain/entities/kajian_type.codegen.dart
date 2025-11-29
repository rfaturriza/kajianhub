import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../core/utils/pair.dart';

part 'kajian_type.codegen.freezed.dart';

@freezed
abstract class KajianType with _$KajianType {
  const factory KajianType({
    required String id,
    required String name,
  }) = _KajianType;

  const KajianType._();
  static List<KajianType> get types => <KajianType>[
        KajianType(id: '1', name: LocaleKeys.routine.tr()),
        KajianType(id: '2', name: LocaleKeys.nonRoutine.tr()),
        KajianType(id: '3', name: LocaleKeys.event.tr())
      ];

  Pair<String, String> get toPair => Pair(name, id);

  static Pair<String, String> get typesPairs =>
      types.map((type) => type.toPair).reduce(
            (value, element) => Pair(
              '${value.first}|${element.first}',
              '${value.second}|${element.second}',
            ),
          );
}
