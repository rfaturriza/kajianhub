part of 'buletin_bloc.dart';

@freezed
abstract class BuletinEvent with _$BuletinEvent {
  const factory BuletinEvent.loadBuletins({
    String? query,
    @Default(false) bool isRefresh,
  }) = _LoadBuletins;

  const factory BuletinEvent.loadMoreBuletins() = _LoadMoreBuletins;

  const factory BuletinEvent.searchBuletins(String query) = _SearchBuletins;

  const factory BuletinEvent.clearSearch() = _ClearSearch;
}
