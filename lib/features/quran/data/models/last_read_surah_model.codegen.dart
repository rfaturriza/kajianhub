import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/data/models/surah_name_model.codegen.dart';
import 'package:quranku/features/quran/data/models/verses_model.codegen.dart';

import '../../domain/entities/last_read_surah.codegen.dart';
import 'language_model.codegen.dart';

part 'last_read_surah_model.codegen.freezed.dart';
part 'last_read_surah_model.codegen.g.dart';

@freezed
abstract class LastReadSurahModel with _$LastReadSurahModel {
  const factory LastReadSurahModel({
    required SurahNameModel? surahName,
    required int surahNumber,
    required LanguageModel? revelation,
    required int totalVerses,
    required VersesNumberModel versesNumber,
    required double progress,
    required DateTime createdAt,
  }) = _LastReadSurahModel;

  const LastReadSurahModel._();

  factory LastReadSurahModel.fromJson(Map<String, dynamic> json) =>
      _$LastReadSurahModelFromJson(json);

  factory LastReadSurahModel.fromEntity(LastReadSurah entity) =>
      LastReadSurahModel(
        surahName: entity.surahName?.toModel(),
        surahNumber: entity.surahNumber,
        revelation: entity.revelation?.toModel(),
        totalVerses: entity.totalVerses,
        versesNumber: entity.versesNumber.toModel(),
        progress: entity.progress,
        createdAt: entity.createdAt,
      );

  LastReadSurah toEntity() => LastReadSurah(
        surahName: surahName?.toEntity(),
        surahNumber: surahNumber,
        revelation: revelation?.toEntity(),
        totalVerses: totalVerses,
        versesNumber: versesNumber.toEntity(),
        progress: progress,
        createdAt: createdAt,
      );
}
