import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/juz_bookmark.codegen.dart';
import '../../../domain/entities/surah_bookmark.codegen.dart';
import '../../../domain/entities/verse_bookmark.codegen.dart';
import '../../../domain/usecases/get_list_juz_bookmark_usecase.dart';
import '../../../domain/usecases/get_list_surah_bookmark_usecase.dart';
import '../../../domain/usecases/get_list_verses_bookmark_usecase.dart';

part 'bookmark_bloc.freezed.dart';

part 'bookmark_event.dart';

part 'bookmark_state.dart';

@injectable
class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final GetListJuzBookmarkUseCase getListJuzBookmarkUseCase;
  final GetListSurahBookmarkUseCase getListSurahBookmarkUseCase;
  final GetListVersesBookmarkUseCase getListVersesBookmarkUseCase;

  BookmarkBloc(
    this.getListJuzBookmarkUseCase,
    this.getListSurahBookmarkUseCase,
    this.getListVersesBookmarkUseCase,
  ) : super(const BookmarkState()) {
    Future<void> onGetListVersesBookmark(Emitter<BookmarkState> emit) async {
      emit(state.copyWith(isLoading: true));
      final result = await getListVersesBookmarkUseCase(NoParams());
      emit(state.copyWith(isLoading: false, verseBookmarks: result));
    }

    Future<void> onGetListSurahBookmark(Emitter<BookmarkState> emit) async {
      emit(state.copyWith(isLoading: true));
      final result = await getListSurahBookmarkUseCase(NoParams());
      emit(state.copyWith(isLoading: false, surahBookmarks: result));
    }

    Future<void> onGetListJuzBookmark(Emitter<BookmarkState> emit) async {
      emit(state.copyWith(isLoading: true));
      final result = await getListJuzBookmarkUseCase(NoParams());
      emit(state.copyWith(isLoading: false, juzBookmarks: result));
    }

    Future<void> onChangedExpansionPanel(
      Emitter<BookmarkState> emit,
      int index,
      bool isExpanded,
    ) async {
      switch (index) {
        case BookmarkPanelConstant.verses:
          add(const BookmarkEvent.getListVersesBookmark());
          emit(state.copyWith(isExpandedVerses: isExpanded));
          break;
        case BookmarkPanelConstant.surah:
          add(const BookmarkEvent.getListSurahBookmark());
          emit(state.copyWith(isExpandedSurah: isExpanded));
          break;
        case BookmarkPanelConstant.juz:
          add(const BookmarkEvent.getListJuzBookmark());
          emit(state.copyWith(isExpandedJuz: isExpanded));
          break;
      }
    }

    on<BookmarkEvent>((event, emit) async {
      switch (event) {
        case _GetListVersesBookmark():
          await onGetListVersesBookmark(emit);
        case _GetListSurahBookmark():
          await onGetListSurahBookmark(emit);
        case _GetListJuzBookmark():
          await onGetListJuzBookmark(emit);
        case _OnChangedExpansionPanel(:final index, :final isExpanded):
          await onChangedExpansionPanel(emit, index, isExpanded);
      }
    });
  }
}
