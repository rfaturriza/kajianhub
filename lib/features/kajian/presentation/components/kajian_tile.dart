import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/kajian/presentation/components/label_tag.dart';

import '../../../../core/components/fullscreen_image_dialog.dart';
import '../../../../core/components/spacer.dart';
import '../../../../core/route/root_router.dart';
import '../../../../core/utils/extension/string_ext.dart';
import '../../../../core/utils/pair.dart';
import '../../domain/entities/kajian_schedule.codegen.dart';
import 'mosque_image_container.dart';
import 'schedule_icon_text.dart';

class KajianTile extends StatelessWidget {
  final DataKajianSchedule kajian;

  const KajianTile({
    super.key,
    required this.kajian,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = kajian.studyLocation.pictureUrl ?? '';
    final prayerName = kajian.prayerSchedule;
    final title = kajian.title;
    final ustadzName =
        kajian.ustadz.isNotEmpty ? kajian.ustadz.first.name : emptyString;
    final ustadzPictureUrl =
        kajian.ustadz.isNotEmpty ? kajian.ustadz.first.pictureUrl : null;
    final time = kajian.timeEnd.isNotEmpty == true
        ? '${kajian.timeStart} - ${kajian.timeEnd}'
        : kajian.timeStart;
    final place = kajian.studyLocation.name;
    final schedule = () {
      if (kajian.dailySchedules.isEmpty && kajian.customSchedules.isNotEmpty) {
        if (kajian.customSchedules.first.date != null) {
          return DateFormat('EEEE, dd MMMM yyyy', context.locale.toString())
              .format(kajian.customSchedules.first.date!.toLocal());
        }
        return emptyString;
      }
      if (kajian.dailySchedules.isNotEmpty && kajian.customSchedules.isEmpty) {
        return kajian.dailySchedules.first.dayLabel;
      }
      return emptyString;
    }();
    final Pair<Color, Color> prayerColor = () {
      switch (prayerName.toLowerCase()) {
        case 'subuh':
          return Pair(
            context.theme.colorScheme.tertiaryContainer,
            context.theme.colorScheme.onTertiaryContainer,
          );
        case 'dzuhur':
          return Pair(
            context.theme.colorScheme.tertiary,
            context.theme.colorScheme.onTertiary,
          );
        case 'ashar':
          return Pair(
            context.theme.colorScheme.error,
            context.theme.colorScheme.onError,
          );
        case 'maghrib':
          return Pair(
            context.theme.colorScheme.primaryContainer,
            context.theme.colorScheme.onPrimaryContainer,
          );
        case 'isya':
          return Pair(
            context.theme.colorScheme.secondaryContainer,
            context.theme.colorScheme.onSecondaryContainer,
          );
        default:
          return Pair(
            context.theme.colorScheme.tertiaryContainer,
            context.theme.colorScheme.onTertiaryContainer,
          );
      }
    }();
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RootRouter.kajianDetailRoute.name,
          pathParameters: {
            'id': kajian.id.toString(),
          },
          extra: kajian,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: context.theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MosqueImageContainer(
              distanceInKm:
                  kajian.distanceInKm ?? kajian.studyLocation.distanceInKm,
              imageUrl: imageUrl,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (prayerName.isNotEmpty) ...[
                            LabelTag(
                              title: prayerName.capitalize(),
                              backgroundColor: prayerColor.first,
                              foregroundColor: prayerColor.second,
                            ),
                          ],
                          Text(
                            title,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const VSpacer(height: 2),
                          Row(
                            children: [
                              if (ustadzPictureUrl != null &&
                                  ustadzPictureUrl.isNotEmpty) ...[
                                GestureDetector(
                                  onTap: () {
                                    showFullscreenImage(
                                      context,
                                      imageUrl: ustadzPictureUrl,
                                      overlayText: ustadzName,
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundImage: CachedNetworkImageProvider(
                                        ustadzPictureUrl),
                                    onBackgroundImageError: (_, __) {},
                                    child: CachedNetworkImage(
                                      imageUrl: ustadzPictureUrl,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Symbols.person_rounded,
                                        color: context
                                            .theme.colorScheme.onSurfaceVariant,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const HSpacer(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  ustadzName,
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const VSpacer(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (schedule.isNotEmpty) ...[
                                Expanded(
                                  flex: 1,
                                  child: ScheduleIconText(
                                    icon: Symbols.date_range_rounded,
                                    text: schedule,
                                  ),
                                ),
                              ],
                              if (time.isNotEmpty) ...[
                                const HSpacer(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: ScheduleIconText(
                                    icon: Icons.access_time,
                                    text: time,
                                  ),
                                ),
                              ]
                            ],
                          ),
                          const VSpacer(height: 2),
                          ScheduleIconText(
                            icon: Icons.place_outlined,
                            text: place ?? emptyString,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.navigate_next,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
