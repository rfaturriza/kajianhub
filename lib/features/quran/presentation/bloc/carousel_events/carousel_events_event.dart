part of 'carousel_events_bloc.dart';

@freezed
abstract class CarouselEventsEvent with _$CarouselEventsEvent {
  const factory CarouselEventsEvent.loadEvents() = _LoadEvents;
  const factory CarouselEventsEvent.refreshEvents() = _RefreshEvents;
}
