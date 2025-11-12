part of 'share_verse_bloc.dart';

@freezed
abstract class ShareVerseState with _$ShareVerseState {
  const factory ShareVerseState({
    Verses? verse,
    JuzConstant? juz,
    DetailSurah? surah,
    @Default(false) bool isLoading,
    String? randomImageUrl,
    Color? backgroundColor,
    @Default(10) double arabicFontSize,
    @Default(10) double latinFontSize,
    @Default(10) double translationFontSize,
    @Default(true) bool isArabicVisible,
    @Default(true) bool isLatinVisible,
    @Default(true) bool isTranslationVisible,
    // text colors (null means use default white)
    Color? arabicTextColor,
    Color? latinTextColor,
    Color? translationTextColor,
    // custom background image path
    String? backgroundImagePath,
  }) = _ShareVerseState;
}
