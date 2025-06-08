import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/kajian/domain/entities/study_location_entity.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/error_screen.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../kajian/presentation/components/kajian_tile.dart';
import '../blocs/study_location_detail/study_location_detail_bloc.dart';

class StudyLocationDetailScreen extends StatelessWidget {
  final StudyLocationEntity masjid;
  const StudyLocationDetailScreen({super.key, required this.masjid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(masjid.name ?? ''),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _ImageSection(
                  imageUrl: masjid.pictureUrl ?? '',
                  label: "Youtube",
                  youtubeUrl: masjid.youtubeChannelLink ?? '',
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _InfoSection(mosque: masjid),
                ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              minHeight: kToolbarHeight,
              maxHeight: kToolbarHeight,
              child: Container(
                color: context.theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  LocaleKeys.kajian.tr(),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _StudySchedulesList(
              studyLocationId: masjid.id?.toString() ?? '',
            ),
          ),
        ],
      ),
    );
  }
}

class _StudySchedulesList extends StatefulWidget {
  final String studyLocationId;
  const _StudySchedulesList({required this.studyLocationId});

  @override
  _StudySchedulesListState createState() => _StudySchedulesListState();
}

class _StudySchedulesListState extends State<_StudySchedulesList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    // Load first page
    context.read<StudyLocationDetailBloc>().add(
          StudyLocationDetailEvent.loadStudies(
            studyLocationId: widget.studyLocationId,
            page: 1,
          ),
        );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final state = context.read<StudyLocationDetailBloc>().state;
    if (currentScroll >= maxScroll &&
        !state.hasReachedMax &&
        state.kajianResult.isNotEmpty &&
        state.statusKajian != FormzSubmissionStatus.inProgress) {
      context.read<StudyLocationDetailBloc>().add(
            StudyLocationDetailEvent.loadStudies(
              studyLocationId: widget.studyLocationId,
              page: state.currentPage + 1,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyLocationDetailBloc, StudyLocationDetailState>(
      builder: (context, state) {
        if (state.statusKajian == FormzSubmissionStatus.inProgress &&
            state.kajianResult.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.statusKajian == FormzSubmissionStatus.failure) {
          return ErrorScreen(
            message: state.errorMessage,
            onRefresh: () {
              context.read<StudyLocationDetailBloc>().add(
                    StudyLocationDetailEvent.loadStudies(
                      studyLocationId: widget.studyLocationId,
                      page: 1,
                    ),
                  );
            },
          );
        }
        final schedules = state.kajianResult;
        if (schedules.isEmpty) {
          return ErrorScreen(
            iconType: IconType.info,
            message: LocaleKeys.searchKajianEmpty.tr(),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount:
              state.hasReachedMax ? schedules.length : schedules.length + 1,
          itemBuilder: (context, index) {
            if (index >= schedules.length) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              ));
            }
            final kajian = schedules[index];
            return KajianTile(
              key: Key(index.toString()),
              kajian: kajian,
            );
          },
        );
      },
    );
  }
}

class _ImageSection extends StatelessWidget {
  final String imageUrl;
  final String youtubeUrl;
  final String label;

  const _ImageSection({
    required this.imageUrl,
    this.youtubeUrl = '',
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
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              final youtubeUrl =
                  this.youtubeUrl.isNotEmpty ? this.youtubeUrl : '';
              if (youtubeUrl.isNotEmpty) {
                final uri = Uri.parse(youtubeUrl);
                launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                context.showErrorToast(LocaleKeys.defaultErrorMessage.tr());
              }
            },
            child: Chip(
              backgroundColor: context.theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              side: BorderSide.none,
              avatar: const Icon(
                Symbols.youtube_activity_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final StudyLocationEntity mosque;

  const _InfoSection({
    required this.mosque,
  });

  void _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = mosque.name ?? '';
    final provinceCity =
        "${mosque.city?.name ?? ''}, ${mosque.province?.name ?? ''}";
    final address = mosque.address ?? '';
    final totalStudy = int.tryParse(mosque.kajianCount ?? '0') ?? 0;
    final totalSubscribe = int.tryParse(mosque.subscribersCount ?? '0') ?? 0;
    final googleMapUrl = mosque.googleMaps ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const VSpacer(height: 8),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.location_on_rounded,
                    size: 18,
                    color: context.theme.colorScheme.primary,
                  ),
                  const HSpacer(width: 8),
                  Expanded(
                    child: Text(
                      provinceCity,
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const VSpacer(height: 8),
              Row(
                children: [
                  Icon(
                    Symbols.calendar_month_rounded,
                    size: 18,
                    color: context.theme.colorScheme.primary,
                  ),
                  const HSpacer(width: 8),
                  Text(
                    '$totalStudy ${LocaleKeys.totalStudies.tr()}',
                    style: context.textTheme.bodyMedium,
                  ),
                  const HSpacer(width: 16),
                  Icon(
                    Symbols.group_rounded,
                    size: 18,
                    color: context.theme.colorScheme.primary,
                  ),
                  const HSpacer(width: 8),
                  Text(
                    '$totalSubscribe ${LocaleKeys.subscribers.tr()}',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const VSpacer(height: 12),
        Material(
          color:
              context.theme.colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openMaps(googleMapUrl),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.map_rounded,
                        size: 20,
                        color: context.theme.colorScheme.primary,
                      ),
                      const HSpacer(width: 8),
                      Text(
                        () {
                          final distance = " - ${mosque.distanceInKm} Km";
                          var text = LocaleKeys.location.tr();
                          if (mosque.distanceInKm != null) {
                            text += distance;
                          }
                          return text;
                        }(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const VSpacer(height: 8),
                  Text(
                    address,
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
