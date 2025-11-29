import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';
import 'package:quranku/features/kajian/presentation/components/label_tag.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/fullscreen_image_dialog.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../generated/locale_keys.g.dart';
import '../components/custom_schedule_card.dart';
import '../components/kajian_history_tile.dart';

class KajianDetailScreen extends StatefulWidget {
  final DataKajianSchedule kajian;

  const KajianDetailScreen({
    super.key,
    required this.kajian,
  });

  @override
  State<KajianDetailScreen> createState() => _KajianDetailScreenState();
}

class _KajianDetailScreenState extends State<KajianDetailScreen> {
  var _isSortedHistories = false;
  var _isSortedCustomSchedules = false;

  void toggleSort() {
    setState(() {
      _isSortedHistories = !_isSortedHistories;
      _isSortedCustomSchedules = !_isSortedCustomSchedules;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kajianTheme =
        widget.kajian.themes.isNotEmpty ? widget.kajian.themes.first.theme : '';
    final isEvent = widget.kajian.typeLabel == 'Event';
    EventKajian? kajian = widget.kajian.event;
    var tabs = <Widget>[
      Tab(
        text: LocaleKeys.history.tr(),
        height: 30,
      ),
    ];
    if (isEvent) {
      tabs = [
        Tab(
          text: LocaleKeys.kajianDateSchedule.tr(),
          height: 10,
        ),
      ];
    } else if (widget.kajian.customSchedules.isNotEmpty) {
      tabs = [
        Tab(
          text: LocaleKeys.kajianDateSchedule.tr(),
          height: 30,
        ),
        Tab(
          text: LocaleKeys.history.tr(),
          height: 30,
        ),
      ];
    }
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
        body: isEvent
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    _ImageSection(
                      imageUrl: widget.kajian.studyLocation.pictureUrl ?? '',
                      label: kajianTheme,
                      locationName: widget.kajian.studyLocation.name ?? '',
                      isEvent: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _InfoSection(kajian: widget.kajian),
                    ),
                    VSpacer(height: 12),
                  ],
                ),
              )
            : DefaultTabController(
                length: tabs.length,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _ImageSection(
                          imageUrl:
                              widget.kajian.studyLocation.pictureUrl ?? '',
                          label: kajianTheme,
                          locationName: widget.kajian.studyLocation.name ?? '',
                          isEvent: false,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _InfoSection(kajian: widget.kajian),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverHeaderDelegate(
                          minHeight: kToolbarHeight,
                          maxHeight: kToolbarHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TabBar(
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    labelPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    labelStyle:
                                        context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    tabs: tabs,
                                  ),
                                ),
                                IconButton(
                                  onPressed: toggleSort,
                                  icon: Icon(
                                    _isSortedHistories ||
                                            _isSortedCustomSchedules
                                        ? Symbols.arrow_downward_rounded
                                        : Symbols.arrow_upward_rounded,
                                    color: _isSortedHistories ||
                                            _isSortedCustomSchedules
                                        ? context.theme.colorScheme.primary
                                        : null,
                                  ),
                                  tooltip: _isSortedHistories ||
                                          _isSortedCustomSchedules
                                      ? 'Sort: Oldest First'
                                      : 'Sort: Newest First',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: _TabSection(
                    isSortedHistories: _isSortedHistories,
                    isSortedCustomSchedules: _isSortedCustomSchedules,
                    histories: widget.kajian.histories,
                    customSchedules: widget.kajian.customSchedules,
                  ),
                ),
              ),
        bottomNavigationBar: isEvent &&
                (kajian?.onlineLink != null && kajian!.onlineLink!.isNotEmpty)
            ? Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                height: 64,
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final uri =
                              Uri.parse(kajian.onlineLink ?? emptyString);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          width: double.infinity,
                          height: 36,
                          child: Center(
                            child: Text(
                              LocaleKeys.register.tr(),
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
              )
            : null);
  }
}

class _ImageSection extends StatelessWidget {
  final String locationName;
  final String imageUrl;
  final String label;
  final bool isEvent;

