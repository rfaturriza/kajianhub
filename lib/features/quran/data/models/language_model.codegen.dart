import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/language.codegen.dart';

part 'language_model.codegen.freezed.dart';
part 'language_model.codegen.g.dart';

@freezed
abstract class LanguageModel with _$LanguageModel {
  const factory LanguageModel({
    String? en,
    String? id,
    String? arab,
  }) = _LanguageModel;

  const LanguageModel._();

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  factory LanguageModel.fromEntity(Language entity) => LanguageModel(
        en: entity.en,
        id: entity.id,
        arab: entity.arab,
      );

  Language toEntity() => Language(
        en: en,
        id: id,
        arab: arab,
      );
}
