part of 'bookmark_bloc.dart';

@freezed
abstract class BookmarkEvent with _$BookmarkEvent {
  const factory BookmarkEvent.getListVersesBookmark() = _GetListVersesBookmark;

  const factory BookmarkEvent.getListSurahBookmark() = _GetListSurahBookmark;

  const factory BookmarkEvent.getListJuzBookmark() = _GetListJuzBookmark;

  const factory BookmarkEvent.onChangedExpansionPanel({
    required int index,
    required bool isExpanded,
  }) = _OnChangedExpansionPanel;
}

class BookmarkPanelConstant {
  static const int verses = 0;
  static const int surah = 1;
  static const int juz = 2;
}
