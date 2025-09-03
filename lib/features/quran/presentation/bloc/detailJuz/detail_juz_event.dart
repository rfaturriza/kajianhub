part of 'detail_juz_bloc.dart';

@freezed
abstract class JuzDetailEvent with _$JuzDetailEvent {
  const factory JuzDetailEvent.fetchJuzDetail({
    required int? juzNumber,
  }) = FetchJuzDetailEvent;

  const factory JuzDetailEvent.onPressedBookmark({
    JuzBookmark? juzBookmark,
    required bool isBookmarked,
  }) = OnPressedBookmarkEvent;

  const factory JuzDetailEvent.onPressedVerseBookmark({
    VerseBookmark? bookmark,
    required bool isBookmarked,
  }) = OnPressedVerseBookmarkEvent;
}
