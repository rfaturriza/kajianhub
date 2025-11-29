import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/shalat/domain/entities/prayer_in_app.dart';
import 'package:quranku/injection.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/daily_tracking_model.codegen.dart';
import '../../data/dataSources/local/tracking_local_data_source.dart';
import '../../data/dataSources/local/tracking_settings_local_data_source.dart';
import '../../domain/entities/tracking_settings.codegen.dart';
import '../../domain/services/goals_notification_service.dart';
import '../components/quick_goals_dialog.dart';
import '../components/notification_settings_dialog.dart';

class TrackingHistoryScreen extends StatefulWidget {
  const TrackingHistoryScreen({super.key});

  @override
  State<TrackingHistoryScreen> createState() => _TrackingHistoryScreenState();
}

class _TrackingHistoryScreenState extends State<TrackingHistoryScreen> {
  late TrackingLocalDataSource trackingDataSource;
  late TrackingSettingsLocalDataSource settingsDataSource;
  late GoalsNotificationService goalsNotificationService;
  List<DailyTrackingModel> trackingHistory = [];
  Map<String, dynamic>? statistics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    trackingDataSource = sl<TrackingLocalDataSource>();
    settingsDataSource = sl<TrackingSettingsLocalDataSource>();
    goalsNotificationService = sl<GoalsNotificationService>();
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    setState(() => isLoading = true);

    // Load history
    final historyResult = await trackingDataSource.getTrackingHistory();
    historyResult.fold(
      (failure) => context.showErrorToast(
        LocaleKeys.defaultErrorMessage.tr(),
      ),
      (history) => trackingHistory = history,
    );

    // Load statistics
    final statsResult = await trackingDataSource.getTrackingStatistics();
    statsResult.fold(
      (failure) => context.showErrorToast(
        LocaleKeys.defaultErrorMessage.tr(),
      ),
      (stats) => statistics = stats,
    );

