import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/components/error_screen.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/quran/presentation/bloc/juz/juz_cubit.dart';
import 'package:quranku/features/quran/presentation/screens/components/list_tile_juz.dart';

import '../../../../../core/components/search_box.dart';
import '../../../../../core/route/root_router.dart';
import '../../../../../generated/locale_keys.g.dart';

class JuzList extends StatelessWidget {
  const JuzList({super.key});

  @override
  Widget build(BuildContext context) {
    final juzBloc = context.read<JuzBloc>();

    return BlocBuilder<JuzBloc, JuzState>(
      bloc: juzBloc,
      builder: (context, state) {
        return ListView.separated(
          itemCount: () {
            if (state.isLoading) {
              return 2;
            } else if (state.listJuz != null) {
              return (state.listJuz?.length ?? 0) + 1;
            } else if (state.listJuz == null ||
                state.listJuz?.isEmpty == true) {
              return 2;
            } else {
              return 1;
            }
          }(),
          separatorBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return const Divider(color: Colors.transparent);
            }
            return const Divider(thickness: 0.1);
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: SearchBox(
                  initialValue: state.query ?? emptyString,
                  hintText: LocaleKeys.search.tr(),
                  onChanged: (val) {
                    juzBloc.searchJuz(val);
                  },
                ),
              );
            }

            return BlocBuilder<JuzBloc, JuzState>(
              bloc: juzBloc,
              builder: (context, state) {
                if (state.isLoading) {
                  return const LinearProgressIndicator();
                }
                if (state.listJuz == null || state.listJuz?.isEmpty == true) {
                  return ErrorScreen(
                    message: LocaleKeys.noData.tr(),
                  );
                }

                final juz = state.listJuz?[index - 1];
                return ListTileJuz(
                  onTapJuz: () => onTapJuz(context, juz?.number),
                  number: juz?.number.toString() ?? emptyString,
                  name: juz?.name ?? emptyString,
                  description: juz?.description ?? emptyString,
                );
              },
            );
          },
        );
      },
    );
  }

  static void onTapJuz(
    BuildContext context,
    int? juzNumber, {
    int? jumpToVerse,
  }) {
    context.pushNamed(
      RootRouter.juzRoute.name,
      queryParameters: {
        'no': juzNumber.toString(),
        'jump_to': jumpToVerse.toString(),
      },
    );
  }
}
