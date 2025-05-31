part of 'audio_verse_bloc.dart';

@freezed
abstract class AudioVerseEvent with _$AudioVerseEvent {
  const factory AudioVerseEvent.playAudioVerse({
    required Audio? audioVerse,
  }) = PlayAudioVerse;

  const factory AudioVerseEvent.setListAudioVerse({
    required List<Audio?>? listAudioVerses,
  }) = SetListAudioVerse;

  const factory AudioVerseEvent.pauseAudioVerse() = PauseAudioVerse;

  const factory AudioVerseEvent.stopAudioVerse() = StopAudioVerse;

  const factory AudioVerseEvent.resumeAudioVerse() = ResumeAudioVerse;

  const factory AudioVerseEvent.seekAudioVerse({
    required Duration position,
  }) = SeekAudioVerse;

  const factory AudioVerseEvent.setVolumeAudioVerse({
    required double volume,
  }) = SetVolumeAudioVerse;

  const factory AudioVerseEvent.nextAudioVerse() = NextAudioVerse;

  const factory AudioVerseEvent.previousAudioVerse() = PreviousAudioVerse;

  const factory AudioVerseEvent.streamAudioStateEvent(
    PlayerState state,
  ) = StreamAudioStateEvent;

  const factory AudioVerseEvent.streamPositionStateEvent(
    Duration position,
  ) = StreamAudioPositionEvent;

  const factory AudioVerseEvent.streamDurationStateEvent(
    Duration duration,
  ) = StreamAudioDurationEvent;
}
