import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/generated/locale_keys.g.dart';

part 'kajian_type.codegen.freezed.dart';

@freezed
abstract class KajianType with _$KajianType {
  const factory KajianType({
    required String id,
    required String name,
  }) = _KajianType;

  const KajianType._();

  static List<KajianType> get types => <KajianType>[
        KajianType(id: '1', name: LocaleKeys.Routine.tr()),
        KajianType(id: '2', name: LocaleKeys.NonRoutine.tr()),
        KajianType(id: '3', name: LocaleKeys.Event.tr())
      ];
}
