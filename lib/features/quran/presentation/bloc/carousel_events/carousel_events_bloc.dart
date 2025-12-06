import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/carousel_event.codegen.dart';
import '../../../domain/usecases/get_carousel_events_usecase.dart';

part 'carousel_events_event.dart';
part 'carousel_events_state.dart';
part 'carousel_events_bloc.freezed.dart';

@injectable
class CarouselEventsBloc
    extends Bloc<CarouselEventsEvent, CarouselEventsState> {
  final GetCarouselEventsUseCase _getCarouselEventsUseCase;

  CarouselEventsBloc(this._getCarouselEventsUseCase)
      : super(const CarouselEventsState()) {
    on<_LoadEvents>(_onLoadEvents);
    on<_RefreshEvents>(_onRefreshEvents);

    // Load events on initialization
    add(const CarouselEventsEvent.loadEvents());
  }

  Future<void> _onLoadEvents(
    _LoadEvents event,
    Emitter<CarouselEventsState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _getCarouselEventsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (events) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        events: events,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onRefreshEvents(
    _RefreshEvents event,
    Emitter<CarouselEventsState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await _getCarouselEventsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (events) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        events: events,
        errorMessage: null,
      )),
    );
  }
}
