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
    var tabs = <Widget>[
      Tab(
        text: LocaleKeys.history.tr(),
        height: 30,
      ),
    ];
    if (widget.kajian.customSchedules.isNotEmpty) {
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
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _ImageSection(
                  imageUrl: widget.kajian.studyLocation.pictureUrl ?? '',
                  label: kajianTheme,
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
                            labelPadding: EdgeInsets.symmetric(horizontal: 8),
                            labelStyle: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            tabs: tabs,
                          ),
                        ),
                        IconButton(
                          onPressed: toggleSort,
                          icon: Icon(
                            _isSortedHistories || _isSortedCustomSchedules
                                ? Symbols.arrow_downward_rounded
                                : Symbols.arrow_upward_rounded,
                            color:
                                _isSortedHistories || _isSortedCustomSchedules
                                    ? context.theme.colorScheme.primary
                                    : null,
                          ),
                          tooltip:
                              _isSortedHistories || _isSortedCustomSchedules
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
                    const VSpacer(height: 8),
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
