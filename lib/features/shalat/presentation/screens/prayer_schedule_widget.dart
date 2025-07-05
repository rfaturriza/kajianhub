import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';

class SholatNotificationBottomSheet extends StatefulWidget {
  final String playerName;
  final String time;
  final Function(Map)? onSave;
  const SholatNotificationBottomSheet(
      {super.key, this.playerName = '', this.time = '', this.onSave});

  @override
  State<SholatNotificationBottomSheet> createState() =>
      _SholatNotificationBottomSheetState();
}

class _SholatNotificationBottomSheetState
    extends State<SholatNotificationBottomSheet> {
  final _controllerSwitch = ValueNotifier<bool>(false);
  int _selectedNotificationType = 2;
  bool _reminderEnabled = false;
  int _selectedReminder = 0;

  final List<Map<String, dynamic>> _notificationOptions = [
    {
      'icon': Icons.volume_up,
      'label': LocaleKeys.player_schedule_modal_option1.tr(),
    },
    {
      'icon': Icons.notifications_none_outlined,
      'label': LocaleKeys.player_schedule_modal_option2.tr(),
    },
    {
      'icon': Icons.volume_off,
      'label': LocaleKeys.player_schedule_modal_option3.tr(),
    },
    {
      'icon': Icons.block,
      'label': LocaleKeys.player_schedule_modal_option4.tr(),
    },
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    _controllerSwitch.addListener(() {
      setState(() {
        if (_controllerSwitch.value) {
          _reminderEnabled = true;
        } else {
          _reminderEnabled = false;
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
                  Text('${widget.playerName} ${widget.time}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(LocaleKeys.player_schedule_modal_text1.tr(),
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 20),

              // Notification Type Options
              ...List.generate(_notificationOptions.length, (index) {
                final option = _notificationOptions[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(option['icon'], color: Color(0xff7E7E7E)),
                  title: Text(
                    option['label'],
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Color(0xff7E7E7E),
                    ),
                  ),
                  trailing: Theme(
                    data: Theme.of(context).copyWith(
                      radioTheme: RadioThemeData(
                        fillColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Color(0xffF1B340); // active color
                          }
                          return Colors.grey.shade300; // inactive color
                        }),
                      ),
                    ),
                    child: Transform.scale(
                      scale: 1.2,
                      child: Radio<int>(
                        value: index,
                        groupValue: _selectedNotificationType,
                        onChanged: (value) {
                          setState(() {
                            _selectedNotificationType = value!;
                          });
                        },
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: 10),

              // Reminder Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${LocaleKeys.player_schedule_modal_text2.tr()} ${widget.playerName}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  AdvancedSwitch(
                    controller: _controllerSwitch,
                    inactiveColor: Color(0xffE9E8EB),
                    enabled: _selectedNotificationType == 3 ? false : true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [5, 15, 30].map((min) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Text(
                        '$min ${LocaleKeys.player_schedule_modal_text3.tr()}',
                        style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: _selectedReminder == min
                                ? FontWeight.bold
                                : FontWeight.w600),
                      ),
                      selected:
                          _reminderEnabled ? _selectedReminder == min : false,
                      onSelected: _reminderEnabled
                          ? (_) {
                              setState(() {
                                _selectedReminder = min;
                              });
                            }
                          : null,
                      selectedColor: Color(0xffE2F0F1),
                      backgroundColor: Color(0xffFAFAFA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Change this value to adjust radius
                      ),
                      side: BorderSide(
                        color: _selectedReminder == min
                            ? Color(0xff57C7BD)
                            : Color(0xffE5F1F2),
                      ),
                    ),
                  );
                }).toList(),
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
                  child: Text(LocaleKeys.player_schedule_modal_text4.tr(),
                      style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    // handle save logic here
                    widget.onSave?.call({
                      'notificationType': _selectedNotificationType,
                      'reminderEnabled': _reminderEnabled,
                      'reminderTime': _selectedReminder,
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
