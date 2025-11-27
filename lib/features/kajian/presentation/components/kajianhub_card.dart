import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';
import 'package:quranku/features/kajian/presentation/bloc/kajian/kajian_bloc.dart';

import '../../../../core/components/spacer.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/route/root_router.dart';
import '../../../../core/utils/pair.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../injection.dart';
import '../../../shalat/presentation/bloc/shalat/shalat_bloc.dart';
import 'label_tag.dart';
import 'mosque_image_container.dart';

class KajianHubCard extends StatelessWidget {
  const KajianHubCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShalatBloc, ShalatState>(
      buildWhen: (previous, current) {
        return previous.locationStatus != current.locationStatus ||
            previous.geoLocation != current.geoLocation;
      },
      builder: (context, state) {
        final isLocationNotGranted =
            state.locationStatus?.status.isNotGranted == true;
        final isLocationEnabled = state.locationStatus?.enabled == true;
        final isNotIndonesia =
            state.geoLocation?.country?.toLowerCase() != 'indonesia';

        if (isNotIndonesia) {
          return const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.islamicStudiesInformationLabel.tr(),
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const VSpacer(height: 10),
              InkWell(
                onTap: () {
                  if (isLocationNotGranted) {
                    return;
                  }
                  context.goNamed(RootRouter.kajianRoute.name);
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color: context.theme.colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isLocationNotGranted) ...[
                              Flexible(
                                flex: 8,
                                child: const _ErrorInfo(
                                  onTap: null,
                                ),
                              ),
                            ] else if (!isLocationEnabled) ...[
                              Flexible(
                                flex: 8,
                                child: _ErrorInfo(
                                  message:
                                      LocaleKeys.errorLocationDisabled.tr(),
                                  actionLabel:
                                      LocaleKeys.requestAccessLocation.tr(),
                                  onTap: () {
                                    Geolocator.openLocationSettings();
                                  },
                                ),
                              ),
                            ] else ...[
                              Flexible(
                                flex: 8,
                                child: BlocProvider(
                                  create: (_) => sl<KajianBloc>()
                                    ..add(
                                      KajianEvent.fetchNearbyKajian(
                                        locale: context.locale,
                                      ),
                                    ),
                                  child: const _RecitationInfo(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Flexible(
                        flex: 1,
                        child: TagNavIcon(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorInfo extends StatelessWidget {
  final String? message;
  final String? actionLabel;
  final VoidCallback? onTap;
  const _ErrorInfo({
    this.message,
    this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: MosqueImageContainer(
            imageUrl: AssetConst.mosqueDummyImageUrl,
            height: 100,
            width: double.infinity,
          ),
        ),
        const HSpacer(width: 10),
        Expanded(
          flex: 7,
          child: Center(
            child: GestureDetector(
              onTap: onTap,
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: message ?? LocaleKeys.errorGetKajian.tr(),
                      style: context.theme.textTheme.titleSmall,
                    ),
                    TextSpan(
                      text: '\n',
                      style: context.theme.textTheme.titleSmall,
                    ),
                    TextSpan(
                      text: actionLabel ?? LocaleKeys.tryAgain.tr(),
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecitationInfo extends StatelessWidget {
  const _RecitationInfo();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) =>
          previous.statusRecommended != current.statusRecommended ||
          previous.recommendedKajian != current.recommendedKajian,
      builder: (context, state) {
        if (state.statusRecommended.isInProgress) {
          return const Center(child: LinearProgressIndicator());
        }
        if (state.statusRecommended.isFailure) {
          return _ErrorInfo(
            onTap: () {
              context.read<KajianBloc>().add(
                    KajianEvent.fetchNearbyKajian(
                      locale: context.locale,
                    ),
                  );
            },
          );
        }
        if (state.recommendedKajian == null) {
          return _ErrorInfo(
            message: LocaleKeys.nearbyKajianEmptyToday.tr(),
            actionLabel: LocaleKeys.seeAll.tr(),
            onTap: () {
              context.goNamed(RootRouter.kajianRoute.name);
            },
          );
        }
        final imageUrl = state.recommendedKajian?.studyLocation.pictureUrl ??
            AssetConst.mosqueDummyImageUrl;
        final isEvent = state.recommendedKajian?.typeLabel == 'Event';
        final EventKajian? kajianEvent = state.recommendedKajian?.event;
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: MosqueImageContainer(
                imageUrl: imageUrl,
                height: 110,
                width: double.infinity,
              ),
            ),
            const HSpacer(width: 10),
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (isEvent &&
                            (kajianEvent?.type != null &&
                                kajianEvent!.type!.isNotEmpty)) ...[
                          LabelTag(
                            title: LocaleKeys.Event.tr().capitalize(),
                            backgroundColor: context.theme.colorScheme.primary,
                            foregroundColor:
                                context.theme.colorScheme.onPrimary,
                          ),
                          LabelTag(
                            title: kajianEvent.type!.capitalize(),
                            backgroundColor: context.theme.colorScheme.primary,
                            foregroundColor:
                                context.theme.colorScheme.onPrimary,
                          ),
                        ],
                        if (!isEvent) ...[
                          LabelTag(
                            title: LocaleKeys
                                .islamicStudiesNearbyInformationLabel
                                .tr(),
                            backgroundColor: context.theme.colorScheme.primary,
                            foregroundColor:
                                context.theme.colorScheme.onPrimary,
                          ),
                          ...?state.recommendedKajian?.themes.map((e) {
                            final randomColors = [
                              Pair(
                                context.theme.colorScheme.secondary,
                                context.theme.colorScheme.onSecondary,
                              ),
                              Pair(
                                context.theme.colorScheme.tertiary,
                                context.theme.colorScheme.onTertiary,
                              ),
                              Pair(
                                context.theme.colorScheme.surface,
                                context.theme.colorScheme.onSurface,
                              ),
                              Pair(
                                context.theme.colorScheme.primaryContainer,
                                context.theme.colorScheme.onPrimaryContainer,
                              ),
                              Pair(
                                context.theme.colorScheme.secondaryContainer,
                                context.theme.colorScheme.onSecondaryContainer,
                              ),
                              Pair(
                                context.theme.colorScheme.tertiaryContainer,
                                context.theme.colorScheme.onTertiaryContainer,
                              ),
                            ];
                            randomColors.shuffle();
                            return LabelTag(
                              title: e.theme,
                              backgroundColor: randomColors.first.first,
                              foregroundColor: randomColors.first.second,
                            );
                          })
                        ],
                      ],
                    ),
                  ),
                  const VSpacer(height: 2),
                  Text(
                    (state.recommendedKajian?.studyLocation.name ?? ''),
                    style: context.theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const VSpacer(height: 2),
                  Text(
                    state.recommendedKajian?.ustadz.isNotEmpty ?? false
                        ? state.recommendedKajian?.ustadz.first.name ?? ''
                        : '',
                    style: context.theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const VSpacer(height: 2),
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${state.recommendedKajian?.timeStart ?? ''} - ${state.recommendedKajian?.timeEnd ?? ''}',
                          style: context.theme.textTheme.titleSmall,
                        ),
                        TextSpan(
                          text: ' | ',
                          style: context.theme.textTheme.titleSmall,
                        ),
                        TextSpan(
                          text: state.recommendedKajian?.prayerSchedule ?? '',
                          style: context.theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class TagNavIcon extends StatelessWidget {
  const TagNavIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.navigate_next,
      color: context.theme.colorScheme.onSurfaceVariant,
      size: 20,
    );
  }
}
