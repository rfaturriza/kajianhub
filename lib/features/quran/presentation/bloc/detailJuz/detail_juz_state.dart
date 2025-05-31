part of 'detail_juz_bloc.dart';

@freezed
abstract class JuzDetailState with _$JuzDetailState {
  const factory JuzDetailState({
    @Default(false) bool isLoading,
    Either<Failure, DetailJuz?>? detailJuzResult,
    Either<Failure, Unit>? deleteBookmarkResult,
    Either<Failure, Unit>? saveBookmarkResult,
    Either<Failure, String>? saveVerseBookmarkResult,
    Either<Failure, String>? deleteVerseBookmarkResult,
  }) = _JuzDetailState;
}
