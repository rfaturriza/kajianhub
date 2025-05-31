import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/bookmark/domain/entities/surah_bookmark.codegen.dart';
import 'package:quranku/features/quran/data/models/language_model.codegen.dart';
import 'package:quranku/features/quran/data/models/surah_name_model.codegen.dart';

part 'surah_bookmark_model.codegen.freezed.dart';

part 'surah_bookmark_model.codegen.g.dart';

@freezed
abstract class SurahBookmarkModel with _$SurahBookmarkModel {
  const factory SurahBookmarkModel({
    required SurahNameModel surahName,
    required int surahNumber,
    required LanguageModel revelation,
    required int totalVerses,
  }) = _SurahBookmarkModel;

  const SurahBookmarkModel._();

  factory SurahBookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$SurahBookmarkModelFromJson(json);

  factory SurahBookmarkModel.fromEntity(SurahBookmark entity) =>
      SurahBookmarkModel(
        surahName: SurahNameModel.fromEntity(entity.surahName),
        surahNumber: entity.surahNumber,
        revelation: LanguageModel.fromEntity(entity.revelation),
        totalVerses: entity.totalVerses,
      );

  SurahBookmark toEntity() => SurahBookmark(
        surahName: surahName.toEntity(),
        surahNumber: surahNumber,
        revelation: revelation.toEntity(),
        totalVerses: totalVerses,
      );
}
