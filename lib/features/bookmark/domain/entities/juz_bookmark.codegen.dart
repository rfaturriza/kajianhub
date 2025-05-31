import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../quran/domain/entities/juz.codegen.dart';

part 'juz_bookmark.codegen.freezed.dart';

@freezed
abstract class JuzBookmark with _$JuzBookmark {
  const factory JuzBookmark({
    required String name,
    required int number,
    required String description,
  }) = _JuzBookmark;

  const JuzBookmark._();

  String get descriptionTr => JuzConstant.juzList
      .firstWhere((element) => element.number == number)
      .description;
}
