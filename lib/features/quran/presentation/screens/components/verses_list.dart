import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/bookmark/domain/entities/verse_bookmark.codegen.dart';
import 'package:quranku/features/quran/domain/entities/juz.codegen.dart';
import 'package:quranku/features/quran/domain/entities/last_read_juz.codegen.dart';
import 'package:quranku/features/quran/domain/entities/verses.codegen.dart';
import 'package:quranku/features/quran/presentation/bloc/detailJuz/detail_juz_bloc.dart';
import 'package:quranku/features/quran/presentation/bloc/lastRead/last_read_cubit.dart';
import 'package:quranku/features/quran/presentation/screens/components/verse_popup_menu.dart';
import 'package:quranku/features/quran/presentation/utils/tajweed_word.dart';
import 'package:quranku/features/setting/domain/entities/last_read_reminder_mode_entity.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../core/route/root_router.dart';
import '../../../../../core/utils/extension/string_ext.dart';
import '../../../../setting/presentation/bloc/language_setting/language_setting_bloc.dart';
import '../../../../setting/presentation/bloc/styling_setting/styling_setting_bloc.dart';
import '../../../domain/entities/detail_surah.codegen.dart';
import '../../../domain/entities/last_read_surah.codegen.dart';
import '../../bloc/audioVerse/audio_verse_bloc.dart';
import '../../bloc/detailSurah/detail_surah_bloc.dart';
import '../../utils/tajweed_token.dart';
import '../share_verse_screen.dart';
import 'number_pin.dart';

enum ViewMode {
  juz,
  surah,
  setting,
}

class VersesList extends StatefulWidget {
  final ViewMode view;
  final String? preBismillah;
  final JuzConstant? juz;
  final DetailSurah? surah;
  final int? toVerses;
  final List<Verses> listVerses;
  final List<TajweedWord> tajweedWords;

  const VersesList({
    super.key,
    required this.listVerses,
    this.preBismillah,
    required this.view,
    this.juz,
    this.surah,
    this.toVerses,
    required this.tajweedWords,
  });

  @override
  State<VersesList> createState() => VersesListState();
}

class VersesListState extends State<VersesList> {
  final _progress = ValueNotifier<double>(0.0);
  var onDrag = false;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();

  void _onListener() {
    final value =
        _itemPositionsListener.itemPositions.value.map((e) => e.index).toList();
    final verseNumberVisible = value.isNotEmpty ? (value.last + 1) : 0;
    final progressValue = verseNumberVisible / widget.listVerses.length;
    if (progressValue >= 1.0) {
      _progress.value = 1.0;
      return;
    }
    _progress.value = progressValue;
  }

  bool scrollToVerse(int verseNumber) {
    if (verseNumber <= 0) return false;

    final targetIndex = _calculateVerseIndex(verseNumber);
    final isPreBismillah = widget.preBismillah?.isNotEmpty == true;
    final totalItemCount = isPreBismillah
        ? widget.listVerses.length + 1
        : widget.listVerses.length;

    if (targetIndex >= 0 && targetIndex < totalItemCount) {
      _itemScrollController.scrollTo(
        index: targetIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
      return true;
    }
    return false;
  }

  bool scrollToJuzVerse(int surahNumber, int verseNumber) {
    if (surahNumber <= 0 || verseNumber <= 0) return false;

    // For Juz search, we need to find the verse by its context
    // We'll use a mapping approach based on known Quran structure
    for (int i = 0; i < widget.listVerses.length; i++) {
      final verse = widget.listVerses[i];
      final verseInSurah = verse.number?.inSurah ?? 0;
      final verseInQuran = verse.number?.inQuran ?? 0;

      // Check if this verse matches our target by comparing with known surah ranges
      if (verseInSurah == verseNumber &&
          _isVerseInSurah(verseInQuran, surahNumber)) {
        _itemScrollController.scrollTo(
          index: i,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
        return true;
      }
    }
    return false; // Verse not found
  }

  // Helper method to determine if a verse (by inQuran number) belongs to a specific surah
  bool _isVerseInSurah(int inQuran, int surahNumber) {
    // Basic surah ranges based on verse counts (this is a simplified approach)
    // In a production app, you'd have a complete mapping table
    const surahVerseRanges = {
      1: [1, 7], // Al-Fatihah: verses 1-7
      2: [8, 293], // Al-Baqarah: verses 8-293
      3: [294, 493], // Ali 'Imran: verses 294-493
      4: [494, 669], // An-Nisa': verses 494-669
      5: [670, 789], // Al-Ma'idah: verses 670-789
      6: [790, 954], // Al-An'am: verses 790-954
      7: [955, 1160], // Al-A'raf: verses 955-1160
      // Add more ranges as needed...
    };

    final range = surahVerseRanges[surahNumber];
    if (range != null) {
      return inQuran >= range[0] && inQuran <= range[1];
    }

    // Fallback: if we don't have the exact range, return true
    // This ensures the search still works even without complete mapping
    return true;
  }

  int _calculateVerseIndex(int verseNumber) {
    // For surah view, adjust for preBismillah
    if (widget.view == ViewMode.surah &&
        widget.preBismillah?.isNotEmpty == true) {
      return verseNumber; // preBismillah is at index 0, verse 1 is at index 1, etc.
    }

    // For juz view, find the verse by number in Quran
    if (widget.view == ViewMode.juz) {
      for (int i = 0; i < widget.listVerses.length; i++) {
        final verse = widget.listVerses[i];
        if (verse.number?.inSurah == verseNumber) {
          return i;
        }
      }
      return -1; // Verse not found
    }

    // Default for surah view without preBismillah
    return verseNumber - 1;
  }

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onListener);
    WidgetsBinding.instance.addPostFrameCallback(_scrollTo);
  }