    setState(() => isLoading = false);
  }

  void _showGoalsDialog() {
    // Get current goals from the most recent tracking entry, or use defaults
    int currentAyahGoal = 30;
    int currentMinuteGoal = 20;

    if (trackingHistory.isNotEmpty) {
      final latestTracking = trackingHistory.first;
      currentAyahGoal = latestTracking.dailyAyahGoal;
      currentMinuteGoal = latestTracking.dailyMinuteGoal;
    }

    showDialog(
      context: context,
      builder: (context) => QuickGoalsDialog(
        currentAyahGoal: currentAyahGoal,
        currentMinuteGoal: currentMinuteGoal,
        onSave: (ayahGoal, minuteGoal) {
          _updateDefaultGoals(ayahGoal, minuteGoal);
        },
      ),
    );
  }

  void _showNotificationSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const NotificationSettingsDialog(),
    );
  }

  Future<void> _updateDefaultGoals(int ayahGoal, int minuteGoal) async {
    try {
      // Get current settings or create new ones
      var settings = TrackingSettings(
        defaultDailyAyahGoal: ayahGoal,
        defaultDailyMinuteGoal: minuteGoal,
        createdAt: DateTime.now(),
      );
      final settingsResult = await settingsDataSource.getTrackingSettings();

      settingsResult.fold(
        (failure) {
          // Create new settings if none exist
        },
        (existingSettings) {
          if (existingSettings != null) {
            // Update existing settings
            settings = existingSettings.copyWith(
              defaultDailyAyahGoal: ayahGoal,
              defaultDailyMinuteGoal: minuteGoal,
              updatedAt: DateTime.now(),
            );
          }
        },
      );

      // Save the settings
      final saveResult =
          await settingsDataSource.saveTrackingSettings(settings);

      saveResult.fold(
        (failure) {
          context.showErrorToast(
            LocaleKeys.defaultErrorMessage.tr(),
          );
        },
        (_) async {
          // Update notification settings after saving
          final notificationResult =
              await goalsNotificationService.updateNotificationSettings();

          notificationResult.fold(
            (failure) {
              // Show warning about notification failure but still show success for goals update
              context.showInfoToast(
                LocaleKeys.dailyGoalsUpdatedButNotificationFailed.tr(),
              );
            },
            (_) {
              context.showInfoToast(
                LocaleKeys.dailyGoalsUpdated.tr(
                  namedArgs: {
                    'ayahGoal': ayahGoal.toString(),
                    'minuteGoal': minuteGoal.toString(),
                  },
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      context.showErrorToast(
        LocaleKeys.defaultErrorMessage.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.dailyGoals.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Symbols.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'goals':
                  _showGoalsDialog();
                  break;
                case 'notifications':
                  _showNotificationSettingsDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'goals',
                child: Row(
                  children: [
                    const Icon(Symbols.flag),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.setDailyGoals.tr(),
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    const Icon(Symbols.notifications),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.notificationSettings.tr(),
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (trackingHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.history,
                    size: 64,
                    color: context.theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.noTrackingData.tr(),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // 'Start tracking your prayers and Quran reading!',
                    LocaleKeys.startTrackingPrompt.tr(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Statistics Section
              if (statistics != null) _buildStatisticsSection(),
              // History List
              ...trackingHistory
                  .map((tracking) => _buildTrackingItem(tracking)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final stats = statistics!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.analytics,
                color: context.theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.statistics.tr(),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: context.isPortrait ? 2 : 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                LocaleKeys.totalDays.tr(),
                stats['totalDays'].toString(),
                Symbols.calendar_today,
                Colors.blue,
              ),
              _buildStatCard(
                LocaleKeys.prayerStreak.tr(),
                stats['currentPrayerStreak'] == 1
                    ? '${stats['currentPrayerStreak']} ${LocaleKeys.day.tr()}'
                    : '${stats['currentPrayerStreak']} ${LocaleKeys.days.tr()}',
                Symbols.mosque,
                Colors.green,
              ),
              _buildStatCard(
                LocaleKeys.quranStreak.tr(),
                stats['currentQuranStreak'] == 1
                    ? '${stats['currentQuranStreak']} ${LocaleKeys.day.tr()}'
                    : '${stats['currentQuranStreak']} ${LocaleKeys.days.tr()}',
                Symbols.menu_book,
                Colors.purple,
              ),
              _buildStatCard(
                LocaleKeys.totalAyahs.tr(),
                stats['totalAyahs'].toString(),
                Symbols.text_ad,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingItem(DailyTrackingModel tracking) {
    final date = tracking.dateTime;
    final isToday =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) == tracking.date;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? context.theme.colorScheme.primaryContainer.withAlpha(100)
            : context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(
                color: context.theme.colorScheme.primary.withAlpha(100))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Row(
            children: [
              Icon(
                Symbols.calendar_today,
                size: 16,
                color: isToday
                    ? context.theme.colorScheme.primary
                    : context.theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, MMM d, y').format(date),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.onSurface,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    LocaleKeys.today.tr(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Prayer Status
          Row(
            children: [
              Icon(
                Symbols.mosque,
                size: 14,
                color: context.theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              // Prayer dots
              Row(
                children: [
                  _buildPrayerDot(
                    tracking.fajr,
                    PrayerInApp.subuh.name.capitalize(),
                  ),
                  const SizedBox(width: 4),
                  _buildPrayerDot(
                    tracking.dhuhr,
                    PrayerInApp.dzuhur.name.capitalize(),
                  ),
                  const SizedBox(width: 4),
                  _buildPrayerDot(
                    tracking.asr,
                    PrayerInApp.ashar.name.capitalize(),
                  ),
                  const SizedBox(width: 4),
                  _buildPrayerDot(
                    tracking.maghrib,
                    PrayerInApp.maghrib.name.capitalize(),
                  ),
                  const SizedBox(width: 4),
                  _buildPrayerDot(
                    tracking.isha,
                    PrayerInApp.isya.name.capitalize(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quran Status
          Row(
            children: [
              Icon(
                Symbols.menu_book,
                size: 14,
                color: context.theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.quranTrackingSummary.tr(
                  namedArgs: {
                    'ayahsRead': tracking.ayahsRead.toString(),
                    'dailyAyahGoal': tracking.dailyAyahGoal.toString(),
                    'minutesRead': tracking.minutesRead.toString(),
                    'dailyMinuteGoal': tracking.dailyMinuteGoal.toString(),
                  },
                ),
                style: context.textTheme.bodyMedium,
              ),
              const Spacer(),
              if (tracking.isQuranGoalAchieved)
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
            ],
          ),

          // Progress Bars
          if (tracking.ayahsRead > 0 || tracking.minutesRead > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: tracking.ayahProgress.clamp(0.0, 1.0),
                        backgroundColor:
                            context.theme.colorScheme.outline.withAlpha(50),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocaleKeys.verses.tr(),
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: tracking.minuteProgress.clamp(0.0, 1.0),
                        backgroundColor:
                            context.theme.colorScheme.outline.withAlpha(50),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocaleKeys.minutes.tr(),
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerDot(bool completed, String letter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: completed
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.onSurfaceVariant,
            width: 1,
          ),
        ),
        color: completed
            ? context.theme.colorScheme.primary
            : context.theme.colorScheme.outline.withAlpha(50),
      ),
      child: Row(
        children: [
          if (completed) ...[
            Icon(
              Symbols.check,
              size: 10,
              color: completed
                  ? context.theme.colorScheme.onPrimary
                  : context.theme.colorScheme.onSurfaceVariant,
            ),
          ],
          const SizedBox(width: 2),
          Text(
            letter,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: completed
                  ? context.theme.colorScheme.onPrimary
                  : context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
