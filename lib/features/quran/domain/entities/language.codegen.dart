import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/extension/string_ext.dart';
import '../../data/models/language_model.codegen.dart';

part 'language.codegen.freezed.dart';

@freezed
abstract class Language with _$Language {
  const factory Language({
    String? arab,
    String? en,
    String? id,
  }) = _Language;

  const Language._();

  LanguageModel toModel() => LanguageModel(
        arab: arab,
        id: id,
        en: en,
      );

  String asLocale(Locale locale) {
    if (locale.languageCode == 'en') {
      return en ?? emptyString;
    } else if (locale.languageCode == 'id') {
      return id ?? en ?? emptyString;
    } else {
      return arab ?? emptyString;
    }
  }
}
