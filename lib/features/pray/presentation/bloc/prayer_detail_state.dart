part of 'prayer_detail_bloc.dart';

@freezed
abstract class PrayerDetailState with _$PrayerDetailState {
  const factory PrayerDetailState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    Prayer? prayer,
    String? errorMessage,
    @Default(FormzSubmissionStatus.initial)
    FormzSubmissionStatus suggestedPrayersStatus,
    @Default([]) List<Prayer> suggestedPrayers,
  }) = _PrayerDetailState;
}
