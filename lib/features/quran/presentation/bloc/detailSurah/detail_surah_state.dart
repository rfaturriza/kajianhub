part of 'detail_surah_bloc.dart';

@freezed
abstract class SurahDetailState with _$SurahDetailState {
  const factory SurahDetailState({
    @Default(false) bool isLoading,
    Either<Failure, DetailSurah?>? detailSurahResult,
    Either<Failure, Unit>? deleteBookmarkResult,
    Either<Failure, Unit>? saveBookmarkResult,
    Either<Failure, String>? saveVerseBookmarkResult,
    Either<Failure, String>? deleteVerseBookmarkResult,
  }) = _SurahDetailState;
}
