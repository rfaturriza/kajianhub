part of 'ustad_ai_bloc.dart';

@freezed
abstract class UstadAiEvent with _$UstadAiEvent {
  const factory UstadAiEvent.sendPrompt(String prompt) = _SendPrompt;
}
