import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/data/models/verses_model.codegen.dart';
import 'package:quranku/features/quran/domain/entities/last_read_juz.codegen.dart';

part 'last_read_juz_model.codegen.freezed.dart';
part 'last_read_juz_model.codegen.g.dart';

@freezed
abstract class LastReadJuzModel with _$LastReadJuzModel {
  const factory LastReadJuzModel({
    required String name,
    required int number,
    required String description,
    required VersesNumberModel versesNumber,
    required double progress,
    required DateTime createdAt,
  }) = _LastReadJuzModel;

  const LastReadJuzModel._();

  factory LastReadJuzModel.fromJson(Map<String, dynamic> json) =>
      _$LastReadJuzModelFromJson(json);

  factory LastReadJuzModel.fromEntity(LastReadJuz entity) => LastReadJuzModel(
        name: entity.name,
        number: entity.number,
        description: entity.description,
        versesNumber: entity.versesNumber.toModel(),
        progress: entity.progress,
        createdAt: entity.createdAt,
      );

  LastReadJuz toEntity() => LastReadJuz(
        name: name,
        number: number,
        description: description,
        versesNumber: versesNumber.toEntity(),
        progress: progress,
        createdAt: createdAt,
      );
}
