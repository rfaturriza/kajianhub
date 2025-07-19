import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../core/utils/extension/string_ext.dart';

class ScheduleCard extends StatelessWidget {
  final CustomSchedule schedule;

  const ScheduleCard({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final ustadzName = schedule.ustadz?.isNotEmpty == true
        ? schedule.ustadz!.first.name
        : emptyString;
    final theme = () {
      if (schedule.theme?.theme.isNotEmpty == true) {
        return schedule.theme!.theme;
      } else if (schedule.book?.isNotEmpty == true) {
        return schedule.book!;
      }
      return emptyString;
    }();
    final tanggal =
        schedule.date?.toEEEEddMMMMyyyy(context.locale) ?? emptyString;
    final waktuShalat = schedule.prayTime ?? emptyString;
    final waktu = schedule.timeStart ?? emptyString;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.theme.colorScheme.surface,
        border: Border.all(
          color: context.theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          if (schedule.title?.isNotEmpty == true) ...[
            Text(
              schedule.title!,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            const VSpacer(height: 8),
          ],

          // Information Grid
          Column(
            children: [
              // Row 1: Ustadz and Tema
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: LocaleKeys.ustadz.tr(),
                      value: ustadzName,
                      icon: Icons.person,
                    ),
                  ),
                  const HSpacer(width: 16),
                  Expanded(
                    child: _InfoItem(
                      label: LocaleKeys.theme.tr(),
                      value: theme,
                      icon: Icons.topic,
                    ),
                  ),
                ],
              ),
              const VSpacer(height: 8),

              // Row 2: Tanggal and Waktu Shalat
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: LocaleKeys.kajianDateSchedule.tr(),
                      value: tanggal,
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const HSpacer(width: 16),
                  Expanded(
                    child: _InfoItem(
                      label: LocaleKeys.prayerSchedule.tr(),
                      value: waktuShalat.isNotEmpty
                          ? waktuShalat.capitalize()
                          : emptyString,
                      icon: Icons.access_time_filled,
                    ),
                  ),
                ],
              ),
              const VSpacer(height: 8),

              // Row 3: Waktu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: LocaleKeys.time.tr(),
                      value: waktu,
                      icon: Icons.schedule,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: context.theme.colorScheme.primary,
            ),
            const HSpacer(width: 6),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const VSpacer(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            value.isNotEmpty ? value : '-',
            style: context.textTheme.bodyMedium?.copyWith(
              color: value.isNotEmpty
                  ? context.theme.colorScheme.onSurface
                  : context.theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
