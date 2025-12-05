import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/tasbih_counter.codegen.dart';
import '../../domain/usecases/get_tasbih_counters_usecase.dart';
import '../../domain/usecases/increment_counter_usecase.dart';
import '../../domain/usecases/reset_counter_usecase.dart';
import '../../domain/repositories/tasbih_repository.dart';

part 'tasbih_event.dart';
part 'tasbih_state.dart';
part 'tasbih_bloc.freezed.dart';

@injectable
class TasbihBloc extends Bloc<TasbihEvent, TasbihState> {
  final GetTasbihCountersUseCase _getTasbihCountersUseCase;
  final IncrementCounterUseCase _incrementCounterUseCase;
  final ResetCounterUseCase _resetCounterUseCase;
  final TasbihRepository _repository;
  final AudioPlayer _audioPlayer = AudioPlayer();

  TasbihBloc(
    this._getTasbihCountersUseCase,
    this._incrementCounterUseCase,
    this._resetCounterUseCase,
    this._repository,
  ) : super(const TasbihState()) {
    on<_LoadCounters>(_onLoadCounters);
    on<_IncrementCounter>(_onIncrementCounter);
    on<_ResetCounter>(_onResetCounter);
    on<_UpdateTarget>(_onUpdateTarget);
    on<_ResetAllCounters>(_onResetAllCounters);
    on<_ToggleVibration>(_onToggleVibration);
    on<_ToggleSound>(_onToggleSound);
    on<_CreateCustomCounter>(_onCreateCustomCounter);
    on<_DeleteCustomCounter>(_onDeleteCustomCounter);
    on<_SelectCounter>(_onSelectCounter);

    // Load counters on initialization
    add(const TasbihEvent.loadCounters());
  }

  Future<void> _onLoadCounters(
    _LoadCounters event,
    Emitter<TasbihState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _getTasbihCountersUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (counters) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        counters: counters,
        selectedCounterId: counters.isNotEmpty ? counters.first.id : null,
      )),
    );
  }

  Future<void> _onIncrementCounter(
    _IncrementCounter event,
    Emitter<TasbihState> emit,
  ) async {
    // Play sound if enabled
    if (state.isSoundEnabled) {
      try {
        // await _audioPlayer.play(AssetSource('sounds/click_sound.mp3'));
        // Sound file not implemented yet
      } catch (e) {
        // Ignore audio errors
      }
    }

    // Vibrate if enabled
    if (state.isVibrationEnabled) {
      try {
        await HapticFeedback.lightImpact();
      } catch (e) {
        // Ignore vibration errors
      }
    }

    final result = await _incrementCounterUseCase(event.counterId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedCounter) {
        final updatedCounters = state.counters.map((counter) {
          return counter.id == event.counterId ? updatedCounter : counter;
        }).toList();

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          counters: updatedCounters,
        ));

        // Check if target is reached for special vibration/sound
        if (updatedCounter.isTargetReached && state.isVibrationEnabled) {
          try {
            HapticFeedback.mediumImpact();
          } catch (e) {
            // Ignore vibration errors
          }
        }
      },
    );
  }

  Future<void> _onResetCounter(
    _ResetCounter event,
    Emitter<TasbihState> emit,
  ) async {
    final result = await _resetCounterUseCase(event.counterId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (resetCounter) {
        final updatedCounters = state.counters.map((counter) {
          return counter.id == event.counterId ? resetCounter : counter;
        }).toList();

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          counters: updatedCounters,
        ));
      },
    );
  }

  Future<void> _onUpdateTarget(
    _UpdateTarget event,
    Emitter<TasbihState> emit,
  ) async {
    final result =
        await _repository.updateTarget(event.counterId, event.newTarget);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedCounter) {
        final updatedCounters = state.counters.map((counter) {
          return counter.id == event.counterId ? updatedCounter : counter;
        }).toList();

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          counters: updatedCounters,
        ));
      },
    );
  }

  Future<void> _onResetAllCounters(
    _ResetAllCounters event,
    Emitter<TasbihState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _repository.resetAllCounters();
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        // Reload counters after reset
        add(const TasbihEvent.loadCounters());
      },
    );
  }

  void _onToggleVibration(
    _ToggleVibration event,
    Emitter<TasbihState> emit,
  ) {
    emit(state.copyWith(isVibrationEnabled: !state.isVibrationEnabled));
  }

  void _onToggleSound(
    _ToggleSound event,
    Emitter<TasbihState> emit,
  ) {
    emit(state.copyWith(isSoundEnabled: !state.isSoundEnabled));
  }

  Future<void> _onCreateCustomCounter(
    _CreateCustomCounter event,
    Emitter<TasbihState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _repository.createCustomCounter(
      name: event.name,
      arabicText: event.arabicText,
      transliteration: event.transliteration,
      translation: event.translation,
      target: event.target,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (newCounter) {
        final updatedCounters = [...state.counters, newCounter];
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          counters: updatedCounters,
        ));
      },
    );
  }

  Future<void> _onDeleteCustomCounter(
    _DeleteCustomCounter event,
    Emitter<TasbihState> emit,
  ) async {
    final result = await _repository.deleteCustomCounter(event.counterId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedCounters = state.counters
            .where((counter) => counter.id != event.counterId)
            .toList();

        // If deleted counter was selected, select first available
        String? newSelectedId = state.selectedCounterId;
        if (state.selectedCounterId == event.counterId) {
          newSelectedId =
              updatedCounters.isNotEmpty ? updatedCounters.first.id : null;
        }

        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          counters: updatedCounters,
          selectedCounterId: newSelectedId,
        ));
      },
    );
  }

  void _onSelectCounter(
    _SelectCounter event,
    Emitter<TasbihState> emit,
  ) {
    emit(state.copyWith(selectedCounterId: event.counterId));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