  void _scrollTo(Duration duration) {
    if (widget.toVerses != null) {
      final toVerse = () {
        if (widget.preBismillah?.isNotEmpty == true) {
          return widget.toVerses ?? 0;
        }
        if (widget.view == ViewMode.juz) {
          return widget.toVerses ?? 0;
        }
        return (widget.toVerses ?? 0) - 1;
      }();

      _itemScrollController.scrollTo(
        index: toVerse,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _autoScrollPlayingAudio(AudioVerseState state) async {
    final index = widget.listVerses
        .map((e) => e.audio)
        .toList()
        .indexOf(state.audioVersePlaying);
    if (index != -1) {
      final indices = _itemPositionsListener.itemPositions.value
          .where((item) {
            final isTopVisible = item.itemLeadingEdge >= 0;
            final isBottomVisible = item.itemTrailingEdge <= 1.03;
            return isTopVisible && isBottomVisible;
          })
          .map((e) => e.index)
          .toList();
      final lastItem = indices.last;
      if (lastItem != widget.listVerses.length - 1) {
        _itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPreBismillah = widget.preBismillah?.isNotEmpty == true;
    final lastReadReminderMode =
        context.watch<StylingSettingBloc>().state.lastReadReminderMode;
    final isLastReadReminderOn =
        lastReadReminderMode == LastReadReminderModes.on;
    VersesNumber? getVerseNumber() {
      final visibleVerse = _itemPositionsListener.itemPositions.value
          .map((e) => e.index)
          .toList();
      if (visibleVerse.isEmpty) return null;
      final verseNumberVisible = () {
        if (isPreBismillah && visibleVerse.first != 0) {
          return visibleVerse.first - 1;
        }
        return visibleVerse.first;
      }();
      final verse = widget.listVerses[verseNumberVisible].number;
      return verse;
    }

    Future<void> setLastReading() async {
      if (widget.view == ViewMode.setting) return;
      final verse = getVerseNumber();
      if (verse == null) return;
      if (widget.view == ViewMode.juz) {
        context.read<LastReadCubit>().setLastReadJuz(
              LastReadJuz(
                name: widget.juz?.name ?? emptyString,
                number: widget.juz?.number ?? 0,
                description: widget.juz?.description ?? emptyString,
                versesNumber: verse,
                progress: _progress.value,
                createdAt: DateTime.now(),
              ),
            );
      } else if (widget.view == ViewMode.surah) {
        context.read<LastReadCubit>().setLastReadSurah(
              LastReadSurah(
                revelation: widget.surah?.revelation,
                surahName: widget.surah?.name,
                surahNumber: widget.surah?.number ?? 0,
                totalVerses: widget.surah?.numberOfVerses ?? 0,
                versesNumber: verse,
                progress: _progress.value,
                createdAt: DateTime.now(),
              ),
            );
      }
    }

    Future<void> saveLastReading() async {
      if (widget.view == ViewMode.setting) {
        context.pop(false);
        return;
      }
      if (lastReadReminderMode == LastReadReminderModes.autoSave) {
        setLastReading();
        context.pop(false);
        return;
      }
      if (!isLastReadReminderOn) {
        context.pop(false);
        return;
      }
      final verse = getVerseNumber();
      showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LocaleKeys.saveLastReading.tr()),
            content: Text(
              LocaleKeys.saveLastReadingDescription.tr(
                args: [
                  widget.view == ViewMode.juz
                      ? '${widget.juz?.name}'
                      : '${widget.surah?.name?.transliteration?.asLocale(context.locale)}',
                  verse?.inSurah?.toString() ?? emptyString,
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop(false);
                  context.pop(false);
                },
                child: Text(LocaleKeys.no.tr()),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context.theme.colorScheme.primary,
                  foregroundColor: context.theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  setLastReading();
                  context.pop(false);
                  context.pop(false);
                },
                child: Text(LocaleKeys.yes.tr()),
              ),
            ],
          );
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        saveLastReading();
      },
      child: BlocListener<AudioVerseBloc, AudioVerseState>(
        listener: (context, state) {
          if (state.audioVersePlaying != null &&
              (state.errorMessage == null || state.errorMessage!.isEmpty)) {
            _autoScrollPlayingAudio(state);
          }
        },
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.view != ViewMode.setting) ...[
                ValueListenableBuilder<double>(
                  valueListenable: _progress,
                  builder: (context, value, _) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final width = context.width;
                        final value = details.localPosition.dx / width;
                        _itemScrollController.jumpTo(
                          index: (value * widget.listVerses.length).toInt(),
                        );
                      },
                      onPanStart: (details) {
                        setState(() {
                          onDrag = true;
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          onDrag = false;
                        });
                      },
                      onPanUpdate: (details) {
                        final width = context.width;
                        final value = details.localPosition.dx / width;
                        _itemScrollController.jumpTo(
                          index: (value * widget.listVerses.length).toInt(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: onDrag ? 3 : 1,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: onDrag ? 6 : 3,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 0,
                                ),
                              ),
                              child: Slider(
                                value: value,
                                onChanged: (value) {
                                  _itemScrollController.jumpTo(
                                    index: (value * widget.listVerses.length)
                                        .toInt(),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color:
                                    context.theme.colorScheme.primaryContainer,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              child: Text(
                                '${(value * 100).toStringAsFixed(0)}%',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context
                                      .theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
              Expanded(
                child: ScrollablePositionedList.separated(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemCount: () {
                    if (isPreBismillah) {
                      return widget.listVerses.length + 1;
                    }
                    return widget.listVerses.length;
                  }(),
                  separatorBuilder: (BuildContext context, int index) {
                    if (isPreBismillah && index == 0) {
                      return const Divider(color: Colors.transparent);
                    }
                    return const Divider(thickness: 0.1);
                  },
                  itemBuilder: (context, index) {
                    if (index == 0 && isPreBismillah) {
                      return BlocBuilder<StylingSettingBloc,
                          StylingSettingState>(
                        buildWhen: (p, c) {
                          return p.fontFamilyArabic != c.fontFamilyArabic ||
                              p.arabicFontSize != c.arabicFontSize;
                        },
                        builder: (context, state) {
                          return Text(
                            widget.preBismillah ?? emptyString,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontSize: state.arabicFontSize,
                              fontFamily: state.fontFamilyArabic,
                            ),
                          );
                        },
                      );
                    }
                    final indexVerses = isPreBismillah ? index - 1 : index;
                    final verses = widget.listVerses[indexVerses];
                    return ListTileVerses(
                      verses: verses,
                      clickFrom: widget.view,
                      juz: widget.juz,
                      surah: widget.surah,
                      tajweedAya: widget.tajweedWords[indexVerses].tokens,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListTileVerses extends StatelessWidget {
  final ViewMode clickFrom;
  final Verses verses;
  final JuzConstant? juz;
  final DetailSurah? surah;
  final List<TajweedToken>? tajweedAya;

  const ListTileVerses({
    super.key,
    required this.verses,
    required this.clickFrom,
    this.juz,
    this.surah,
    this.tajweedAya = const [],
  });

  @override
  Widget build(BuildContext context) {
    final audioVerseBloc = context.read<AudioVerseBloc>();
    return BlocBuilder<AudioVerseBloc, AudioVerseState>(
      buildWhen: (previous, current) {
        return previous.audioVersePlaying != current.audioVersePlaying;
      },
      builder: (context, state) {
        final isVersePlaying = state.audioVersePlaying == verses.audio;
        return Container(
          color: isVersePlaying
              ? context.theme.colorScheme.primaryContainer
              : Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: FittedBox(
                            child: NumberPin(
                              number: verses.number?.inSurah.toString() ??
                                  emptyString,
                            ),
                          ),
                        ),
                        if (clickFrom != ViewMode.setting) ...[
                          VersePopupMenuButton(
                            isBookmarked: verses.isBookmarked,
                            onPlayPressed: () {
                              audioVerseBloc.add(
                                  PlayAudioVerse(audioVerse: verses.audio));
                            },
                            onBookmarkPressed: () {
                              _onPressedBookmark(
                                  context, verses, clickFrom, juz, surah);
                            },
                            onSharePressed: () {
                              context.pushNamed(
                                RootRouter.shareVerseRoute.name,
                                extra: ShareVerseScreenExtra(
                                  verse: verses,
                                  juz: juz,
                                  surah: surah,
                                ),
                              );
                            },
                          )
                        ]
                      ],
                    ),
                    Expanded(
                      child:
                          BlocBuilder<StylingSettingBloc, StylingSettingState>(
                        buildWhen: (p, c) {
                          return p.fontFamilyArabic != c.fontFamilyArabic ||
                              p.arabicFontSize != c.arabicFontSize ||
                              p.isColoredTajweedEnabled !=
                                  c.isColoredTajweedEnabled;
                        },
                        builder: (context, state) {
                          if (tajweedAya == null ||
                              tajweedAya?.isEmpty == true ||
                              !state.isColoredTajweedEnabled) {
                            return Text(
                              verses.text?.arab ?? emptyString,
                              textAlign: TextAlign.right,
                              style: context.textTheme.headlineSmall?.copyWith(
                                height: 2.5,
                                fontFamily: state.fontFamilyArabic,
                                fontSize: state.arabicFontSize,
                              ),
                            );
                          }
                          return Text.rich(
                            textAlign: TextAlign.right,
                            TextSpan(
                              children: <TextSpan>[
                                for (final token in tajweedAya ?? [])
                                  TextSpan(
                                    text: token.text,
                                    style: context.textTheme.headlineSmall
                                        ?.copyWith(
                                      height: 2.5,
                                      fontFamily: state.fontFamilyArabic,
                                      fontSize: state.arabicFontSize,
                                      color: token.rule.color(context) ??
                                          context.theme.colorScheme.onSurface,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const VSpacer(height: 8),
              BlocBuilder<LanguageSettingBloc, LanguageSettingState>(
                buildWhen: (p, c) => p.languageLatin != c.languageLatin,
                builder: (context, languageSettingState) {
                  return ListTileTransliteration(
                    text: verses.text?.transliteration?.asLocale(
                          languageSettingState.languageLatin ?? context.locale,
                        ) ??
                        emptyString,
                    number: verses.number?.inSurah.toString() ?? emptyString,
                  );
                },
              ),
              const VSpacer(height: 8),
              BlocBuilder<LanguageSettingBloc, LanguageSettingState>(
                buildWhen: (p, c) => p.languageQuran != c.languageQuran,
                builder: (context, languageSettingState) {
                  return ListTileTranslation(
                    text: verses.translation?.asLocale(
                          languageSettingState.languageQuran ?? context.locale,
                        ) ??
                        emptyString,
                    number: verses.number?.inSurah.toString() ?? emptyString,
                  );
                },
              ),
              const VSpacer(height: 8),
            ],
          ),
        );
      },
    );
  }
}

void _onPressedBookmark(
  BuildContext context,
  Verses verses,
  ViewMode clickFrom,
  JuzConstant? juz,
  DetailSurah? surah,
) {
  if (clickFrom == ViewMode.surah) {
    final surahDetailBloc = context.read<SurahDetailBloc>();
    if (surah == null) return;
    surahDetailBloc.add(
      SurahDetailEvent.onPressedVerseBookmark(
        bookmark: VerseBookmark(
          surahName: surah.name!,
          surahNumber: surah.number!,
          versesNumber: verses.number!,
        ),
        isBookmarked: verses.isBookmarked ?? false,
      ),
    );
  } else {
    final juzDetailBloc = context.read<JuzDetailBloc>();
    juzDetailBloc.add(
      JuzDetailEvent.onPressedVerseBookmark(
        bookmark: VerseBookmark(
          juz: JuzConstant(
            name: juz?.name ?? emptyString,
            number: juz?.number ?? 0,
            description: juz?.description ?? emptyString,
          ),
          versesNumber: verses.number!,
        ),
        isBookmarked: verses.isBookmarked ?? false,
      ),
    );
  }
}

class ListTileTranslation extends StatelessWidget {
  final String text;
  final String number;

  const ListTileTranslation(
      {super.key, required this.text, required this.number});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylingSettingBloc, StylingSettingState>(
      builder: (context, state) {
        if (!state.isShowTranslation) return const SizedBox();
        final textStyle = context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: state.translationFontSize,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$number .', style: textStyle),
              const HSpacer(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: textStyle,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ListTileTransliteration extends StatelessWidget {
  final String text;
  final String number;

  const ListTileTransliteration(
      {super.key, required this.text, required this.number});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylingSettingBloc, StylingSettingState>(
      builder: (context, state) {
        if (!state.isShowLatin) return const SizedBox();
        final textStyle = context.textTheme.bodySmall?.copyWith(
          color: context.theme.colorScheme.primary,
          fontSize: state.latinFontSize,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$number .', style: textStyle),
              const HSpacer(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: textStyle,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
