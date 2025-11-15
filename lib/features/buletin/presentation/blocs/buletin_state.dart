part of 'buletin_bloc.dart';

@freezed
abstract class BuletinState with _$BuletinState {
  const factory BuletinState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    @Default([]) List<Buletin> buletins,
    @Default('') String searchQuery,
    @Default(1) int currentPage,
    int? lastPage,
    int? totalData,
    @Default(false) bool hasReachedMax,
    String? errorMessage,
  }) = _BuletinState;
}
