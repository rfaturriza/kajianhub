import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/kajian/domain/entities/study_location_entity.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/spacer.dart';
import '../../../kajian/presentation/components/mosque_image_container.dart';
import '../../../kajian/presentation/components/schedule_icon_text.dart';

class StudyLocationTile extends StatelessWidget {
  final StudyLocationEntity location;
  final Function(StudyLocationEntity mosque)? onTap;

  const StudyLocationTile({
    super.key,
    required this.location,
    this.onTap,
  });

  void _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = location.pictureUrl ?? '';
    final title = location.name ?? '';
    final provinceCity = "${location.city?.name}, ${location.province?.name}";
    final address = location.address ?? '';
    final totalStudy = location.kajianCount ?? '';
    final googleMapUrl = location.googleMaps ?? '';

    return GestureDetector(
      onTap: onTap != null
          ? () {
              onTap!(location);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              distanceInKm: location.distanceInKm ?? '',
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
                          Text(
                            title,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const VSpacer(height: 2),
                          Text(
                            provinceCity,
                            style: context.textTheme.bodySmall,
                          ),
                          const VSpacer(height: 2),
                          Text(
                            address,
                            style: context.textTheme.bodySmall,
                          ),
                          const VSpacer(height: 4),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: ScheduleIconText(
                                  icon: Icons.menu_book_rounded,
                                  text: totalStudy.toString(),
                                ),
                              ),
                              const HSpacer(width: 5),
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () {
                                    _openMaps(googleMapUrl);
                                  },
                                  child: ScheduleIconText(
                                    icon: Symbols.map_search_rounded,
                                    text: "Maps",
                                  ),
                                ),
                              ),
                            ],
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
