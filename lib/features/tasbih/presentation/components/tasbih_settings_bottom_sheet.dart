import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import '../../../../core/components/spacer.dart';
import '../blocs/tasbih_bloc.dart';

class TasbihSettingsBottomSheet extends StatelessWidget {
  const TasbihSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasbihBloc, TasbihState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.settings,
                        color: context.theme.colorScheme.primary,
                      ),
                      const HSpacer(width: 12),
                      Text(
                        LocaleKeys.tasbihSettings.tr(),
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Symbols.close),
                      ),
                    ],
                  ),
                ),

                // Settings Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Vibration Setting
                      Card(
                        child: SwitchListTile(
                          title: Text(LocaleKeys.vibration.tr()),
                          subtitle: Text(LocaleKeys.vibrationDescription.tr()),
                          // leading: const Icon(Symbols.vibration),
                          value: state.isVibrationEnabled,
                          onChanged: (_) => context.read<TasbihBloc>().add(
                                const TasbihEvent.toggleVibration(),
                              ),
                        ),
                      ),
                      const VSpacer(height: 12),

                      // Sound Setting
                      Card(
                        child: SwitchListTile(
                          title: Text(LocaleKeys.sound.tr()),
                          subtitle: Text(LocaleKeys.soundDescription.tr()),
                          // leading: const Icon(Symbols.volume_up),
                          value: state.isSoundEnabled,
                          onChanged: (_) => context.read<TasbihBloc>().add(
                                const TasbihEvent.toggleSound(),
                              ),
                        ),
                      ),
                      const VSpacer(height: 20),

                      // Statistics Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Symbols.analytics,
                                    color: context.theme.colorScheme.primary,
                                  ),
                                  const HSpacer(width: 12),
                                  Text(
                                    LocaleKeys.statistics.tr(),
                                    style:
                                        context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const VSpacer(height: 16),

                              // Total Counters
                              _StatisticRow(
                                icon: Symbols.countertops,
                                label: LocaleKeys.totalCounters.tr(),
                                value: state.counters.length.toString(),
                              ),
                              const VSpacer(height: 8),

                              // Completed Counters
                              _StatisticRow(
                                icon: Symbols.task_alt,
                                label: LocaleKeys.completedCounters.tr(),
                                value: state.counters
                                    .where((c) => c.isTargetReached)
                                    .length
                                    .toString(),
                              ),
                              const VSpacer(height: 8),

                              // Total Count Today
                              _StatisticRow(
                                icon: Symbols.today,
                                label: LocaleKeys.totalCountToday.tr(),
                                value: state.counters
                                    .where((c) =>
                                        c.lastUsed != null &&
                                        _isToday(c.lastUsed!))
                                    .fold<int>(0, (sum, c) => sum + c.count)
                                    .toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VSpacer(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _StatisticRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatisticRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.theme.colorScheme.onSurfaceVariant,
        ),
        const HSpacer(width: 12),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
