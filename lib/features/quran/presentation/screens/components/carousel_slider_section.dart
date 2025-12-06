import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/shalat/presentation/components/shalat_info_card.dart';
import 'package:quranku/injection.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../kajian/presentation/components/kajian_nearby_card.dart';
import '../../../domain/entities/carousel_event.codegen.dart';
import '../../bloc/carousel_events/carousel_events_bloc.dart';

class CarouselSliderSection extends StatelessWidget {
  const CarouselSliderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CarouselEventsBloc>(),
      child: const _CarouselSliderView(),
    );
  }
}

class _CarouselSliderView extends StatefulWidget {
  const _CarouselSliderView();

  @override
  State<_CarouselSliderView> createState() => _CarouselSliderViewState();
}

class _CarouselSliderViewState extends State<_CarouselSliderView> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarouselEventsBloc, CarouselEventsState>(
      builder: (context, state) {
        // Build static slides and dynamic event slides
        final staticSlides = [
          const CarouselSlideData(
            id: 'shalat_info',
            type: CarouselSlideType.shalatInfo,
          ),
          const CarouselSlideData(
            id: 'kajian_nearby_event',
            type: CarouselSlideType.nearbyEvent,
          ),
        ];

        final eventSlides = state.events
            .map((event) => CarouselSlideData(
                  id: event.id.toString(),
                  type: CarouselSlideType.event,
                  imageUrl: event.imageUrl,
                  title: event.title,
                  description: event.description,
                  date: event.eventDate,
                  carouselEvent: event,
                ))
            .toList();

        final allSlides = [...staticSlides, ...eventSlides];

        if (allSlides.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: allSlides.length,
              itemBuilder: (context, index, realIndex) {
                final slideData = allSlides[index];

                if (slideData.type == CarouselSlideType.shalatInfo) {
                  return const ShalatInfoCard();
                } else if (slideData.type == CarouselSlideType.nearbyEvent) {
                  return KajianNearbyCard();
                } else {
                  return CarouselEventCard(
                    data: slideData,
                  );
                }
              },
              options: CarouselOptions(
                height: 200,
                viewportFraction: 0.9,
                initialPage: 0,
                enableInfiniteScroll: allSlides.length > 1,
                autoPlay: allSlides.length > 1,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(seconds: 1),
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            if (allSlides.length > 1) ...[
              const VSpacer(height: 8),
              _buildIndicators(allSlides.length),
            ],
          ],
        );
      },
    );
  }

  Widget _buildIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return GestureDetector(
          onTap: () => _carouselController.animateToPage(index),
          child: Container(
            width: _currentIndex == index ? 24 : 8,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentIndex == index
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        );
      }),
    );
  }
}

class CarouselEventCard extends StatelessWidget {
  final CarouselSlideData data;
  const CarouselEventCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    void launchLink() async {
      try {
        if (await canLaunchUrl(Uri.parse(data.link!))) {
          await launchUrl(
            Uri.parse(data.link!),
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (e) {
        // Handle error if needed
      }
    }

    return GestureDetector(
      onTap: launchLink,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: data.imageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: context.theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Container(
                      color: context.theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Symbols.broken_image,
                        size: 32,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        context.theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.title ?? '',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.theme.colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const VSpacer(height: 4),
                    Text(
                      data.description ?? '',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.surface
                            .withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.location != null || data.date != null) ...[
                      const VSpacer(height: 8),
                      Row(
                        children: [
                          if (data.location != null) ...[
                            Icon(
                              Symbols.location_on,
                              size: 14,
                              color: context.theme.colorScheme.surface
                                  .withValues(alpha: 0.8),
                            ),
                            const HSpacer(width: 4),
                            Expanded(
                              child: Text(
                                data.location!,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.theme.colorScheme.surface
                                      .withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (data.date != null) ...[
                            if (data.location != null) const HSpacer(width: 12),
                            Icon(
                              Symbols.calendar_today,
                              size: 14,
                              color: context.theme.colorScheme.surface
                                  .withValues(alpha: 0.8),
                            ),
                            const HSpacer(width: 4),
                            Text(
                              formatDate(data.date),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.theme.colorScheme.surface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDate(DateTime? date) {
  if (date == null) return '';

  final now = DateTime.now();
  final difference = date.difference(now).inDays;

  if (difference == 0) {
    return LocaleKeys.today.tr();
  } else if (difference == 1) {
    return LocaleKeys.tomorrow.tr();
  } else if (difference <= 7) {
    return DateFormat.E().format(date);
  } else {
    return '${date.day}/${date.month}';
  }
}

// Data models for carousel slides
class CarouselSlideData {
  final String id;
  final CarouselSlideType type;
  final String? imageUrl;
  final String? link;
  final String? title;
  final String? description;
  final String? location;
  final DateTime? date;
  final CarouselEvent? carouselEvent;

  const CarouselSlideData({
    required this.id,
    required this.type,
    this.imageUrl,
    this.link,
    this.title,
    this.description,
    this.location,
    this.date,
    this.carouselEvent,
  });
}

enum CarouselSlideType {
  shalatInfo,
  nearbyEvent,
  event,
}
