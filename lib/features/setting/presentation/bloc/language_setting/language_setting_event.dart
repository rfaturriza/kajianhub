part of 'language_setting_bloc.dart';

@freezed
abstract class LanguageSettingEvent with _$LanguageSettingEvent {
  const factory LanguageSettingEvent.setLatinLanguage({
    required Locale locale,
  }) = _SetLatinLanguage;

  const factory LanguageSettingEvent.setPrayerLanguage({
    required Locale locale,
  }) = _SetPrayerLanguage;

  const factory LanguageSettingEvent.setQuranLanguage({
    required Locale locale,
  }) = _SetQuranLanguage;

  const factory LanguageSettingEvent.getLatinLanguage() = _GetLatinLanguage;

  const factory LanguageSettingEvent.getPrayerLanguage() = _GetPrayerLanguage;

  const factory LanguageSettingEvent.getQuranLanguage() = _GetQuranLanguage;
}
