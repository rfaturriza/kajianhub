import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/data/models/surah_name_model.codegen.dart';
import 'package:quranku/features/quran/data/models/verses_model.codegen.dart';
import 'package:quranku/features/quran/domain/entities/juz.codegen.dart';

import '../../domain/entities/verse_bookmark.codegen.dart';

part 'verse_bookmark_model.codegen.freezed.dart';

part 'verse_bookmark_model.codegen.g.dart';

@freezed
abstract class VerseBookmarkModel with _$VerseBookmarkModel {
  const factory VerseBookmarkModel({
    SurahNameModel? surahName,
    int? surahNumber,
    JuzConstant? juz,
    required VersesNumberModel verseNumber,
  }) = _VerseBookmarkModel;

  const VerseBookmarkModel._();

  factory VerseBookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$VerseBookmarkModelFromJson(json);

  factory VerseBookmarkModel.fromEntity(VerseBookmark entity) =>
      VerseBookmarkModel(
        surahName: entity.surahName != null
            ? SurahNameModel.fromEntity(entity.surahName!)
            : null,
        surahNumber: entity.surahNumber,
        verseNumber: VersesNumberModel.fromEntity(entity.versesNumber),
        juz: entity.juz,
      );

  VerseBookmark toEntity() => VerseBookmark(
        surahName: surahName?.toEntity(),
        versesNumber: verseNumber.toEntity(),
        surahNumber: surahNumber,
        juz: juz,
      );
}
