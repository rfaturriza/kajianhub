import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../injection.dart';
import '../../../tracking/data/dataSources/local/tracking_local_data_source.dart';
import '../../../tracking/data/models/daily_tracking_model.codegen.dart';
import '../../../tracking/presentation/components/quick_goals_dialog.dart';
import '../../../tracking/presentation/screens/tracking_history_screen.dart';

class TrackingSection extends StatefulWidget {
  const TrackingSection({super.key});

  @override
  State<TrackingSection> createState() => _TrackingSectionState();
}

class _TrackingSectionState extends State<TrackingSection> {
  late TrackingLocalDataSource trackingDataSource;
  DailyTrackingModel? todayTracking;
  bool isLoading = true;
  String get todayDateString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    trackingDataSource = sl<TrackingLocalDataSource>();
    _loadTodayTracking();
  }

  Future<void> _loadTodayTracking() async {
    if (mounted) setState(() => isLoading = true);

    try {
      // Try to get tracking with default goals from settings
      final result =
          await trackingDataSource.getDailyTrackingOrCreate(todayDateString);

      result.fold(
        (failure) {
          // Fallback to default tracking on failure
          todayTracking = DailyTrackingModel(
            date: todayDateString,
            createdAt: DateTime.now(),
          );
        },
        (tracking) {
          todayTracking = tracking;
        },
      );
    } catch (e) {
      // Fallback to default tracking on any error
      todayTracking = DailyTrackingModel(
        date: todayDateString,
        createdAt: DateTime.now(),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _updateTracking(DailyTrackingModel updatedTracking) async {
    await trackingDataSource.saveDailyTracking(updatedTracking);
    setState(() {
      todayTracking = updatedTracking;
    });
  }

  void _showGoalsDialog(BuildContext context, DailyTrackingModel tracking) {
    showDialog(
      context: context,
      builder: (context) => QuickGoalsDialog(
        currentAyahGoal: tracking.dailyAyahGoal,
        currentMinuteGoal: tracking.dailyMinuteGoal,
        onSave: (ayahGoal, minuteGoal) {
          _updateTrackingGoals(ayahGoal, minuteGoal);
        },
      ),
    );
  }

  Future<void> _updateTrackingGoals(int ayahGoal, int minuteGoal) async {
    if (todayTracking != null) {
      final updatedTracking = todayTracking!.copyWith(
        dailyAyahGoal: ayahGoal,
        dailyMinuteGoal: minuteGoal,
      );
      await _updateTracking(updatedTracking);

      if (mounted) {
        context.showInfoToast(
          LocaleKeys.dailyGoalsUpdated.tr(
            namedArgs: {
              'ayahGoal': ayahGoal.toString(),
              'minuteGoal': minuteGoal.toString(),
            },
          ),
        );
      }
    }
  }

  // Prayer tracking
  List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  Widget build(BuildContext context) {
    if (isLoading || todayTracking == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final tracking = todayTracking!;
    final List<bool> prayerStatus = [
      tracking.fajr,
      tracking.dhuhr,
      tracking.asr,
      tracking.maghrib,
      tracking.isha,
    ];

    int completedPrayers = tracking.completedPrayers;
    double quranAyahProgress = tracking.ayahProgress;
    double quranTimeProgress = tracking.minuteProgress;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                LocaleKeys.dailyGoals.tr(),
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showGoalsDialog(context, tracking),
                icon: Icon(
                  Symbols.tune,
                  size: 20,
                  color: context.theme.colorScheme.primary,
                ),
                tooltip: 'Adjust Goals',
                visualDensity: VisualDensity.compact,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrackingHistoryScreen(),
                    ),
                  );
                },
                child: Text(
                  LocaleKeys.seeAll.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          // Prayer Tracking
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.theme.colorScheme.outline.withAlpha(50),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.prayer_times,
                      color: context.theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.prayer.tr(),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (tracking.isQuranGoalAchieved)
                      Icon(
                        Symbols.star,
                        color: context.theme.colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () async {
                          DailyTrackingModel updatedTracking;
                          switch (index) {
                            case 0:
                              updatedTracking =
                                  tracking.copyWith(fajr: !tracking.fajr);
                              break;
                            case 1:
                              updatedTracking =
                                  tracking.copyWith(dhuhr: !tracking.dhuhr);
                              break;
                            case 2:
                              updatedTracking =
                                  tracking.copyWith(asr: !tracking.asr);
                              break;
                            case 3:
                              updatedTracking =
                                  tracking.copyWith(maghrib: !tracking.maghrib);
                              break;
                            case 4:
                              updatedTracking =
                                  tracking.copyWith(isha: !tracking.isha);
                              break;
                            default:
                              return;
                          }
                          await _updateTracking(updatedTracking);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: prayerStatus[index]
                                    ? context.theme.colorScheme.primary
                                    : context.theme.colorScheme.outline
                                        .withAlpha(50),
                                border: Border.all(
                                  color: context.theme.colorScheme.primary,
                                  width: prayerStatus[index] ? 0 : 1,
                                ),
                              ),
                              child: prayerStatus[index]
                                  ? Icon(
                                      Symbols.check,
                                      size: 16,
                                      color:
                                          context.theme.colorScheme.onPrimary,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prayerNames[index],
                              style: context.textTheme.bodySmall?.copyWith(
                                color: prayerStatus[index]
                                    ? context.theme.colorScheme.primary
                                    : context
                                        .theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Text(
                      '$completedPrayers/${prayerNames.length}',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quran Tracking
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.theme.colorScheme.outline.withAlpha(50),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.menu_book,
                      color: context.theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Al-Qur`an',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (tracking.isQuranGoalAchieved)
                      Icon(
                        Symbols.star,
                        color: context.theme.colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Ayah progress
                Row(
                  children: [
                    Text(
                      LocaleKeys.verses.tr(),
                      style: context.textTheme.labelMedium,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final updatedTracking = tracking.copyWith(
                          ayahsRead: (tracking.ayahsRead + 5)
                              .clamp(0, tracking.dailyAyahGoal + 10),
                        );
                        await _updateTracking(updatedTracking);
                      },
                      child: Icon(
                        Symbols.add_circle_outline,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${tracking.ayahsRead}/${tracking.dailyAyahGoal}',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: quranAyahProgress.clamp(0.0, 1.0),
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: context.theme.colorScheme.outline.withAlpha(
                    50,
                  ),
                  minHeight: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                // Minutes progress
                Row(
                  children: [
                    Text(
                      LocaleKeys.minutes.tr(),
                      style: context.textTheme.labelMedium,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final updatedTracking = tracking.copyWith(
                          minutesRead: (tracking.minutesRead + 2)
                              .clamp(0, tracking.dailyMinuteGoal + 10),
                        );
                        await _updateTracking(updatedTracking);
                      },
                      child: Icon(
                        Symbols.add_circle_outline,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${tracking.minutesRead}/${tracking.dailyMinuteGoal}',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: quranTimeProgress.clamp(0.0, 1.0),
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: context.theme.colorScheme.outline.withAlpha(
                    50,
                  ),
                  minHeight: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
