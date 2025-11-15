part of 'prayer_detail_bloc.dart';

@freezed
abstract class PrayerDetailEvent with _$PrayerDetailEvent {
  const factory PrayerDetailEvent.loadPrayerDetail(int id) = _LoadPrayerDetail;
  const factory PrayerDetailEvent.loadSuggestedPrayers() =
      _LoadSuggestedPrayers;
}
