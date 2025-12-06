import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/components/error_screen.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/route/root_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';
import 'package:quranku/features/pray/presentation/bloc/prayer_detail_bloc.dart';
import 'package:quranku/features/pray/presentation/components/prayer_tile.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/injection.dart';

import '../../../setting/presentation/bloc/styling_setting/styling_setting_bloc.dart';

class PrayerDetailScreen extends StatelessWidget {
  final Prayer? prayer;
  final int? prayerId;

  const PrayerDetailScreen({
    super.key,
    this.prayer,
    this.prayerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PrayerDetailBloc>()
        ..add(PrayerDetailEvent.loadPrayerDetail(
          prayerId ?? prayer?.id ?? 0,
        )),
      child: _PrayerDetailContent(prayer: prayer, prayerId: prayerId),
    );
  }
}

class _PrayerDetailContent extends StatelessWidget {
  final Prayer? prayer;
  final int? prayerId;

  const _PrayerDetailContent({this.prayer, this.prayerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(prayer?.title ?? LocaleKeys.pray.tr()),
        actions: [
          BlocBuilder<PrayerDetailBloc, PrayerDetailState>(
            buildWhen: (previous, current) => previous.prayer != current.prayer,
            builder: (context, state) {
              if (state.prayer == null) return const SizedBox();

              return IconButton(
                icon: const Icon(Symbols.content_copy_rounded),
                onPressed: () {
                  final prayer = state.prayer!;
                  final shareText = [
                    prayer.title,
                    if (prayer.description.isNotEmpty) prayer.description,
                    prayer.arabicText,
                    prayer.text,
                  ].join('\n\n');

                  // Share implementation would go here
                  try {
                    Clipboard.setData(ClipboardData(text: shareText));
                    context
                        .showInfoToast(LocaleKeys.prayCopiedToClipboard.tr());
                  } catch (e) {
                    context.showErrorToast(LocaleKeys.defaultErrorMessage.tr());
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PrayerDetailBloc, PrayerDetailState>(
        builder: (context, state) {
          if (state.status.isInProgress && state.prayer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status.isFailure) {
            return ErrorScreen(
              message: state.errorMessage ?? LocaleKeys.errorGetPray.tr(),
              onRefresh: () {
                final id = prayerId ?? prayer?.id ?? 0;
                context.read<PrayerDetailBloc>().add(
                      PrayerDetailEvent.loadPrayerDetail(id),
                    );
              },
            );
          }

          final displayPrayer = state.prayer ?? prayer;
          if (displayPrayer == null) {
            return Center(child: Text(LocaleKeys.prayEmpty.tr()));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PrayerContent(prayer: displayPrayer),
                const VSpacer(height: 32),
                _SuggestedPrayers(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrayerContent extends StatelessWidget {
  final Prayer prayer;

  const _PrayerContent({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prayer.title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            if (prayer.description.isNotEmpty) ...[
              const VSpacer(height: 16),
              Text(
                prayer.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurface
                      .withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
            const VSpacer(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BlocBuilder<StylingSettingBloc, StylingSettingState>(
                buildWhen: (p, c) =>
                    p.fontFamilyArabic != c.fontFamilyArabic ||
                    p.arabicFontSize != c.arabicFontSize,
                builder: (context, stylingState) {
                  return Text(
                    prayer.arabicText,
                    style: context.textTheme.titleLarge?.copyWith(
                      height: 2.0,
                      fontSize: stylingState.arabicFontSize,
                      fontFamily: stylingState.fontFamilyArabic,
                      color: context.theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
            const VSpacer(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      context.theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                prayer.text,
                style: context.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedPrayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerDetailBloc, PrayerDetailState>(
      buildWhen: (previous, current) =>
          previous.suggestedPrayersStatus != current.suggestedPrayersStatus ||
          previous.suggestedPrayers != current.suggestedPrayers,
      builder: (context, state) {
        if (state.suggestedPrayersStatus.isInProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.suggestedPrayers.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.otherPray.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const VSpacer(height: 16),
            ...state.suggestedPrayers.map(
              (prayer) => PrayerTile(
                prayer: prayer,
                onTap: () {
                  context.pushNamed(
                    RootRouter.prayDetailRoute.name,
                    pathParameters: {'id': prayer.id.toString()},
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
