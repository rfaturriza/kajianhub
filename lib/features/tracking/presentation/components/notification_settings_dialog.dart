import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/injection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../data/dataSources/local/tracking_settings_local_data_source.dart';
import '../../domain/entities/tracking_settings.codegen.dart';
import '../../domain/services/goals_notification_service.dart';

class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  @override
  State<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<NotificationSettingsDialog> {
  late TrackingSettingsLocalDataSource settingsDataSource;
  late GoalsNotificationService goalsNotificationService;

  TrackingSettings? settings;
  bool isLoading = true;

  bool prayerRemindersEnabled = true;
  int prayerReminderDelayMinutes = 30;
  bool progressCheckReminderEnabled = true;
  TimeOfDay progressCheckReminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    settingsDataSource = sl<TrackingSettingsLocalDataSource>();
    goalsNotificationService = sl<GoalsNotificationService>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final result = await settingsDataSource.getTrackingSettings();
    result.fold(
      (failure) {
        // Use defaults if no settings found
      },
      (loadedSettings) {
        if (loadedSettings != null) {
          settings = loadedSettings;
          prayerRemindersEnabled = loadedSettings.prayerRemindersEnabled;
          prayerReminderDelayMinutes =
              loadedSettings.prayerReminderDelayMinutes;
          progressCheckReminderEnabled =
              loadedSettings.progressCheckReminderEnabled;
          progressCheckReminderTime =
              loadedSettings.progressCheckReminderTimeOfDay;
        }
      },
    );

    setState(() => isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => isLoading = true);

    final updatedSettings = (settings ?? TrackingSettings.defaultSettings())
        .copyWith(
          prayerRemindersEnabled: prayerRemindersEnabled,
          prayerReminderDelayMinutes: prayerReminderDelayMinutes,
          progressCheckReminderEnabled: progressCheckReminderEnabled,
        )
        .copyWithProgressCheckReminderTime(progressCheckReminderTime);

    final saveResult =
        await settingsDataSource.saveTrackingSettings(updatedSettings);

    saveResult.fold(
      (failure) {
        if (mounted) {
          context
              .showErrorToast(LocaleKeys.failedToSaveNotificationSettings.tr());
        }
      },
      (_) async {
        // Update notifications
        final notificationResult =
            await goalsNotificationService.updateNotificationSettings();

        notificationResult.fold(
          (failure) {
            if (mounted) {
              context.showInfoToast(
                  LocaleKeys.settingsSavedNotificationFailed.tr());
            }
          },
          (_) {
            if (mounted) {
              context.showInfoToast(
                  LocaleKeys.notificationSettingsUpdatedSuccessfully.tr());
              Navigator.of(context).pop();
            }
          },
        );
      },
    );

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Symbols.notifications,
            color: context.theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(LocaleKeys.notificationSettings.tr()),
        ],
      ),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Prayer Reminder Setting
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.mosque,
                              color: context.theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              LocaleKeys.prayerReminders.tr(),
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: prayerRemindersEnabled,
                              onChanged: (value) {
                                setState(() => prayerRemindersEnabled = value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocaleKeys.prayerRemindersDescription.tr(),
                          style: context.textTheme.bodySmall,
                        ),
                        if (prayerRemindersEnabled) ...[
                          const SizedBox(height: 16),
                          Text(
                            LocaleKeys.remindMeToTrackPrayer.tr(),
                            style: context.textTheme.labelMedium?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [15, 30, 45, 60].map((minutes) {
                              return FilterChip(
                                label:
                                    Text(LocaleKeys.minutesAfter.tr(namedArgs: {
                                  'minutes': minutes.toString(),
                                })),
                                selected: prayerReminderDelayMinutes == minutes,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() =>
                                        prayerReminderDelayMinutes = minutes);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Progress Check Reminder Setting
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.check_circle,
                              color: context.theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              LocaleKeys.eveningCheckIn.tr(),
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: progressCheckReminderEnabled,
                              onChanged: (value) {
                                setState(
                                    () => progressCheckReminderEnabled = value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocaleKeys.eveningCheckInDescription.tr(),
                          style: context.textTheme.bodySmall,
                        ),
                        if (progressCheckReminderEnabled) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: progressCheckReminderTime,
                              );
                              if (time != null) {
                                setState(
                                    () => progressCheckReminderTime = time);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: context.theme.colorScheme.outline),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.schedule,
                                    size: 16,
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(progressCheckReminderTime
                                      .format(context)),
                                  const Spacer(),
                                  Icon(
                                    Symbols.edit,
                                    size: 16,
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.cancel.tr()),
        ),
        FilledButton.icon(
          onPressed: isLoading ? null : _saveSettings,
          icon: const Icon(Symbols.save),
          label: Text(LocaleKeys.save.tr()),
        ),
      ],
    );
  }
}
