import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/quran/domain/entities/surah_name.codegen.dart';
import 'package:quranku/features/quran/domain/entities/verses.codegen.dart';

import 'language.codegen.dart';

part 'last_read_surah.codegen.freezed.dart';

@freezed
abstract class LastReadSurah with _$LastReadSurah {
  const factory LastReadSurah({
    required SurahName? surahName,
    required int surahNumber,
    required Language? revelation,
    required int totalVerses,
    required VersesNumber versesNumber,
    required double progress,
    required DateTime createdAt,
  }) = _LastReadSurah;
}
