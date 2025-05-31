part of 'ustad_ai_bloc.dart';

@freezed
abstract class UstadAiState with _$UstadAiState {
  const factory UstadAiState.initial() = UstadAiInitialState;
  const factory UstadAiState.streaming({
    required String text,
    @Default(false) bool isGenerating,
  }) = UstadAiStreamingState;
  const factory UstadAiState.error(String message) = UstadAiErrorState;
}
