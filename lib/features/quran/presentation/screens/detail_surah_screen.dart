import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quranku/core/components/error_screen.dart';
import 'package:quranku/core/components/loading_screen.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/bookmark/domain/entities/surah_bookmark.codegen.dart';
import 'package:quranku/features/quran/presentation/bloc/audioVerse/audio_verse_bloc.dart';
import 'package:quranku/features/quran/presentation/screens/components/app_bar_detail_screen.dart';
import 'package:quranku/features/quran/presentation/screens/components/bottom_nav_player.dart';
import 'package:quranku/features/quran/presentation/screens/components/search_verse_dialog.dart';
import 'package:quranku/features/quran/presentation/screens/components/verses_list.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../../injection.dart';
import '../../domain/entities/surah.codegen.dart';
import '../bloc/detailSurah/detail_surah_bloc.dart';

class DetailSurahScreenExtra {
  final Surah? surah;
  final int? jumpToVerse;

  const DetailSurahScreenExtra({
    this.surah,
    this.jumpToVerse,
  });
}

class DetailSurahScreen extends StatelessWidget {
  final Surah? surah;
  final int? jumpToVerse;

  const DetailSurahScreen({
    super.key,
    this.surah,
    this.jumpToVerse,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SurahDetailBloc>(
          create: (context) => sl<SurahDetailBloc>()
            ..add(
              FetchSurahDetailEvent(
                surahNumber: surah?.number,
              ),
            ),
        ),
        BlocProvider<AudioVerseBloc>(
          create: (context) => sl<AudioVerseBloc>(),
        ),
      ],
      child: _DetailSurahScaffold(
        surah: surah,
        jumpToVerse: jumpToVerse,
      ),
    );
  }
}

class _DetailSurahScaffold extends StatefulWidget {
  final Surah? surah;
  final int? jumpToVerse;

  const _DetailSurahScaffold({
    this.surah,
    this.jumpToVerse,
  });

  @override
  State<_DetailSurahScaffold> createState() => _DetailSurahScaffoldState();
}

class _DetailSurahScaffoldState extends State<_DetailSurahScaffold> {
  final GlobalKey<VersesListState> _versesListKey =
      GlobalKey<VersesListState>();

  void _showSearchDialog(BuildContext context, int maxVerses) {
    showDialog(
      context: context,
      builder: (context) => SearchVerseDialog(
        maxVerses: maxVerses,
        onVerseSelected: (verseNumber) {
          final found =
              _versesListKey.currentState?.scrollToVerse(verseNumber) ?? false;
          if (!found) {
            context.showErrorToast(LocaleKeys.verseNotFound.tr());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioBloc = context.watch<AudioVerseBloc>();
    final surahDetailBloc = context.read<SurahDetailBloc>();
    final surahName =
        widget.surah?.name?.transliteration?.asLocale(context.locale);
    return Scaffold(
      body: BlocConsumer<SurahDetailBloc, SurahDetailState>(
        listener: (context, state) {
          if (state.saveBookmarkResult?.isLeft() ?? false) {
            final message = state.saveBookmarkResult?.asLeft().message;
            context.showErrorToast(message ?? emptyString);
          } else if (state.deleteBookmarkResult?.isLeft() ?? false) {
            final message = state.saveBookmarkResult?.asLeft().message;
            context.showErrorToast(message ?? emptyString);
          } else if (state.saveVerseBookmarkResult?.isRight() ?? false) {
            final verseNumber = state.saveVerseBookmarkResult?.asRight();
            context
                .showInfoToast(LocaleKeys.successAddingVersesBookmark.tr(args: [
              surahName ?? emptyString,
              verseNumber ?? emptyString,
            ]));
          } else if (state.deleteVerseBookmarkResult?.isRight() ?? false) {
            final verseNumber = state.deleteVerseBookmarkResult?.asRight();
            context.showInfoToast(
                LocaleKeys.successRemovingVersesBookmark.tr(args: [
              surahName ?? emptyString,
              verseNumber ?? emptyString,
            ]));
          } else if (state.saveVerseBookmarkResult?.isLeft() ?? false) {
            final message = state.saveVerseBookmarkResult?.asLeft().message;
            context.showErrorToast(message ?? emptyString);
          } else if (state.deleteVerseBookmarkResult?.isLeft() ?? false) {
            final message = state.deleteVerseBookmarkResult?.asLeft().message;
            context.showErrorToast(message ?? emptyString);
          } else if (state.detailSurahResult?.isRight() ?? false) {
            final verses = state.detailSurahResult?.asRight()?.verses;
            context.read<AudioVerseBloc>().add(
                  AudioVerseEvent.setListAudioVerse(
                      listAudioVerses: verses?.map((e) => e.audio).toList()),
                );
          }
        },
        builder: (context, state) {
          final detailSurah = state.detailSurahResult?.asRight();
          return NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, _) {
              return [
                SliverAppBarDetailScreen(
                  isBookmarked: detailSurah?.isBookmarked ?? false,
                  title: surahName ?? emptyString,
                  onPressedSearch: (state.detailSurahResult?.isRight() ?? false)
                      ? () => _showSearchDialog(
                          context, detailSurah?.numberOfVerses ?? 0)
                      : null,
                  onPressedBookmark: (state.detailSurahResult?.isRight() ??
                          false)
                      ? () {
                          final detailSurah =
                              state.detailSurahResult?.asRight();
                          final surahBookmark = SurahBookmark(
                            surahName: detailSurah!.name!,
                            surahNumber: detailSurah.number!,
                            revelation: detailSurah.revelation!,
                            totalVerses: detailSurah.numberOfVerses ?? 0,
                          );
                          surahDetailBloc.add(
                            OnPressedBookmarkEvent(
                              surahBookmark: surahBookmark,
                              isBookmarked: detailSurah.isBookmarked ?? false,
                            ),
                          );
                        }
                      : null,
                ),
              ];
            },
            body: BlocBuilder<SurahDetailBloc, SurahDetailState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const LoadingScreen();
                } else if (state.detailSurahResult?.isRight() ?? false) {
                  final verses = detailSurah?.verses;

                  return VersesList(
                    key: _versesListKey,
                    toVerses: widget.jumpToVerse,
                    view: ViewMode.surah,
                    listVerses: verses ?? [],
                    tajweedWords: detailSurah?.tajweedWords ?? [],
                    surah: detailSurah,
                    preBismillah: detailSurah?.preBismillah?.text?.arab,
                  );
                } else if (state.detailSurahResult?.isLeft() ?? false) {
                  final failure = state.detailSurahResult?.asLeft();
                  return ErrorScreen(
                    message: failure?.message,
                    onRefresh: () {
                      surahDetailBloc.add(
                        FetchSurahDetailEvent(
                            surahNumber: widget.surah?.number),
                      );
                    },
                  );
                }
                return Container();
              },
            ),
          );
        },
      ),
      bottomNavigationBar: (audioBloc.state.isShowBottomNavPlayer)
          ? const BottomNavPlayer()
          : null,
    );
  }
}
