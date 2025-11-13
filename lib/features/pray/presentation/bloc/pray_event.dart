part of 'pray_bloc.dart';

@freezed
abstract class PrayEvent with _$PrayEvent {
  const factory PrayEvent.fetchPrayers({
    String? query,
    @Default(1) int page,
    @Default(12) int limit,
    @Default('id') String orderBy,
    @Default('asc') String sortBy,
  }) = _FetchPrayers;

  const factory PrayEvent.loadMorePrayers() = _LoadMorePrayers;

  const factory PrayEvent.searchPrayers(String query) = _SearchPrayers;

  const factory PrayEvent.clearSearch() = _ClearSearch;
}
