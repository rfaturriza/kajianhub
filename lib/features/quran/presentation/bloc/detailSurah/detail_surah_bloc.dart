import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/features/bookmark/domain/entities/surah_bookmark.codegen.dart';
import 'package:quranku/features/bookmark/domain/usecases/delete_surah_bookmark_usecase.dart';
import 'package:quranku/features/quran/domain/entities/detail_surah.codegen.dart';

import '../../../../../core/constants/hive_constants.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/extension/string_ext.dart';
import '../../../../bookmark/domain/entities/verse_bookmark.codegen.dart';
import '../../../../bookmark/domain/usecases/add_surah_bookmark_usecase.dart';
import '../../../../bookmark/domain/usecases/add_verse_bookmark_usecase.dart';
import '../../../../bookmark/domain/usecases/delete_verse_bookmark_usecase.dart';
import '../../../../bookmark/domain/usecases/get_list_surah_bookmark_usecase.dart';
import '../../../../bookmark/domain/usecases/get_list_verses_bookmark_usecase.dart';
import '../../../domain/usecases/get_detail_surah_usecase.dart';
import '../../screens/components/verses_list.dart';
import '../../utils/helper_tajweed.dart';

part 'detail_surah_bloc.freezed.dart';

part 'detail_surah_event.dart';

part 'detail_surah_state.dart';

@injectable
class SurahDetailBloc extends Bloc<SurahDetailEvent, SurahDetailState> {
  final GetDetailSurahUseCase getDetailSurah;
  final AddSurahBookmarkUseCase addSurahBookmark;
  final DeleteSurahBookmarkUseCase deleteSurahBookmark;
  final GetListSurahBookmarkUseCase getListSurahBookmark;
  final GetListVersesBookmarkUseCase getListVerseBookmark;
  final AddVerseBookmarkUseCase addVerseBookmark;
  final DeleteVerseBookmarkUseCase deleteVerseBookmark;

  SurahDetailBloc({
    required this.getDetailSurah,
    required this.addSurahBookmark,
    required this.deleteSurahBookmark,
    required this.getListSurahBookmark,
    required this.getListVerseBookmark,
    required this.addVerseBookmark,
    required this.deleteVerseBookmark,
  }) : super(const SurahDetailState()) {
    on<FetchSurahDetailEvent>(_onSurahFetchDetail);
    on<OnPressedBookmarkEvent>(_onPressedBookmark);
    on<OnPressedVerseBookmarkEvent>(_onPressedVerseBookmark);
  }

