part of 'audio_verse_bloc.dart';

@freezed
abstract class AudioVerseState with _$AudioVerseState {
  const factory AudioVerseState({
    @Default(false) bool isLoading,
    @Default(PlayerState.stopped) PlayerState playerState,
    @Default(Duration()) Duration position,
    @Default(Duration()) Duration duration,
    @Default(false) isShowBottomNavPlayer,
    Audio? audioVersePlaying,
    List<Audio?>? listAudioVerses,
    String? errorMessage,
  }) = _AudioVerseState;
}
