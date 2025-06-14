import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/detail_surah.codegen.dart';
import '../../../domain/entities/juz.codegen.dart';
import '../../../domain/entities/verses.codegen.dart';

part 'share_verse_bloc.freezed.dart';
part 'share_verse_event.dart';
part 'share_verse_state.dart';

@injectable
class ShareVerseBloc extends Bloc<ShareVerseEvent, ShareVerseState> {
  ShareVerseBloc() : super(const ShareVerseState()) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    on<_OnInit>(_onInit);
    on<_OnChangeBackgroundColor>(_onChangeBackgroundColor);
    on<_OnChangeRandomImageUrl>(_onChangeRandomImageUrl);
    on<_OnChangeArabicFontSize>(_onChangeArabicFontSize);
    on<_OnChangeLatinFontSize>(_onChangeLatinFontSize);
    on<_OnChangeTranslationFontSize>(_onChangeTranslationFontSize);
    on<_OnToggleArabicVisibility>(_onToggleArabicVisibility);
    on<_OnToggleLatinVisibility>(_onToggleLatinVisibility);
    on<_OnToggleTranslationVisibility>(_onToggleTranslationVisibility);
    on<_OnSharePressed>(_onSharePressed);
    on<_OnPickBackgroundImage>(_onPickBackgroundImage);
  }

  void _onInit(
    _OnInit event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(
      verse: event.verse,
      juz: event.juz,
      surah: event.surah,
    ));
  }

  void _onChangeBackgroundColor(
    _OnChangeBackgroundColor event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(
      backgroundColor: event.color,
      randomImageUrl: null,
      backgroundImagePath: null,
    ));
  }

  void _onChangeRandomImageUrl(
    _OnChangeRandomImageUrl event,
    Emitter<ShareVerseState> emit,
  ) {
    final randomString = DateTime.now().millisecondsSinceEpoch.toString();
    if (state.backgroundColor != null) {
      emit(state.copyWith(
        backgroundColor: null,
        backgroundImagePath: null,
      ));
      return;
    }
    emit(state.copyWith(
      randomImageUrl: randomString,
      backgroundColor: null,
      backgroundImagePath: null,
    ));
  }

  void _onChangeTranslationFontSize(
    _OnChangeTranslationFontSize event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(translationFontSize: event.fontSize));
  }

  void _onChangeArabicFontSize(
    _OnChangeArabicFontSize event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(arabicFontSize: event.fontSize));
  }

  void _onChangeLatinFontSize(
    _OnChangeLatinFontSize event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(latinFontSize: event.fontSize));
  }

  void _onToggleArabicVisibility(
    _OnToggleArabicVisibility event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(isArabicVisible: event.value ?? false));
  }

  void _onToggleLatinVisibility(
    _OnToggleLatinVisibility event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(isLatinVisible: event.value ?? false));
  }

  void _onToggleTranslationVisibility(
    _OnToggleTranslationVisibility event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(isTranslationVisible: event.value ?? false));
  }

  void _onSharePressed(
    _OnSharePressed event,
    Emitter<ShareVerseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final boundary = event.boundary;
    final image = await boundary?.toImage(pixelRatio: 3.0);
    final byteData = await image?.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();
    if (pngBytes == null) {
      return;
    }
    emit(state.copyWith(isLoading: false));
    SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            pngBytes,
            name: 'verse-story.png',
            mimeType: 'image/png',
          ),
        ],
      ),
    );
  }

  // handle custom background image selection
  void _onPickBackgroundImage(
    _OnPickBackgroundImage event,
    Emitter<ShareVerseState> emit,
  ) {
    emit(state.copyWith(
      backgroundImagePath: event.path,
      backgroundColor: null,
      randomImageUrl: null,
    ));
  }

  @override
  Future<void> close() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return super.close();
  }
}
