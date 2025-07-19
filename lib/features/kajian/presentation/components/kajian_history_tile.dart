import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/spacer.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/utils/extension/string_ext.dart';
import '../../../../core/utils/helper.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../domain/entities/kajian_schedule.codegen.dart';
import 'mosque_image_container.dart';
import 'schedule_icon_text.dart';

class KajianHistoryTile extends StatelessWidget {
  final HistoryKajian history;

  const KajianHistoryTile({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final id = extractYouTubeVideoId(history.url);
    var thumbnailUrl = 'https://i.ytimg.com/vi/$id/mqdefault.jpg';
    if (id == null) {
      thumbnailUrl = AssetConst.mosqueDummyImageUrl;
    }
    final date = () {
      if (history.publishedAt.isEmpty) {
        return emptyString;
      }
      return DateTime.parse(history.publishedAt)
          .toEEEEddMMMMyyyy(context.locale);
    }();
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(history.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: context.theme.colorScheme.surfaceContainer,
        ),
        child: Row(
          children: [
            MosqueImageContainer(
              imageUrl: thumbnailUrl,
              width: 120,
              height: 80,
            ),
            const HSpacer(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const VSpacer(height: 4),
                  ScheduleIconText(
                    icon: Icons.calendar_today,
                    text: date ?? emptyString,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow,
                      color: context.theme.colorScheme.tertiary),
                  Text(
                    LocaleKeys.play.tr(),
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
