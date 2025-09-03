part of 'study_location_list_bloc.dart';

@freezed
abstract class StudyLocationListState with _$StudyLocationListState {
  const factory StudyLocationListState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    final List<StudyLocationEntity>? studyLocations,
    @Default('') String errorMessage,
    @Default(1) int currentPage,
    int? lastPage,
    int? totalData,
    @Default(false) bool hasReachedMax,
    String? querySearch,
    @Default(false) bool isLoadingMore,
  }) = _StudyLocationListState;
}