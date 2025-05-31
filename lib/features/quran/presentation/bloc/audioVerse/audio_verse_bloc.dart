import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/quran/domain/entities/verses.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../../core/utils/extension/string_ext.dart';

part 'audio_verse_bloc.freezed.dart';

part 'audio_verse_event.dart';

part 'audio_verse_state.dart';

@injectable
class AudioVerseBloc extends Bloc<AudioVerseEvent, AudioVerseState> {
  final AudioPlayer _audioPlayer;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _playerPositionSubscription;
  StreamSubscription<Duration>? _playerDurationSubscription;
  StreamSubscription<void>? _playerCompletionSubscription;

  AudioVerseBloc(this._audioPlayer) : super(const AudioVerseState()) {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
      (state) {
        add(AudioVerseEvent.streamAudioStateEvent(state));
      },
    );

    _playerPositionSubscription = _audioPlayer.onPositionChanged.listen(
      (position) {
        add(AudioVerseEvent.streamPositionStateEvent(position));
      },
    );

    _playerDurationSubscription = _audioPlayer.onDurationChanged.listen(
      (duration) {
        add(AudioVerseEvent.streamDurationStateEvent(duration));
      },
    );

    _playerCompletionSubscription = _audioPlayer.onPlayerComplete.listen(
      (_) {
        add(const AudioVerseEvent.nextAudioVerse());
      },
    );

    on<SetListAudioVerse>(_onSetListAudioVerse);
    on<PlayAudioVerse>(_onPlayAudioVerse);
    on<PauseAudioVerse>(_onPauseAudioVerse);
    on<StopAudioVerse>(_onStopAudioVerse);
    on<ResumeAudioVerse>(_onResumeAudioVerse);
    on<SeekAudioVerse>(_onSeekAudioVerse);
    on<SetVolumeAudioVerse>(_onSetVolumeAudioVerse);
    on<StreamAudioStateEvent>(_onStreamAudioStateEvent);
    on<StreamAudioPositionEvent>(_onStreamPositionStateEvent);
    on<StreamAudioDurationEvent>(_onStreamDurationStateEvent);
    on<NextAudioVerse>(_onNextAudioVerse);
    on<PreviousAudioVerse>(_onPreviousAudioVerse);
  }

  void _onSetListAudioVerse(
    SetListAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    emit(state.copyWith(
      listAudioVerses: event.listAudioVerses,
    ));
  }

  Future<void> _onPlayAudioVerse(
    PlayAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isShowBottomNavPlayer: true,
        isLoading: true,
      ));
      await _audioPlayer.stop();

      if (event.audioVerse?.primary?.isNotEmpty == true) {
        await _audioPlayer.setSource(
          UrlSource(event.audioVerse?.primary ?? emptyString),
        );
      } else if (event.audioVerse?.secondary?.isNotEmpty == true) {
        await _audioPlayer.setSource(
          UrlSource(event.audioVerse?.secondary?.first ?? emptyString),
        );
      } else {
        emit(
          state.copyWith(
            errorMessage: LocaleKeys.audioNotAvailable.tr(),
            isShowBottomNavPlayer: false,
            isLoading: false,
          ),
        );
        return;
      }
      await _audioPlayer.resume();
      emit(state.copyWith(
        audioVersePlaying: event.audioVerse,
        playerState: _audioPlayer.state,
        isShowBottomNavPlayer: true,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: LocaleKeys.unknownErrorException.tr(),
        isShowBottomNavPlayer: false,
        isLoading: false,
      ));
    }
  }

  void _onNextAudioVerse(
    NextAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    final index = state.listAudioVerses?.indexOf(state.audioVersePlaying);
    if (index == null) return;
    if (index + 1 >= (state.listAudioVerses?.length ?? 0)) {
      emit(state.copyWith(
        isShowBottomNavPlayer: false,
        audioVersePlaying: null,
      ));
      return;
    }
    final nextVerse = state.listAudioVerses?[index + 1];
    if (nextVerse == null) {
      emit(state.copyWith(
        isShowBottomNavPlayer: false,
        audioVersePlaying: null,
      ));
      return;
    }
    add(PlayAudioVerse(audioVerse: nextVerse));
  }

  void _onPreviousAudioVerse(
    PreviousAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    final index = state.listAudioVerses?.indexOf(state.audioVersePlaying);
    if (index == null) return;
    if (index - 1 < 0) return;
    final previousVerse = state.listAudioVerses?[index - 1];
    if (previousVerse == null) return;
    add(PlayAudioVerse(audioVerse: previousVerse));
  }

  Future<void> _onPauseAudioVerse(
    PauseAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    await _audioPlayer.pause();
  }

  Future<void> _onStopAudioVerse(
    StopAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    await _audioPlayer.stop();
    emit(state.copyWith(
      audioVersePlaying: null,
      playerState: _audioPlayer.state,
      isShowBottomNavPlayer: false,
    ));
  }

  Future<void> _onResumeAudioVerse(
    ResumeAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    await _audioPlayer.resume();
  }

  Future<void> _onSeekAudioVerse(
    SeekAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    await _audioPlayer.seek(state.position + event.position);
  }

  Future<void> _onSetVolumeAudioVerse(
    SetVolumeAudioVerse event,
    Emitter<AudioVerseState> emit,
  ) async {
    await _audioPlayer.setVolume(event.volume);
  }

  void _onStreamAudioStateEvent(
    StreamAudioStateEvent event,
    Emitter<AudioVerseState> emit,
  ) async {
    emit(state.copyWith(
      playerState: event.state,
    ));
  }

  void _onStreamPositionStateEvent(
    StreamAudioPositionEvent event,
    Emitter<AudioVerseState> emit,
  ) async {
    emit(state.copyWith(
      position: event.position,
    ));
  }

  void _onStreamDurationStateEvent(
    StreamAudioDurationEvent event,
    Emitter<AudioVerseState> emit,
  ) async {
    emit(state.copyWith(
      duration: event.duration,
    ));
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _playerPositionSubscription?.cancel();
    _playerDurationSubscription?.cancel();
    _playerCompletionSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
