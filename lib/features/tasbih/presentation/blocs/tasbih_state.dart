part of 'tasbih_bloc.dart';

@freezed
abstract class TasbihState with _$TasbihState {
  const factory TasbihState({
    @Default([]) List<TasbihCounter> counters,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    String? selectedCounterId,
    String? errorMessage,
    @Default(true) bool isVibrationEnabled,
    @Default(true) bool isSoundEnabled,
  }) = _TasbihState;

  const TasbihState._();

  TasbihCounter? get selectedCounter => selectedCounterId != null
      ? counters.firstWhereOrNull((counter) => counter.id == selectedCounterId)
      : null;

  bool get isLoading => status.isInProgress;
  bool get isSuccess => status.isSuccess;
  bool get isFailure => status.isFailure;
}