  const _ImageSection(
      {required this.locationName,
      required this.imageUrl,
      required this.label,
      this.isEvent = false});

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl.isNotEmpty
        ? this.imageUrl
        : AssetConst.mosqueDummyImageUrl;
    String tagName = isEvent ? 'Event' : label;
    Color tagBackgroundColor = isEvent
        ? context.theme.colorScheme.primaryContainer
        : context.theme.colorScheme.tertiary;
    Color tagForegroundColor = isEvent
        ? context.theme.colorScheme.onPrimaryContainer
        : context.theme.colorScheme.onTertiary;
    return GestureDetector(
      onTap: () {
        context.showFullscreenImageDialog(
          imageUrl: imageUrl,
          overlayText: locationName,
        );
      },
      child: Stack(
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
          // Fullscreen indicator
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.surface.withValues(alpha: 0.8),
                border: Border.all(
                  color:
                      context.theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.fullscreen,
                color: context.theme.colorScheme.onSurface,
                size: 16,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: LabelTag(
              title: tagName,
              backgroundColor: tagBackgroundColor,
              foregroundColor: tagForegroundColor,
            ),
          ),
        ],
      ),
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
    String ustadzName = '';
    if (kajian.ustadz.length > 1) {
      ustadzName = kajian.ustadz.map((e) => e.name).join(',\n');
    } else {
      ustadzName = kajian.ustadz.isNotEmpty ? kajian.ustadz.first.name : '';
    }
    final ustadzPictureUrl =
        kajian.ustadz.isNotEmpty ? kajian.ustadz.first.pictureUrl : null;
    String dayLabel = kajian.dailySchedules.isNotEmpty
        ? kajian.dailySchedules.first.dayLabel
        : '';

