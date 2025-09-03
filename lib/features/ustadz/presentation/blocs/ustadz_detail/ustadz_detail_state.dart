part of 'ustadz_detail_bloc.dart';

@freezed
abstract class UstadzDetailState with _$UstadzDetailState {
  const factory UstadzDetailState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus statusKajian,
    @Default([]) List<DataKajianSchedule> kajianResult,
    @Default(1) int currentPage,
    int? lastPage,
    int? totalData,
    @Default(false) bool hasReachedMax,
    String? errorMessage,
  }) = _UstadzDetailState;
}
