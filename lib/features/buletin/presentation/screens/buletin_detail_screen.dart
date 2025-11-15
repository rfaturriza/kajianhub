import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/buletin/presentation/blocs/buletin_detail_bloc.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/injection.dart';

class BuletinDetailScreen extends StatelessWidget {
  final int buletinId;

  const BuletinDetailScreen({
    super.key,
    required this.buletinId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BuletinDetailBloc>()
        ..add(BuletinDetailEvent.loadBuletinDetail(buletinId)),
      child: const BuletinDetailView(),
    );
  }
}

class BuletinDetailView extends StatefulWidget {
  const BuletinDetailView({super.key});

  @override
  State<BuletinDetailView> createState() => _BuletinDetailViewState();
}

class _BuletinDetailViewState extends State<BuletinDetailView> {
  double _fontSize = 16.0; // Default font size

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 24.0) {
        _fontSize += 2.0;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12.0) {
        _fontSize -= 2.0;
      }
    });
  }

  void _resetFontSize() {
    setState(() {
      _fontSize = 16.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      body: BlocBuilder<BuletinDetailBloc, BuletinDetailState>(
        builder: (context, state) {
          if (state.status.isInProgress) {
            return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.buletin.tr()),
                backgroundColor: context.theme.colorScheme.surface,
                foregroundColor: context.theme.colorScheme.onSurface,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state.status.isFailure || state.buletin == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.buletin.tr()),
                backgroundColor: context.theme.colorScheme.surface,
                foregroundColor: context.theme.colorScheme.onSurface,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.error_outline,
                      size: 64,
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      LocaleKeys.errorGetBuletin.tr(),
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: Text(LocaleKeys.backToBuletin.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          final buletin = state.buletin!;

          return Scaffold(
            backgroundColor: context.theme.colorScheme.surface,
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Increase font size
                FloatingActionButton.small(
                  onPressed: _fontSize < 24.0 ? _increaseFontSize : null,
                  backgroundColor: _fontSize < 24.0
                      ? context.theme.colorScheme.primaryContainer
                      : context.theme.colorScheme.outline.withAlpha(50),
                  foregroundColor: _fontSize < 24.0
                      ? context.theme.colorScheme.onPrimaryContainer
                      : context.theme.colorScheme.outline,
                  heroTag: "increase",
                  child: const Icon(Symbols.add, size: 18),
                ),
                const SizedBox(height: 8),
                // Decrease font size
                FloatingActionButton.small(
                  onPressed: _fontSize > 12.0 ? _decreaseFontSize : null,
                  backgroundColor: _fontSize > 12.0
                      ? context.theme.colorScheme.primaryContainer
                      : context.theme.colorScheme.outline.withAlpha(50),
                  foregroundColor: _fontSize > 12.0
                      ? context.theme.colorScheme.onPrimaryContainer
                      : context.theme.colorScheme.outline,
                  heroTag: "decrease",
                  child: const Icon(Symbols.remove, size: 18),
                ),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                // App bar with image
                SliverAppBar(
                  expandedHeight: buletin.pictureUrl != null ? 250 : 80,
                  floating: false,
                  pinned: true,
                  backgroundColor: context.theme.colorScheme.surface,
                  foregroundColor: context.theme.colorScheme.onSurface,
                  actions: [
                    // Font size indicator
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_fontSize.round()}pt',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Font size controls
                    PopupMenuButton<String>(
                      icon: const Icon(Symbols.text_fields),
                      onSelected: (value) {
                        switch (value) {
                          case 'increase':
                            _increaseFontSize();
                            break;
                          case 'decrease':
                            _decreaseFontSize();
                            break;
                          case 'reset':
                            _resetFontSize();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'increase',
                          enabled: _fontSize < 24.0,
                          child: Row(
                            children: [
                              const Icon(Symbols.add),
                              const SizedBox(width: 8),
                              Text(LocaleKeys.increaseFontSize.tr()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'decrease',
                          enabled: _fontSize > 12.0,
                          child: Row(
                            children: [
                              const Icon(Symbols.remove),
                              const SizedBox(width: 8),
                              Text(LocaleKeys.decreaseFontSize.tr()),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'reset',
                          child: Row(
                            children: [
                              const Icon(Symbols.refresh),
                              const SizedBox(width: 8),
                              Text(LocaleKeys.resetFontSize.tr()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    // title: Text(
                    //   buletin.title,
                    //   style: context.textTheme.titleMedium?.copyWith(
                    //     color: context.theme.colorScheme.onSurface,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    background: buletin.pictureUrl != null
                        ? CachedNetworkImage(
                            imageUrl: buletin.pictureUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: context.theme.colorScheme.surfaceContainer,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: context.theme.colorScheme.surfaceContainer,
                              child: Icon(
                                Symbols.image_not_supported_rounded,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),

                // Sticky Title Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTitleDelegate(
                    title: buletin.title,
                    textTheme: context.textTheme,
                    colorScheme: context.theme.colorScheme,
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meta information
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            // Author
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Symbols.person_outline,
                                  size: 16,
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  LocaleKeys.createdBy.tr(namedArgs: {
                                    'name': buletin.createdByUser?.name ?? '-',
                                  }),
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),

                            // Date
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Symbols.schedule_rounded,
                                  size: 16,
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  LocaleKeys.publishedAt.tr(namedArgs: {
                                    'date': _formatDate(buletin.createdAt),
                                  }),
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Content with HTML
                        Html(
                          data: buletin.content,
                          style: {
                            "body": Style(
                              color: context.theme.colorScheme.onSurface,
                              fontFamily:
                                  context.textTheme.bodyLarge?.fontFamily,
                              fontSize: FontSize(_fontSize),
                              lineHeight: const LineHeight(1.6),
                            ),
                            "p": Style(
                              fontSize: FontSize(_fontSize),
                              margin: Margins.only(bottom: 12),
                            ),
                            "h1, h2, h3, h4, h5, h6": Style(
                              fontSize: FontSize(_fontSize + 4),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(top: 16, bottom: 8),
                            ),
                            "a": Style(
                              color: context.theme.colorScheme.primary,
                              textDecoration: TextDecoration.underline,
                              fontSize: FontSize(_fontSize),
                            ),
                            "li": Style(
                              fontSize: FontSize(_fontSize),
                              margin: Margins.only(bottom: 4),
                            ),
                            "blockquote": Style(
                              fontSize: FontSize(_fontSize),
                              fontStyle: FontStyle.italic,
                              padding: HtmlPaddings.symmetric(
                                  horizontal: 16, vertical: 8),
                              border: Border(
                                left: BorderSide(
                                  color: context.theme.colorScheme.primary,
                                  width: 4,
                                ),
                              ),
                            ),
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id').format(date);
  }
}

class _StickyTitleDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  _StickyTitleDelegate({
    required this.title,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  double get minExtent => 70.0;

  @override
  double get maxExtent => 100.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate opacity based on scroll progress
    final double opacity = (shrinkOffset / maxExtent).clamp(0.0, 1.0);

    // Calculate text style transition from titleLarge to titleMedium
    // Use a threshold to avoid too frequent changes
    final bool isScrolled = opacity > 0.2;
    final TextStyle? baseStyle =
        isScrolled ? textTheme.titleMedium : textTheme.titleLarge;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.90 + (opacity * 0.1)),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: opacity * 0.5),
            width: 1,
          ),
        ),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: opacity * 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: baseStyle?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ) ??
                TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
            child: Text(
              title,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
