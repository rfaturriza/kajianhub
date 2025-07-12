// ignore_for_file: unused_element

import 'package:adhan/adhan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jhijri/_src/_jHijri.dart';
import 'package:quranku/core/constants/asset_constants.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/shalat/domain/entities/prayer_schedule_setting.codegen.dart';
import 'package:quranku/features/shalat/domain/entities/schedule.codegen.dart';
import 'package:quranku/features/shalat/presentation/helper/helper_time_shalat.dart';
import 'package:quranku/features/shalat/presentation/components/prayer_schedule_modal.dart';

import '../../../setting/presentation/bloc/language_setting/language_setting_bloc.dart';
import '../../domain/entities/prayer_in_app.dart';
import '../bloc/shalat/shalat_bloc.dart';

class PrayerScheduleScreen extends StatelessWidget {
  const PrayerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ShalatBloc>()
        ..add(
          const ShalatEvent.getPrayerScheduleSettingEvent(),
        ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          }

          context
              .read<ShalatBloc>()
              .add(const ShalatEvent.checkAndUpdateNotificationsEvent());
          context.pop(false);
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(),
          body: Column(
            children: [
              const _InfoSection(),
              Expanded(
                child: const _PrayerScheduleSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    final dateNow = DateTime.now();
    final dateString = DateFormat(
      'EEEE, dd MMMM yyyy',
      context.locale.languageCode,
    ).format(dateNow);
    final hijriDate = JHijri.now();
    final hijriDateString =
        '${hijriDate.day} ${englishHMonth(hijriDate.month)} ${hijriDate.year}';
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(AssetConst.prayerTimeBackground),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            context.theme.colorScheme.surface.withValues(alpha: 0.5),
            context.isDarkMode ? BlendMode.darken : BlendMode.lighten,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BlocBuilder<LanguageSettingBloc, LanguageSettingState>(
              buildWhen: (p, c) => p.languagePrayerTime != c.languagePrayerTime,
              builder: (context, languageSettingState) {
                return BlocBuilder<ShalatBloc, ShalatState>(
                  builder: (context, state) {
                    final shalat = () {
                      if (state.scheduleByDay?.isRight() == true) {
                        return HelperTimeShalat.getShalatNameByTime(
                          state.scheduleByDay?.asRight()?.schedule,
                          languageSettingState.languagePrayerTime,
                        ).toUpperCase();
                      }
                      return emptyString;
                    }();

                    final shalatTime = () {
                      if (state.scheduleByDay?.isRight() == true) {
                        return HelperTimeShalat.getShalatTimeByShalatName(
                              state.scheduleByDay?.asRight()?.schedule,
                              shalat,
                              languageSettingState.languagePrayerTime,
                            ) ??
                            '-';
                      }
                      return emptyString;
                    }();

                    final place = state.geoLocation?.place ?? '-';
                    if (state.isLoading) {
                      return const Center(child: LinearProgressIndicator());
                    }
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            shalat,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            shalatTime,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                dateString,
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                hijriDateString,
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetCalculationSetting extends StatelessWidget {
  const _BottomSheetCalculationSetting();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShalatBloc, ShalatState>(
      builder: (context, state) {
        return SafeArea(
          child: Wrap(children: [
            Column(
              children: [
                ListTile(
                  title: Text(
                    'Metode Perhitungan',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    state.prayerScheduleSetting
                            ?.asRight()
                            ?.calculationMethod
                            .name
                            .capitalizeEveryWord() ??
                        '-',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const _CalculationMethodPickerDialog();
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    'Mazhab',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    state.prayerScheduleSetting
                            ?.asRight()
                            ?.madhab
                            .name
                            .capitalizeEveryWord() ??
                        '-',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const _MadhabPickerDialog();
                      },
                    );
                  },
                ),
              ],
            ),
          ]),
        );
      },
    );
  }
}

class _LocationSettingPickerDialog extends StatelessWidget {
  const _LocationSettingPickerDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ListTile.divideTiles(
          color: context.theme.dividerColor,
          context: context,
          tiles: [
            'Auto',
            'Manual',
          ].map((mode) {
            return ListTile(
              tileColor: mode == 'Auto'
                  ? context.theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              title: Text(
                mode,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {},
            );
          }).toList(),
        ).toList(),
      ),
    );
  }
}

class _CalculationMethodPickerDialog extends StatelessWidget {
  const _CalculationMethodPickerDialog();

  @override
  Widget build(BuildContext context) {
    final setting =
        context.read<ShalatBloc>().state.prayerScheduleSetting?.asRight();
    final calculationMethod = setting?.calculationMethod;
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ListTile.divideTiles(
          color: context.theme.dividerColor,
          context: context,
          tiles: CalculationMethod.values.map((val) {
            return ListTile(
              tileColor: val.name == calculationMethod?.name
                  ? context.theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              title: Text(
                val.name.capitalizeEveryWord(),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                context.read<ShalatBloc>().add(
                      ShalatEvent.setPrayerScheduleSettingEvent(
                        model: setting?.copyWith(
                          calculationMethod: val,
                        ),
                      ),
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ).toList(),
      ),
    );
  }
}

class _MadhabPickerDialog extends StatelessWidget {
  const _MadhabPickerDialog();

  @override
  Widget build(BuildContext context) {
    final setting =
        context.read<ShalatBloc>().state.prayerScheduleSetting?.asRight();
    final madhab = setting?.madhab;
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ListTile.divideTiles(
          color: context.theme.dividerColor,
          context: context,
          tiles: Madhab.values.map((val) {
            return ListTile(
              tileColor: val.name == madhab?.name
                  ? context.theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              title: Text(
                val.name.capitalizeEveryWord(),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                context.read<ShalatBloc>().add(
                      ShalatEvent.setPrayerScheduleSettingEvent(
                        model: setting?.copyWith(
                          madhab: val,
                        ),
                      ),
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ).toList(),
      ),
    );
  }
}

class _PrayerScheduleSection extends StatefulWidget {
  const _PrayerScheduleSection();

  @override
  State<_PrayerScheduleSection> createState() => _PrayerScheduleSectionState();
}

class _PrayerScheduleSectionState extends State<_PrayerScheduleSection> {
  DateTime dateSelected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DatePickerSection(
          onDateChanged: (date) {
            setState(() {
              dateSelected = date;
            });
          },
          dateNow: dateSelected,
        ),
        Expanded(
          child: BlocBuilder<ShalatBloc, ShalatState>(
            buildWhen: (p, c) =>
                p.prayerScheduleSetting != c.prayerScheduleSetting,
            builder: (context, state) {
              if (state.prayerScheduleSetting?.isLeft() == true) {
                return Card(
                  child: ListTile(
                    title: Text(
                      state.prayerScheduleSetting?.asLeft().message ??
                          'Tidak ada jadwal shalat',
                    ),
                  ),
                );
              }
              final schedule = state.prayerScheduleSetting?.asRight();
              final alarms = schedule?.alarms ?? [];
              final icons = [
                AssetConst.imsakIcon,
                AssetConst.subuhIcon,
                AssetConst.syuruqIcon,
                AssetConst.dhuhaIcon,
                AssetConst.dhuhurIcon,
                AssetConst.asharIcon,
                AssetConst.maghribIcon,
                AssetConst.isyaIcon,
              ];
              final time = () {
                final params = CalculationMethod.values
                    .firstWhere(
                      (e) => e.name == schedule?.calculationMethod.name,
                      orElse: () => CalculationMethod.umm_al_qura,
                    )
                    .getParameters();
                params.madhab = schedule?.madhab ?? Madhab.shafi;
                final coordinate = Coordinates(
                  state.geoLocation?.coordinate?.lat ?? 0,
                  state.geoLocation?.coordinate?.lon ?? 0,
                  validate: true,
                );
                final prayerTimes = PrayerTimes(
                  coordinate,
                  DateComponents.from(dateSelected),
                  params,
                );
                return prayerTimes;
              }();

              final prayersByLocale = HelperTimeShalat.prayerNameByLocale(
                context.locale,
              );
              final scheduleTime = Schedule.fromPrayerTimes(time);
              return SafeArea(
                top: false,
                bottom: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: prayersByLocale.asMap().entries.map((entry) {
                        final index = entry.key;
                        final prayer = entry.value;

                        final timePrayerText = () {
                          String? text;
                          if (prayer == prayersByLocale[0]) {
                            text = scheduleTime.imsak;
                          } else if (prayer == prayersByLocale[1]) {
                            text = scheduleTime.subuh;
                          } else if (prayer == prayersByLocale[2]) {
                            text = scheduleTime.syuruq;
                          } else if (prayer == prayersByLocale[3]) {
                            text = scheduleTime.dhuha;
                          } else if (prayer == prayersByLocale[4]) {
                            text = scheduleTime.dzuhur;
                          } else if (prayer == prayersByLocale[5]) {
                            text = scheduleTime.ashar;
                          } else if (prayer == prayersByLocale[6]) {
                            text = scheduleTime.maghrib;
                          } else if (prayer == prayersByLocale[7]) {
                            text = scheduleTime.isya;
                          } else {
                            text = scheduleTime.dzuhur;
                          }
                          return text ?? '';
                        }();
                        final parts = timePrayerText.isNotEmpty
                            ? timePrayerText
                                .split(' ')
                                .firstOrNull
                                ?.split(RegExp('[.:]'))
                            : null;
                        final hour = parts?.elementAtOrNull(0) ?? '';
                        final minute = parts?.elementAtOrNull(1) ?? '';

                        return ListTile(
                          leading: SvgPicture.asset(
                            icons[index],
                            colorFilter: ColorFilter.mode(
                              context.theme.colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                          title: Text(
                            prayer.capitalizeEveryWord(),
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            timePrayerText,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                          trailing: Builder(
                            builder: (context) {
                              final alarm = alarms.firstWhere(
                                (e) => e.prayer?.index == index,
                                orElse: () => PrayerAlarm(
                                  prayer: PrayerInApp.values.firstWhere(
                                    (e) => e.index == index,
                                    orElse: () => PrayerInApp.dzuhur,
                                  ),
                                  alarmType: 3,
                                ),
                              );
                              return IconButton(
                                icon: Icon(
                                  () {
                                    return alarm.alarmType != 3
                                        ? Icons.notifications_active
                                        : Icons.notifications_off;
                                  }(),
                                  color: () {
                                    return alarm.alarmType != 3
                                        ? context.theme.colorScheme.primary
                                        : context.theme.colorScheme.onSurface;
                                  }(),
                                ),
                                onPressed: () {
                                  _openBottomSheet(
                                      context,
                                      prayer.capitalizeEveryWord(),
                                      timePrayerText,
                                      alarm, (Map data) {
                                    final reminderTime =
                                        data['reminderTime'] ?? 0;
                                    context.read<ShalatBloc>().add(
                                          ShalatEvent
                                              .setPrayerScheduleSettingEvent(
                                            model: schedule?.copyWith(
                                              alarms: alarms.map((e) {
                                                if (e.prayer?.index == index) {
                                                  return e.copyWith(
                                                    time:
                                                        DateTime.now().copyWith(
                                                      hour:
                                                          int.tryParse(hour) ??
                                                              0,
                                                      minute: int.tryParse(
                                                              minute) ??
                                                          0,
                                                    ),
                                                    alarmType: data[
                                                        'notificationType'],
                                                    reminderTime: reminderTime,
                                                    reminderEnabled: data[
                                                            'reminderEnabled'] ??
                                                        false,
                                                  );
                                                }
                                                return e;
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                  });
                                },
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openBottomSheet(
    BuildContext context,
    String playerName,
    String time,
    PrayerAlarm? prayerAlarm,
    Function(Map) onSave,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SholatNotificationBottomSheet(
          playerName: playerName,
          time: time,
          onSave: onSave,
          prayerAlarm: prayerAlarm,
        );
      },
    );
  }
}

class _DatePickerSection extends StatelessWidget {
  final DateTime dateNow;
  final Function(DateTime date) onDateChanged;
  const _DatePickerSection({
    required this.dateNow,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriDate.dateToHijri(dateNow);
    final hijriDateString =
        '${hijriDate.day} ${englishHMonth(hijriDate.month)} ${hijriDate.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                onDateChanged(
                  dateNow.subtract(const Duration(days: 1)),
                );
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
          Expanded(
            flex: 8,
            child: GestureDetector(
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: dateNow,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                ).then((value) {
                  if (value != null) {
                    onDateChanged(value);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    textAlign: TextAlign.center,
                    DateFormat('EEEE, dd MMMM yyyy').format(dateNow),
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    textAlign: TextAlign.center,
                    hijriDateString,
                    style: context.textTheme.titleSmall?.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () {
                onDateChanged(
                  dateNow.add(const Duration(days: 1)),
                );
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
      ),
    );
  }
}
