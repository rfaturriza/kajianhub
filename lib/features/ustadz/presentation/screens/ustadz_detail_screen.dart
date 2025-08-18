import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../core/components/error_screen.dart';
import '../../../../core/components/fullscreen_image_dialog.dart';
import '../../../kajian/presentation/components/kajian_tile.dart';
import '../blocs/ustadz_detail/ustadz_detail_bloc.dart';

class UstadzDetailScreen extends StatelessWidget {
  final UstadzEntity ustadz;
  const UstadzDetailScreen({super.key, required this.ustadz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ustadz.name),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _ImageSection(
                  imageUrl: ustadz.pictureUrl ?? '',
                  ustadz: ustadz,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _InfoSection(ustadz: ustadz),
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
            child: _KajianByUstadzList(
              ustadzId: ustadz.id.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _KajianByUstadzList extends StatefulWidget {
  final String ustadzId;
  const _KajianByUstadzList({
    required this.ustadzId,
  });

  @override
  _KajianByUstadzListState createState() => _KajianByUstadzListState();
}

class _KajianByUstadzListState extends State<_KajianByUstadzList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    // Load first page
    context.read<UstadzDetailBloc>().add(
          LoadKajianByUstadz(
            ustadzId: widget.ustadzId,
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
    final state = context.read<UstadzDetailBloc>().state;
    if (currentScroll >= maxScroll &&
        !state.hasReachedMax &&
        state.kajianResult.isNotEmpty &&
        state.statusKajian != FormzSubmissionStatus.inProgress) {
      context.read<UstadzDetailBloc>().add(
            LoadKajianByUstadz(
              ustadzId: widget.ustadzId,
              page: state.currentPage + 1,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UstadzDetailBloc, UstadzDetailState>(
      builder: (context, state) {
        if (state.statusKajian == FormzSubmissionStatus.inProgress &&
            state.kajianResult.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.statusKajian == FormzSubmissionStatus.failure) {
          return ErrorScreen(
            message: state.errorMessage,
            onRefresh: () {
              context.read<UstadzDetailBloc>().add(
                    LoadKajianByUstadz(
                      ustadzId: widget.ustadzId,
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
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.statusKajian == FormzSubmissionStatus.inProgress
              ? schedules.length + 1
              : schedules.length,
          itemBuilder: (context, index) {
            if (index >= schedules.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final kajian = schedules[index];
            return KajianTile(
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
  final UstadzEntity ustadz;

  const _ImageSection({
    required this.imageUrl,
    required this.ustadz,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (imageUrl.isNotEmpty) {
          context.showFullscreenImageDialog(
            imageUrl: imageUrl,
            overlayText: ustadz.name,
          );
        }
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerHighest,
        ),
        child: Stack(
          children: [
            if (imageUrl.isNotEmpty) ...[
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(
                    Icons.person,
                    size: 80,
                  ),
                ),
              ),
              // a indicator that the image is clickable
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surface
                        .withValues(alpha: 0.8),
                    border: Border.all(
                      color: context.theme.colorScheme.outline
                          .withValues(alpha: 0.3),
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
            ] else ...[
              Container(
                color: context.theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 80,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final UstadzEntity ustadz;

  const _InfoSection({required this.ustadz});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Symbols.menu_book,
                label: LocaleKeys.kajian.tr(),
                value: ustadz.kajianCount ?? '0',
              ),
            ),
            const HSpacer(width: 8),
            Expanded(
              child: _StatCard(
                icon: Symbols.people,
                label: LocaleKeys.subscribers.tr(),
                value: ustadz.subscribersCount ?? '0',
              ),
            ),
          ],
        ),
        const VSpacer(height: 16),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: context.theme.colorScheme.primary,
          ),
          const VSpacer(height: 8),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
