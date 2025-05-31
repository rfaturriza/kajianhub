import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/features/bookmark/domain/entities/verse_bookmark.codegen.dart';
import 'package:quranku/features/bookmark/domain/usecases/add_verse_bookmark_usecase.dart';
import 'package:quranku/features/bookmark/domain/usecases/delete_verse_bookmark_usecase.dart';
import 'package:quranku/features/bookmark/domain/usecases/get_list_verses_bookmark_usecase.dart';

import '../../../../../core/constants/hive_constants.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/extension/string_ext.dart';
import '../../../../bookmark/domain/entities/juz_bookmark.codegen.dart';
import '../../../../bookmark/domain/usecases/add_juz_bookmark_usecase.dart';
import '../../../../bookmark/domain/usecases/delete_juz_bookmark_usecase.dart';
import '../../../../bookmark/domain/usecases/get_list_juz_bookmark_usecase.dart';
import '../../../domain/entities/detail_juz.codegen.dart';
import '../../../domain/usecases/get_detail_juz_usecase.dart';
import '../../screens/components/verses_list.dart';
import '../../utils/helper_tajweed.dart';

part 'detail_juz_bloc.freezed.dart';

part 'detail_juz_event.dart';

part 'detail_juz_state.dart';

@injectable
class JuzDetailBloc extends Bloc<JuzDetailEvent, JuzDetailState> {
  final GetDetailJuzUseCase getDetailJuz;
  final AddJuzBookmarkUseCase addJuzBookmark;
  final DeleteJuzBookmarkUseCase deleteJuzBookmark;
  final GetListJuzBookmarkUseCase getListJuzBookmark;
  final GetListVersesBookmarkUseCase getListVerseBookmark;
  final AddVerseBookmarkUseCase addVerseBookmark;
  final DeleteVerseBookmarkUseCase deleteVerseBookmark;

  JuzDetailBloc({
    required this.getDetailJuz,
    required this.addJuzBookmark,
    required this.deleteJuzBookmark,
    required this.getListJuzBookmark,
    required this.getListVerseBookmark,
    required this.addVerseBookmark,
    required this.deleteVerseBookmark,
  }) : super(const JuzDetailState()) {
    on<FetchJuzDetailEvent>(_onJuzFetchDetail);
    on<OnPressedBookmarkEvent>(_onPressedBookmark);
    on<OnPressedVerseBookmarkEvent>(_onPressedVerseBookmark);
  }

  void _onJuzFetchDetail(FetchJuzDetailEvent event, emit) async {
    if (event.juzNumber == null) {
      emit(state.copyWith(
        detailJuzResult: left(
          const GeneralFailure(message: 'Juz Empty'),
        ),
      ));
    }
    emit(state.copyWith(isLoading: true));
    final failureOrJuzBookmark = await getListJuzBookmark(NoParams());
    final isBookmarked = failureOrJuzBookmark.fold(
      (failure) => false,
      (surahBookmark) => surahBookmark.any(
        (element) => element.number == event.juzNumber,
      ),
    );
    final failureOrJuz = await getDetailJuz(Params(number: event.juzNumber!));
    if (failureOrJuz.isLeft()) {
      emit(state.copyWith(
        isLoading: false,
        detailJuzResult: failureOrJuz,
      ));
      return;
    }
    final failureOrVerseBookmark = await getListVerseBookmark(NoParams());
    final Either<Failure, DetailJuz?> addVerseBookmarked =
        failureOrVerseBookmark.fold(
      (failure) => left(failure),
      (verseBookmark) {
        final detailJuz = failureOrJuz.asRight();
        final updatedVerses = detailJuz?.verses?.map((verse) {
          if (verseBookmark.any((e) =>
              e.versesNumber.inSurah == verse.number?.inSurah &&
              e.versesNumber.inQuran == verse.number?.inQuran)) {
            return verse.copyWith(isBookmarked: true);
          }
          return verse.copyWith(isBookmarked: false);
        }).toList();
        return right(
          detailJuz?.copyWith(
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
        ViewMode.juz,
        event.juzNumber.toString(),
      );
      final updatedDetailSurah = addVerseBookmarked.fold(
        (failure) => null,
        (detailSurah) => detailSurah?.copyWith(tajweedWords: loadTajweedVerses),
      );
      emit(
        state.copyWith(
          isLoading: false,
          detailJuzResult: right(updatedDetailSurah),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoading: false,
        detailJuzResult: addVerseBookmarked,
      ),
    );
  }

  void _onPressedBookmark(OnPressedBookmarkEvent event, emit) async {
    if (event.juzBookmark == null) return;

    if (event.isBookmarked) {
      final deleteResult = await deleteJuzBookmark(
        DeleteJuzBookmarkParams(event.juzBookmark!),
      );

      final Either<Failure, DetailJuz?>? stateUpdateBookmark =
          state.detailJuzResult?.fold(
        (failure) => left(failure),
        (detailJuz) => right(
          detailJuz?.copyWith(isBookmarked: false),
        ),
      );

      emit(
        state.copyWith(
          detailJuzResult: stateUpdateBookmark,
          deleteBookmarkResult: deleteResult,
        ),
      );
      return;
    }
    final saveResult = await addJuzBookmark(
      AddJuzBookmarkParams(event.juzBookmark!),
    );

    final Either<Failure, DetailJuz?>? stateUpdateBookmark =
        state.detailJuzResult?.fold(
      (failure) => left(failure),
      (detailJuz) => right(
        detailJuz?.copyWith(isBookmarked: true),
      ),
    );

    emit(
      state.copyWith(
        saveBookmarkResult: saveResult,
        detailJuzResult: stateUpdateBookmark,
      ),
    );
  }

  void _onPressedVerseBookmark(OnPressedVerseBookmarkEvent event, emit) async {
    if (event.bookmark == null) return;

    if (event.isBookmarked) {
      final deleteResult = await deleteVerseBookmark(
        DeleteVerseBookmarkParams(event.bookmark!),
      );

      final Either<Failure, DetailJuz?>? stateUpdateBookmark = state
          .detailJuzResult
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
                event.bookmark?.versesNumber.inSurah.toString() ?? emptyString),
          ),
          saveVerseBookmarkResult: null,
          detailJuzResult: stateUpdateBookmark,
        ),
      );
      return;
    }
    final saveResult = await addVerseBookmark(
      AddVerseBookmarkParams(event.bookmark!),
    );

    final Either<Failure, DetailJuz?>? stateUpdateBookmark =
        state.detailJuzResult?.fold((failure) => left(failure), (detailSurah) {
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
              event.bookmark?.versesNumber.inSurah.toString() ?? emptyString),
        ),
        deleteBookmarkResult: null,
        detailJuzResult: stateUpdateBookmark,
      ),
    );
  }
}
