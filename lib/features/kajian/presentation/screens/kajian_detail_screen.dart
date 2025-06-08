import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';
import 'package:quranku/features/kajian/presentation/components/label_tag.dart';
import 'package:quranku/features/kajian/presentation/components/mosque_image_container.dart';
import 'package:quranku/features/kajian/presentation/components/schedule_icon_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/utils/helper.dart';
import '../../../../generated/locale_keys.g.dart';

class KajianDetailScreen extends StatelessWidget {
  final DataKajianSchedule kajian;

  const KajianDetailScreen({
    super.key,
    required this.kajian,
  });

  @override
  Widget build(BuildContext context) {
    final kajianTheme =
        kajian.themes.isNotEmpty ? kajian.themes.first.theme : '';
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          context.isDarkMode
              ? AssetConst.kajianHubTextLogoLight
              : AssetConst.kajianHubTextLogoDark,
          width: 100,
        ),
      ),
      body: ListView(
        children: [
          _ImageSection(
            imageUrl: kajian.studyLocation.pictureUrl ?? '',
            label: kajianTheme,
          ),
          const VSpacer(height: 12),
          _InfoSection(kajian: kajian),
          const VSpacer(height: 12),
          _HistorySection(
            histories: kajian.histories,
          ),
        ],
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final String imageUrl;
  final String label;

  const _ImageSection({
    required this.imageUrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl.isNotEmpty
        ? this.imageUrl
        : AssetConst.mosqueDummyImageUrl;
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: LabelTag(
            title: label,
            backgroundColor: context.theme.colorScheme.tertiary,
            foregroundColor: context.theme.colorScheme.onTertiary,
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final DataKajianSchedule kajian;

  const _InfoSection({
    required this.kajian,
  });

  @override
  Widget build(BuildContext context) {
    final ustadzName = kajian.ustadz.isNotEmpty ? kajian.ustadz.first.name : '';
    final dayLabel = kajian.dailySchedules.isNotEmpty
        ? kajian.dailySchedules.first.dayLabel
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kajian.title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ustadzName,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const VSpacer(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.day.tr(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dayLabel,
                      style: context.textTheme.bodyMedium,
                    ),
                    const VSpacer(height: 12),
                    Text(
                      LocaleKeys.time.tr(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${kajian.timeStart} - ${kajian.timeEnd}',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 7,
                child: GestureDetector(
                  onTap: () async {
                    final uri =
                        Uri.parse(kajian.studyLocation.googleMaps ?? '');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            LocaleKeys.location.tr(),
                            textAlign: TextAlign.end,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const HSpacer(width: 4),
                          SvgPicture.asset(
                            AssetConst.googleMapsIcon,
                            width: 12,
                          )
                        ],
                      ),
                      Text(
                        kajian.studyLocation.address ?? emptyString,
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatefulWidget {
  final List<HistoryKajian> histories;

  const _HistorySection({
    required this.histories,
  });

  @override
  State<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<_HistorySection> {
  late List<HistoryKajian> sortedHistories;

  @override
  void initState() {
    super.initState();
    sortedHistories = List.from(widget.histories);

    if (sortedHistories.isNotEmpty && sortedHistories.length > 1) {
      sortedHistories.sort((a, b) {
        return DateTime.parse(b.publishedAt)
            .compareTo(DateTime.parse(a.publishedAt));
      });
    }
  }

  void toggleSort() {
    if (sortedHistories.isEmpty || sortedHistories.length == 1) return;
    setState(() {
      sortedHistories = sortedHistories.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.theme.colorScheme.surfaceContainer,
      ),
      child: DefaultTabController(
        length: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelPadding: EdgeInsets.zero,
                    labelStyle: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(
                        text: LocaleKeys.history.tr(),
                        height: 30,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: toggleSort,
                  icon: const Icon(Icons.format_line_spacing_rounded),
                ),
              ],
            ),
            const VSpacer(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedHistories.length,
              itemBuilder: (context, index) {
                return _HistoryTile(
                  history: sortedHistories[index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryKajian history;

  const _HistoryTile({
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
