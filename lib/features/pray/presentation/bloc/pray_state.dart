part of 'pray_bloc.dart';

@freezed
abstract class PrayState with _$PrayState {
  const factory PrayState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    @Default([]) List<Prayer> prayers,
    @Default(1) int currentPage,
    @Default(false) bool hasReachedMax,
    @Default(false) bool isLoadingMore,
    String? errorMessage,
    String? searchQuery,
  }) = _PrayState;
}
