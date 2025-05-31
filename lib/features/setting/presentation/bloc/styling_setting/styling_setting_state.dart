part of 'styling_setting_bloc.dart';

@freezed
abstract class StylingSettingState with _$StylingSettingState {
  const factory StylingSettingState({
    @Default(FormzSubmissionStatus.initial)
    FormzSubmissionStatus statusArabicFontSize,
    @Default(FormzSubmissionStatus.initial)
    FormzSubmissionStatus statusArabicFontFamily,
    @Default(FormzSubmissionStatus.initial)
    FormzSubmissionStatus statusLatinFontSize,
    @Default(FormzSubmissionStatus.initial)
    FormzSubmissionStatus statusTranslationFontSize,
    @Default(FontConst.defaultArabicFontSize) double arabicFontSize,
    @Default(FontConst.lpmqIsepMisbah) String fontFamilyArabic,
    @Default(FontConst.defaultLatinFontSize) double latinFontSize,
    @Default(FontConst.defaultTranslationFontSize) double translationFontSize,
    @Default(LastReadReminderModes.on)
    LastReadReminderModes lastReadReminderMode,
    @Default(true) bool isShowLatin,
    @Default(true) bool isShowTranslation,
    @Default(true) bool isColoredTajweedEnabled,
  }) = _StylingSettingState;
}
