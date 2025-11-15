import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';

import '../../../setting/presentation/bloc/styling_setting/styling_setting_bloc.dart';

class PrayerTile extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;

  const PrayerTile({
    super.key,
    required this.prayer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayer.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (prayer.description.isNotEmpty) ...[
                const VSpacer(height: 8),
                Text(
                  prayer.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const VSpacer(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      context.theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: BlocBuilder<StylingSettingBloc, StylingSettingState>(
                  buildWhen: (p, c) => p.fontFamilyArabic != c.fontFamilyArabic,
                  builder: (context, stylingState) {
                    return Text(
                      prayer.arabicText,
                      style: context.textTheme.titleLarge?.copyWith(
                        height: 1.8,
                        fontFamily: stylingState.fontFamilyArabic,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
