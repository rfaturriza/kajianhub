import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/kajian/presentation/components/label_tag.dart';

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
    final ustadz =
        kajian.ustadz.isNotEmpty ? kajian.ustadz.first.name : emptyString;
    final time = '${kajian.timeStart} - ${kajian.timeEnd}';
    final place = kajian.studyLocation.name;
    final schedule = kajian.dailySchedules.isNotEmpty
        ? kajian.dailySchedules.first.dayLabel
        : emptyString;
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
              distanceInKm: kajian.distanceInKm ??
                  kajian.studyLocation.distanceInKm ??
                  emptyString,
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
                          Text(
                            ustadz,
                            style: context.textTheme.bodySmall,
                          ),
                          const VSpacer(height: 2),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: ScheduleIconText(
                                  icon: Icons.date_range_outlined,
                                  text: schedule,
                                ),
                              ),
                              const HSpacer(width: 5),
                              Expanded(
                                flex: 2,
                                child: ScheduleIconText(
                                  icon: Icons.access_time,
                                  text: time,
                                ),
                              ),
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
