part of 'study_location_detail_bloc.dart';

@freezed
abstract class StudyLocationDetailState with _$StudyLocationDetailState {
  const factory StudyLocationDetailState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus statusKajian,
    @Default([]) List<DataKajianSchedule> kajianResult,
    @Default('') String errorMessage,
    @Default(1) int currentPage,
    int? lastPage,
    int? totalData,
    @Default(false) bool hasReachedMax,
  }) = _StudyLocationDetailState;
}
