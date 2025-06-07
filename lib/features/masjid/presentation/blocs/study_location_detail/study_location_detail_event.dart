part of 'study_location_detail_bloc.dart';

@freezed
abstract class StudyLocationDetailEvent with _$StudyLocationDetailEvent {
  const factory StudyLocationDetailEvent.loadStudies({
    required String studyLocationId,
    required int page,
  }) = _LoadStudies;
}
