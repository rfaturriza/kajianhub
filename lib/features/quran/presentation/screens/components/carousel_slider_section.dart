import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/shalat/presentation/components/shalat_info_card.dart';

import '../../../../kajian/presentation/components/kajian_nearby_card.dart';

class CarouselSliderSection extends StatefulWidget {
  const CarouselSliderSection({super.key});

  @override
  State<CarouselSliderSection> createState() => _CarouselSliderSectionState();
}

class _CarouselSliderSectionState extends State<CarouselSliderSection> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Dummy data for carousel slides
  final List<CarouselSlideData> _carouselData = [
    CarouselSlideData(
      id: 'shalat_info',
      type: CarouselSlideType.shalatInfo,
    ),
    CarouselSlideData(
      id: 'kajian_nearby_event',
      type: CarouselSlideType.nearbyEvent,
    ),
    CarouselSlideData(
      id: 'kajian_1',
      type: CarouselSlideType.event,
      imageUrl:
          'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      title: 'Kajian Tafsir Al-Quran',
      description:
          'Memahami makna mendalam ayat-ayat Al-Quran dengan metode tafsir modern',
      location: 'Masjid Al-Ikhlas, Jakarta Selatan',
      date: DateTime.now().add(const Duration(days: 3)),
    ),
    CarouselSlideData(
      id: 'kajian_2',
      type: CarouselSlideType.event,
      imageUrl:
          'https://images.unsplash.com/photo-1591604021695-0c72c2d50f1e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      title: 'Daurah Hadits Bukhari',
      description:
          'Kajian mendalam kitab Shahih Bukhari bersama Ustadz terkenal',
      location: 'Islamic Center, Bandung',
      date: DateTime.now().add(const Duration(days: 7)),
    ),
    CarouselSlideData(
      id: 'kajian_3',
      type: CarouselSlideType.event,
      imageUrl:
          'https://images.unsplash.com/photo-1609220136736-443140cffec6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      title: 'Sesi Tanya Jawab Agama',
      description:
          'Ruang diskusi terbuka untuk berbagai pertanyaan seputar Islam',
      location: 'Pesantren Modern, Yogyakarta',
      date: DateTime.now().add(const Duration(days: 5)),
    ),
    CarouselSlideData(
      id: 'kajian_4',
      type: CarouselSlideType.event,
      imageUrl:
          'https://images.unsplash.com/photo-1544816155-12df9643f363?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      title: 'Workshop Tahfidz Al-Quran',
      description:
          'Pelatihan menghafal Al-Quran dengan teknik mudah dan efektif',
      location: 'Pondok Tahfidz As-Salam, Bogor',
      date: DateTime.now().add(const Duration(days: 10)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: _carouselData.length,
          itemBuilder: (context, index, realIndex) {
            final slideData = _carouselData[index];

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
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const VSpacer(height: 8),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _carouselData.asMap().entries.map((entry) {
        int index = entry.key;
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
      }).toList(),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                errorWidget: (context, url, error) => Container(
                  color: context.theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.error,
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
                      Colors.black.withValues(alpha: 0.7),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const VSpacer(height: 4),
                  Text(
                    data.description ?? '',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const VSpacer(height: 8),
                  Row(
                    children: [
                      Icon(
                        Symbols.location_on,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const HSpacer(width: 4),
                      Expanded(
                        child: Text(
                          data.location ?? '',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const HSpacer(width: 12),
                      Icon(
                        Symbols.calendar_today,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const HSpacer(width: 4),
                      Text(
                        formatDate(data.date),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
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

String formatDate(DateTime? date) {
  if (date == null) return '';

  final now = DateTime.now();
  final difference = date.difference(now).inDays;

  if (difference == 0) {
    return 'Hari ini';
  } else if (difference == 1) {
    return 'Besok';
  } else if (difference <= 7) {
    return '$difference hari lagi';
  } else {
    return '${date.day}/${date.month}';
  }
}

// Data models for carousel slides
class CarouselSlideData {
  final String id;
  final CarouselSlideType type;
  final String? imageUrl;
  final String? title;
  final String? description;
  final String? location;
  final DateTime? date;

  const CarouselSlideData({
    required this.id,
    required this.type,
    this.imageUrl,
    this.title,
    this.description,
    this.location,
    this.date,
  });
}

enum CarouselSlideType {
  shalatInfo,
  nearbyEvent,
  event,
}
