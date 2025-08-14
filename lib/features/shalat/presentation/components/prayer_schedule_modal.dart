import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/shalat/domain/entities/prayer_schedule_setting.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

class SholatNotificationBottomSheet extends StatefulWidget {
  final String playerName;
  final String time;
  final Function(Map)? onSave;
  final PrayerAlarm? prayerAlarm;
  const SholatNotificationBottomSheet(
      {super.key,
      this.playerName = '',
      this.time = '',
      this.onSave,
      this.prayerAlarm});

  @override
  State<SholatNotificationBottomSheet> createState() =>
      _SholatNotificationBottomSheetState();
}

class _SholatNotificationBottomSheetState
    extends State<SholatNotificationBottomSheet> {
  late ValueNotifier<bool> _controllerSwitch;
  int _selectedNotificationType = 2;
  bool _reminderEnabled = false;
  int _selectedReminderTime = 0;

  final List<Map<String, dynamic>> _notificationOptions = [
    {
      'icon': Symbols.volume_up,
      'label': LocaleKeys.notificationTypeAdhan.tr(),
    },
    {
      'icon': Symbols.notifications_active,
      'label': LocaleKeys.notificationTypeStandard.tr(),
    },
    {
      'icon': Symbols.notifications_none,
      'label': LocaleKeys.notificationTypeSilent.tr(),
    },
    {
      'icon': Symbols.notifications_off_rounded,
      'label': LocaleKeys.notificationTypeDisabled.tr(),
    },
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    _selectedReminderTime = widget.prayerAlarm?.reminderTime ?? 0;
    _selectedNotificationType = widget.prayerAlarm?.alarmType ?? 2;
    _reminderEnabled = widget.prayerAlarm?.reminderEnabled ?? false;
    _controllerSwitch = ValueNotifier<bool>(_reminderEnabled);
    _controllerSwitch.addListener(() {
      setState(() {
        if (_controllerSwitch.value) {
          _reminderEnabled = true;
          _selectedReminderTime = 5;
        } else {
          _reminderEnabled = false;
          _selectedReminderTime = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.playerName} ${widget.time}',
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Symbols.close),
                    color: context.theme.colorScheme.onSurface,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                LocaleKeys.prayerNotificationDescription.tr(),
                style: context.textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  color: context.theme.colorScheme.onSurface.withAlpha(
                    (0.5 * 255).toInt(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Notification Type Options
              ...List.generate(
                _notificationOptions.length,
                (index) {
                  final option = _notificationOptions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      option['icon'],
                      color: context.theme.colorScheme.onSurface,
                    ),
                    title: Text(
                      option['label'],
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedNotificationType = index;
                      });
                    },
                    trailing: Radio<int>(
                      value: index,
                      groupValue: _selectedNotificationType,
                      onChanged: (value) {
                        setState(() {
                          _selectedNotificationType = value!;
                        });
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 10),

              // Reminder Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${LocaleKeys.reminderLeadTimeLabel.tr()} ${widget.playerName}',
                  ),
                  Switch(
                    value: _reminderEnabled,
                    onChanged: _selectedNotificationType == 3
                        ? null
                        : (value) {
                            _controllerSwitch.value = value;
                          },
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [5, 15, 30].map((min) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(
                          '$min ${LocaleKeys.reminderLeadTimeUnit.tr()}',
                          style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: _selectedReminderTime == min
                                  ? FontWeight.bold
                                  : FontWeight.w600),
                        ),
                        selected: _reminderEnabled
                            ? _selectedReminderTime == min
                            : false,
                        onSelected: _reminderEnabled
                            ? (_) {
                                setState(() {
                                  _selectedReminderTime = min;
                                });
                              }
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.saveButtonLabel.tr(),
                    style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onPrimary,
                        fontSize: 16),
                  ),
                  onPressed: () {
                    // handle save logic here
                    widget.onSave?.call({
                      'notificationType': _selectedNotificationType,
                      'reminderEnabled': _reminderEnabled,
                      'reminderTime': _selectedReminderTime,
                    });
                    Navigator.of(context).pop();
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