  void _onSurahFetchDetail(FetchSurahDetailEvent event, emit) async {
    emit(state.copyWith(isLoading: true));
    final failureOrSurahBookmark = await getListSurahBookmark(NoParams());
    final isBookmarked = failureOrSurahBookmark.fold(
      (failure) => false,
      (surahBookmark) => surahBookmark.any(
        (element) => element.surahNumber == event.surahNumber,
      ),
    );
    final failureOrSurah = await getDetailSurah(
      Params(number: event.surahNumber ?? 1),
    );
    if (failureOrSurah.isLeft()) {
      emit(state.copyWith(
        isLoading: false,
        detailSurahResult: failureOrSurah,
      ));
      return;
    }
    final failureOrVerseBookmark = await getListVerseBookmark(NoParams());
    final Either<Failure, DetailSurah?> addVerseBookmarked =
        failureOrVerseBookmark.fold(
      (failure) => left(failure),
      (verseBookmark) {
        final detailSurah = failureOrSurah.asRight();
        final updatedVerses = detailSurah?.verses?.map((verse) {
          if (verseBookmark.any((e) =>
              e.versesNumber.inSurah == verse.number?.inSurah &&
              e.versesNumber.inQuran == verse.number?.inQuran)) {
            return verse.copyWith(isBookmarked: true);
          }
          return verse.copyWith(isBookmarked: false);
        }).toList();
        return right(
          detailSurah?.copyWith(
            verses: updatedVerses,
            isBookmarked: isBookmarked,
          ),
        );
      },
    );

    final settingBox = await Hive.openBox(HiveConst.settingBox);
    final isColoredTajweedEnabled =
        settingBox.get(HiveConst.tajweedStatusKey) ?? true;
    if (isColoredTajweedEnabled) {
      final loadTajweedVerses = await HelperTajweed.loadAyas(
        addVerseBookmarked.fold((l) => [], (r) => r?.verses ?? []),
        ViewMode.surah,
        event.surahNumber.toString(),
      );
      final updatedDetailSurah = addVerseBookmarked.fold(
        (failure) => null,
        (detailSurah) => detailSurah?.copyWith(tajweedWords: loadTajweedVerses),
      );
      emit(
        state.copyWith(
          isLoading: false,
          detailSurahResult: right(updatedDetailSurah),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        detailSurahResult: addVerseBookmarked,
      ),
    );
  }

  void _onPressedBookmark(OnPressedBookmarkEvent event, emit) async {
    if (event.surahBookmark == null) return;

    if (event.isBookmarked) {
      final deleteResult = await deleteSurahBookmark(
        DeleteSurahBookmarkParams(event.surahBookmark!),
      );

      final Either<Failure, DetailSurah?>? stateUpdateBookmark =
          state.detailSurahResult?.fold(
        (failure) => left(failure),
        (detailJuz) => right(
          detailJuz?.copyWith(isBookmarked: false),
        ),
      );

      emit(
        state.copyWith(
          detailSurahResult: stateUpdateBookmark,
          deleteBookmarkResult: deleteResult,
        ),
      );
      return;
    }
    final saveResult = await addSurahBookmark(
      AddSurahBookmarkParams(event.surahBookmark!),
    );

    final Either<Failure, DetailSurah?>? stateUpdateBookmark =
        state.detailSurahResult?.fold(
      (failure) => left(failure),
      (detailJuz) => right(
        detailJuz?.copyWith(isBookmarked: true),
      ),
    );

    emit(
      state.copyWith(
        saveBookmarkResult: saveResult,
        detailSurahResult: stateUpdateBookmark,
      ),
    );
  }

  void _onPressedVerseBookmark(OnPressedVerseBookmarkEvent event, emit) async {
    if (event.bookmark == null) return;

    if (event.isBookmarked) {
      final deleteResult = await deleteVerseBookmark(
        DeleteVerseBookmarkParams(event.bookmark!),
      );

      final Either<Failure, DetailSurah?>? stateUpdateBookmark = state
          .detailSurahResult
          ?.fold((failure) => left(failure), (detailSurah) {
        final updatedVerses = detailSurah?.verses?.map(
          (e) {
            if (e.number?.inSurah == event.bookmark?.versesNumber.inSurah) {
              return e.copyWith(isBookmarked: false);
            }
            return e;
          },
        ).toList();
        return right(detailSurah?.copyWith(verses: updatedVerses));
      });
      emit(
        state.copyWith(
          deleteVerseBookmarkResult: deleteResult.fold(
            (l) => left(l),
            (r) => right(
              event.bookmark?.versesNumber.inSurah.toString() ?? emptyString,
            ),
          ),
          saveVerseBookmarkResult: null,
          detailSurahResult: stateUpdateBookmark,
        ),
      );
      return;
    }
    final saveResult = await addVerseBookmark(
      AddVerseBookmarkParams(event.bookmark!),
    );

    final Either<Failure, DetailSurah?>? stateUpdateBookmark = state
        .detailSurahResult
        ?.fold((failure) => left(failure), (detailSurah) {
      final updatedVerses = detailSurah?.verses?.map(
        (e) {
          if (e.number?.inSurah == event.bookmark?.versesNumber.inSurah) {
            return e.copyWith(isBookmarked: true);
          }
          return e;
        },
      ).toList();
      return right(detailSurah?.copyWith(verses: updatedVerses));
    });

    emit(
      state.copyWith(
        saveVerseBookmarkResult: saveResult.fold(
          (l) => left(l),
          (r) => right(
            event.bookmark?.versesNumber.inSurah.toString() ?? emptyString,
          ),
        ),
        deleteBookmarkResult: null,
        detailSurahResult: stateUpdateBookmark,
      ),
    );
  }
}