    final isEvent = kajian.typeLabel == 'Event';
    String eventThemes = '';
    if (isEvent) {
      dayLabel = kajian.event?.date != null
          ? DateFormat('EEEE, dd MMM yyyy', context.locale.toString())
              .format(DateTime.parse(kajian.event!.date!))
          : '';
      if (kajian.themes.isNotEmpty && kajian.themes.length > 1) {
        eventThemes = kajian.themes.map((e) => e.theme).join(', ');
      } else {
        eventThemes = kajian.themes.isNotEmpty ? kajian.themes.first.theme : '';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ustadzPictureUrl != null && ustadzPictureUrl.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    context.showFullscreenImageDialog(
                      imageUrl: ustadzPictureUrl,
                      overlayText: ustadzName,
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            CachedNetworkImageProvider(ustadzPictureUrl),
                        onBackgroundImageError: (_, __) {},
                        child: CachedNetworkImage(
                          imageUrl: ustadzPictureUrl,
                          imageBuilder: (context, imageProvider) => Container(),
                          errorWidget: (context, url, error) => Icon(
                            Symbols.person_rounded,
                            color: context.theme.colorScheme.onSurfaceVariant,
                            size: 30,
                          ),
                        ),
                      ),
                      // Indicator that the image is clickable
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.surface
                                .withValues(alpha: 0.9),
                            border: Border.all(
                              color: context.theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fullscreen,
                            color: context.theme.colorScheme.onSurface,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const HSpacer(width: 12),
              ],
              Expanded(
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
                  ],
                ),
              ),
            ],
          ),
          const VSpacer(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((kajian.customSchedules.isEmpty) == true) ...[
                Expanded(
                  flex: isEvent ? 6 : 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dayLabel.isNotEmpty) ...[
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
                        const VSpacer(height: 8),
                      ],
                      if (kajian.timeStart.isNotEmpty == true ||
                          kajian.timeEnd.isNotEmpty == true) ...[
                        Text(
                          LocaleKeys.time.tr(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${kajian.timeStart} ${kajian.timeEnd.isNotEmpty ? '- ${kajian.timeEnd}' : ''}',
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primaryContainer
                          .withAlpha(100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Symbols.map_rounded,
                              size: 20,
                              color: context.theme.colorScheme.primary,
                            ),
                            const HSpacer(width: 4),
                            Text(
                              LocaleKeys.location.tr(),
                              textAlign: TextAlign.end,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const VSpacer(height: 8),
                        Text(
                          kajian.studyLocation.address ?? emptyString,
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isEvent)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VSpacer(height: 16),
                Text(
                  LocaleKeys.theme.tr(),
                  style: context.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
                ),
                const VSpacer(height: 8),
                Text(
                  eventThemes,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
                const VSpacer(height: 16),
                if (kajian.event?.body != null &&
                    kajian.event!.body!.isNotEmpty) ...[
                  Text(
                    LocaleKeys.description.tr(),
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
                  ),
                  const VSpacer(height: 8),
                  Text(
                    kajian.event!.body!,
                    style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                ],
                /* if (kajian.event?.onlineLink != null &&
                    kajian.event!.onlineLink!.isNotEmpty) */
                ...[
                  const VSpacer(height: 16),
                  Text(
                    LocaleKeys.online.tr(),
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
                  ),
                  const VSpacer(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final uri =
                          Uri.parse(kajian.event?.onlineLink ?? emptyString);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      height: 36,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          LocaleKeys.JoinSession.tr(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  VSpacer(height: MediaQuery.of(context).padding.bottom),
                ]
              ],
            ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final List<HistoryKajian> histories;
  const _HistorySection({
    required this.histories,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        return KajianHistoryTile(
          history: histories[index],
        );
      },
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final List<CustomSchedule> schedules;

  const _ScheduleSection({
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      separatorBuilder: (context, index) => const VSpacer(height: 12),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return ScheduleCard(schedule: schedule);
      },
    );
  }
}

class _TabSection extends StatefulWidget {
  final bool isSortedHistories;
  final bool isSortedCustomSchedules;
  final List<HistoryKajian> histories;
  final List<CustomSchedule> customSchedules;

  const _TabSection({
    required this.isSortedHistories,
    required this.isSortedCustomSchedules,
    required this.histories,
    required this.customSchedules,
  });

  @override
  State<_TabSection> createState() => _TabSectionState();
}

class _TabSectionState extends State<_TabSection> {
  late List<HistoryKajian> sortedHistories;
  late List<CustomSchedule> sortedCustomSchedules;

  @override
  void initState() {
    super.initState();
    _updateSortedLists();
  }

  @override
  void didUpdateWidget(_TabSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSortedHistories != widget.isSortedHistories ||
        oldWidget.isSortedCustomSchedules != widget.isSortedCustomSchedules) {
      _updateSortedLists();
    }
  }

  void _updateSortedLists() {
    sortedHistories = List.from(widget.histories);
    sortedCustomSchedules = List.from(widget.customSchedules);

    if (sortedHistories.isNotEmpty && sortedHistories.length > 1) {
      sortedHistories.sort((a, b) {
        final comparison = DateTime.parse(b.publishedAt)
            .compareTo(DateTime.parse(a.publishedAt));
        return widget.isSortedHistories ? -comparison : comparison;
      });
    }

    if (sortedCustomSchedules.isNotEmpty && sortedCustomSchedules.length > 1) {
      sortedCustomSchedules.sort((a, b) {
        if (a.date != null && b.date != null) {
          final comparison = a.date!.compareTo(b.date!);
          return widget.isSortedCustomSchedules ? -comparison : comparison;
        }
        return 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.theme.colorScheme.surfaceContainer,
      ),
      child: TabBarView(
        children: [
          if (widget.customSchedules.isNotEmpty) ...[
            // Schedule Tab
            _ScheduleSection(
              schedules: sortedCustomSchedules,
            ),
          ],
          // History Tab
          _HistorySection(
            histories: sortedHistories,
          ),
        ],
      ),
    );
  }
}

// Delegate for SliverPersistentHeader to display floating title
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate(
      {required this.minHeight, required this.maxHeight, required this.child});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
