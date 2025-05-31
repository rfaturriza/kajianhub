import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/components/error_screen.dart';
import 'package:quranku/core/components/search_box.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/quran/presentation/bloc/surah/surah_bloc.dart';

import '../../../../../core/route/root_router.dart';
import '../../../../../core/utils/extension/string_ext.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../domain/entities/surah.codegen.dart';
import '../detail_surah_screen.dart';
import 'list_tile_surah.dart';

class SurahList extends StatelessWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context) {
    final surahBloc = context.read<SurahBloc>();
    return BlocBuilder<SurahBloc, SurahState>(
      bloc: surahBloc,
      builder: (context, state) {
        final listSurah = state is SurahLoadedState ? state.listSurah : null;
        return ListView.separated(
          separatorBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return const Divider(color: Colors.transparent);
            }
            return const Divider(thickness: 0.1);
          },
          itemCount: () {
            if (state is SurahLoadingState) {
              return 2;
            } else if (state is SurahLoadedState) {
              if (listSurah == null || listSurah.isEmpty) {
                return 2;
              }
              return (listSurah.length) + 1;
            } else if (state is SurahErrorState) {
              return 2;
            } else {
              return 1;
            }
          }(),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: SearchBox(
                  isDense: true,
                  initialValue: surahBloc.state.query ?? emptyString,
                  hintText: LocaleKeys.search.tr(),
                  onChanged: (val) {
                    surahBloc.add(SurahFetchSearchEvent(query: val));
                  },
                ),
              );
            }

            return BlocBuilder<SurahBloc, SurahState>(
              bloc: surahBloc,
              builder: (context, state) {
                if (state is SurahLoadingState) {
                  return const LinearProgressIndicator();
                } else if (state is SurahErrorState) {
                  return ErrorScreen(
                    message: state.message,
                    onRefresh: () {
                      surahBloc.add(const SurahFetchEvent());
                    },
                  );
                }
                if (listSurah == null || listSurah.isEmpty) {
                  return Center(
                    child: Text(
                      LocaleKeys.noData.tr(),
                      style: context.textTheme.headlineMedium,
                    ),
                  );
                }

                final surahData = listSurah[index - 1];
                return ListTileSurah(
                  onTapSurah: () => onTapSurah(context, surahData),
                  number: surahData.number?.toString() ?? emptyString,
                  name: surahData.name?.transliteration
                          ?.asLocale(context.locale) ??
                      emptyString,
                  revelation: surahData.revelation,
                  numberOfVerses:
                      surahData.numberOfVerses?.toString() ?? emptyString,
                  trailingText: surahData.name?.short ?? emptyString,
                );
              },
            );
          },
        );
      },
    );
  }

  static void onTapSurah(
    BuildContext context,
    Surah? surah, {
    int? jumpToVerse,
  }) {
    context.pushNamed(
      RootRouter.surahRoute.name,
      queryParameters: {
        'jump_to': jumpToVerse?.toString(),
      },
      extra: DetailSurahScreenExtra(surah: surah),
    );
  }
}
