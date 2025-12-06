import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/features/kajian/presentation/bloc/kajian/kajian_bloc.dart';
import 'package:quranku/features/quran/presentation/screens/components/carousel_slider_section.dart';

import '../../../../core/components/spacer.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/route/root_router.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../injection.dart';
import '../../../shalat/presentation/bloc/shalat/shalat_bloc.dart';
import 'mosque_image_container.dart';

class KajianNearbyCard extends StatelessWidget {
  const KajianNearbyCard({
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
        return InkWell(
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
                      message: LocaleKeys.errorLocationDisabled.tr(),
                      actionLabel: LocaleKeys.requestAccessLocation.tr(),
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

        final description = () {
          // themes + time start + - + time end + prayer schedule + ustadz
          final themes = state.recommendedKajian?.themes
                  .map(
                    (e) => e.theme,
                  )
                  .join(', ') ??
              '';
          final timeStart = state.recommendedKajian?.timeStart ?? '';
          final timeEnd = state.recommendedKajian?.timeEnd ?? '';
          final prayerSchedule = state.recommendedKajian?.prayerSchedule ?? '';
          final speaker = state.recommendedKajian?.ustadz.isNotEmpty == true
              ? state.recommendedKajian?.ustadz.first
              : null;

          return [
            if (themes.isNotEmpty) themes,
            switch ((timeStart.isNotEmpty, timeEnd.isNotEmpty)) {
              (true, true) => '$timeStart - $timeEnd',
              (true, false) => timeStart,
              (false, true) => timeEnd,
              _ => '',
            },
            if (prayerSchedule.isNotEmpty) prayerSchedule,
            if (speaker != null) speaker.name,
          ].join('\n');
        }();

        return CarouselEventCard(
          data: CarouselSlideData(
            id: 'kajian_nearby_card',
            type: CarouselSlideType.nearbyEvent,
            title: state.recommendedKajian?.title,
            description: description,
            location: state.recommendedKajian?.studyLocation.name,
            imageUrl: imageUrl,
            tags: [
              LocaleKeys.nearby.tr(),
              ...?state.recommendedKajian?.themes.map(
                (e) => e.theme,
              )
            ],
            date: DateTime.now(),
          ),
        );
      },
    );
  }
}
