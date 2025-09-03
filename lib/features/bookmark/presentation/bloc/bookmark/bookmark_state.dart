part of 'bookmark_bloc.dart';

@freezed
abstract class BookmarkState with _$BookmarkState {
  const factory BookmarkState({
    @Default(false) bool isLoading,
    Either<Failure, List<VerseBookmark>>? verseBookmarks,
    Either<Failure, List<SurahBookmark>>? surahBookmarks,
    Either<Failure, List<JuzBookmark>>? juzBookmarks,
    @Default(false) bool isExpandedVerses,
    @Default(false) bool isExpandedSurah,
    @Default(false) bool isExpandedJuz,
  }) = _BookmarkState;
}
