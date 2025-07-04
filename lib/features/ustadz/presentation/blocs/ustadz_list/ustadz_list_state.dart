part of 'ustadz_list_bloc.dart';

@freezed
abstract class UstadzListState with _$UstadzListState {
  const factory UstadzListState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    List<UstadzEntity>? ustadzList,
    @Default(1) int currentPage,
    int? lastPage,
    @Default(0) int totalData,
    @Default(false) bool hasReachedMax,
    @Default(false) bool isLoadingMore,
    String? querySearch,
    String? errorMessage,
  }) = _UstadzListState;
}
