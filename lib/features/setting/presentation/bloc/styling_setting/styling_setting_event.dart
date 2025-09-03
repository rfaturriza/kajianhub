part of 'styling_setting_bloc.dart';

@freezed
abstract class StylingSettingEvent with _$StylingSettingEvent {
  const factory StylingSettingEvent.init() = _Init;

  const factory StylingSettingEvent.setArabicFontFamily({
    required String fontFamily,
  }) = _SetArabicFontFamily;

  const factory StylingSettingEvent.setArabicFontSize({
    required double fontSize,
  }) = _SetArabicFontSize;

  const factory StylingSettingEvent.setLatinFontSize({
    required double fontSize,
  }) = _SetLatinFontSize;

  const factory StylingSettingEvent.setTranslationFontSize({
    required double fontSize,
  }) = _SetTranslationFontSize;

  const factory StylingSettingEvent.getArabicFontFamily() =
      _GetArabicFontFamily;

  const factory StylingSettingEvent.getArabicFontSize() = _GetArabicFontSize;

  const factory StylingSettingEvent.getLatinFontSize() = _GetLatinFontSize;

  const factory StylingSettingEvent.getTranslationFontSize() =
      _GetTranslationFontSize;

  const factory StylingSettingEvent.setLastReadReminder({
    required LastReadReminderModes mode,
  }) = _SetLastReadReminder;

  const factory StylingSettingEvent.getLastReadReminder() =
      _GetLastReadReminder;

  const factory StylingSettingEvent.setShowLatin({
    required bool isShow,
  }) = _SetShowLatin;

  const factory StylingSettingEvent.getShowLatin() = _GetShowLatin;

  const factory StylingSettingEvent.setShowTranslation({
    required bool isShow,
  }) = _SetShowTranslation;

  const factory StylingSettingEvent.getShowTranslation() = _GetShowTranslation;

  const factory StylingSettingEvent.setColoredTajweedStatus({
    required bool isColoredTajweedEnabled,
  }) = _SetColoredTajweedStatus;

  const factory StylingSettingEvent.getColoredTajweedStatus() =
      _GetColoredTajweedStatus;
}
