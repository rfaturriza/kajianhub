part of 'tasbih_bloc.dart';

@freezed
abstract class TasbihEvent with _$TasbihEvent {
  const factory TasbihEvent.loadCounters() = _LoadCounters;
  const factory TasbihEvent.incrementCounter(String counterId) =
      _IncrementCounter;
  const factory TasbihEvent.resetCounter(String counterId) = _ResetCounter;
  const factory TasbihEvent.updateTarget(String counterId, int newTarget) =
      _UpdateTarget;
  const factory TasbihEvent.resetAllCounters() = _ResetAllCounters;
  const factory TasbihEvent.toggleVibration() = _ToggleVibration;
  const factory TasbihEvent.toggleSound() = _ToggleSound;
  const factory TasbihEvent.createCustomCounter({
    required String name,
    required String arabicText,
    required String transliteration,
    required String translation,
    required int target,
  }) = _CreateCustomCounter;
  const factory TasbihEvent.deleteCustomCounter(String counterId) =
      _DeleteCustomCounter;
  const factory TasbihEvent.selectCounter(String counterId) = _SelectCounter;
}
