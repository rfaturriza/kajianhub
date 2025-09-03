part of 'language_setting_bloc.dart';

@freezed
abstract class LanguageSettingState with _$LanguageSettingState {
  const factory LanguageSettingState({
    Locale? languageLatin,
    Locale? languagePrayerTime,
    Locale? languageQuran,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus statusLatin,
    @Default(FormzSubmissionStatus.initial)
    FormzSubmissionStatus statusPrayerTime,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus statusQuran,
  }) = _SettingState;
}
