part of 'carousel_events_bloc.dart';

@freezed
abstract class CarouselEventsState with _$CarouselEventsState {
  const factory CarouselEventsState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    @Default([]) List<CarouselEvent> events,
    String? errorMessage,
  }) = _CarouselEventsState;
}

extension CarouselEventsStateX on CarouselEventsState {
  bool get isLoading => status == FormzSubmissionStatus.inProgress;
  bool get isSuccess => status == FormzSubmissionStatus.success;
  bool get isFailure => status == FormzSubmissionStatus.failure;
}
