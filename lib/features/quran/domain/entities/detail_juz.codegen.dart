import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/detail_juz_model.codegen.dart';
import '../../presentation/utils/tajweed_word.dart';
import 'verses.codegen.dart';

part 'detail_juz.codegen.freezed.dart';

@freezed
abstract class DetailJuz with _$DetailJuz {
  const factory DetailJuz({
    bool? isBookmarked,
    int? juz,
    int? juzStartSurahNumber,
    int? juzEndSurahNumber,
    String? juzStartInfo,
    String? juzEndInfo,
    int? totalVerses,
    List<Verses>? verses,
    List<TajweedWord>? tajweedWords,
  }) = _DetailJuz;

  const DetailJuz._();

  DataDetailJuzModel toModel() => DataDetailJuzModel(
        juz: juz,
        juzStartSurahNumber: juzStartSurahNumber,
        juzEndSurahNumber: juzEndSurahNumber,
        juzStartInfo: juzStartInfo,
        juzEndInfo: juzEndInfo,
        totalVerses: totalVerses,
        verses: verses?.map((e) => e.toModel()).toList(),
      );
}
