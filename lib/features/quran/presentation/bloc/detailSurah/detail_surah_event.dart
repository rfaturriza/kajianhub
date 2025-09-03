part of 'detail_surah_bloc.dart';

@freezed
abstract class SurahDetailEvent with _$SurahDetailEvent {
  const factory SurahDetailEvent.fetchSurahDetail({
    int? surahNumber,
  }) = FetchSurahDetailEvent;

  const factory SurahDetailEvent.onPressedBookmark({
    SurahBookmark? surahBookmark,
    required bool isBookmarked,
  }) = OnPressedBookmarkEvent;

  const factory SurahDetailEvent.onPressedVerseBookmark({
    VerseBookmark? bookmark,
    required bool isBookmarked,
  }) = OnPressedVerseBookmarkEvent;
}
