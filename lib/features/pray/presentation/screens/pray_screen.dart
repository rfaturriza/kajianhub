import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/components/error_screen.dart';
import 'package:quranku/core/components/search_box.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/route/root_router.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/pray/presentation/bloc/pray_bloc.dart';
import 'package:quranku/features/pray/presentation/components/prayer_tile.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/injection.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PrayBloc>()..add(const PrayEvent.fetchPrayers()),
      child: const _PrayScreenContent(),
    );
  }
}

class _PrayScreenContent extends StatelessWidget {
  const _PrayScreenContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VSpacer(height: 10),
        BlocBuilder<PrayBloc, PrayState>(
          buildWhen: (previous, current) =>
              previous.searchQuery != current.searchQuery,
          builder: (context, state) {
            return SearchBox(
              initialValue: state.searchQuery ?? emptyString,
              hintText: LocaleKeys.searchPrayHint.tr(),
              onClear: () {
                context.read<PrayBloc>().add(const PrayEvent.clearSearch());
              },
              onSubmitted: (value) {
                if (value != null && value.isNotEmpty) {
                  context.read<PrayBloc>().add(PrayEvent.searchPrayers(value));
                }
              },
            );
          },
        ),
        const VSpacer(height: 16),
        Expanded(
          child: BlocBuilder<PrayBloc, PrayState>(
            builder: (context, state) {
              if (state.status.isInProgress && state.prayers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status.isFailure) {
                return ErrorScreen(
                  message: state.errorMessage ?? LocaleKeys.errorGetPray.tr(),
                  onRefresh: () {
                    context
                        .read<PrayBloc>()
                        .add(const PrayEvent.fetchPrayers());
                  },
                );
              }

              if (state.prayers.isEmpty && state.status.isSuccess) {
                return Center(
                  child: Text(LocaleKeys.prayEmpty.tr()),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // Load more when user is near the bottom (within 200 pixels)
                  if (scrollInfo is ScrollUpdateNotification &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200 &&
                      !state.hasReachedMax &&
                      !state.isLoadingMore &&
                      state.status.isSuccess) {
                    context
                        .read<PrayBloc>()
                        .add(const PrayEvent.loadMorePrayers());
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.prayers.length +
                      (state.isLoadingMore && !state.hasReachedMax ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.prayers.length && state.isLoadingMore) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    }

                    final prayer = state.prayers[index];
                    return PrayerTile(
                      prayer: prayer,
                      onTap: () {
                        context.pushNamed(
                          RootRouter.prayDetailRoute.name,
                          pathParameters: {
                            'id': prayer.id.toString(),
                          },
                          extra: prayer,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
