import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/utils/pair.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

@Singleton()
class LocalNotification {
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static const _defaultIcon = 'ic_notification';

  Future<void> init() async {
    // Get device timezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse,
    ) async {
      final String? payload = notificationResponse.payload;
      if (notificationResponse.payload != null) {
        log('notification payload: $payload');
      }
    }

    const initSettingsAndroid = AndroidInitializationSettings(
      _defaultIcon,
    );
    final initSettingsDarwin = DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsDarwin,
      macOS: initSettingsDarwin,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
    Pair<String, String>? channel,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel?.first ?? 'high_importance_channel',
      channel?.second ?? 'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: _defaultIcon,
      showWhen: false,
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      payload: payload,
      platformChannelSpecifics,
    );
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    Pair<String, String>? channel,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel?.first ?? 'reminder_channel',
      channel?.second ?? 'Reminder Channel',
      icon: _defaultIcon,
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final tzDateTime = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      platformChannelSpecifics,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay timeOfDay,
    String? payload,
    Pair<String, String>? channel,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel?.first ?? 'periodic_channel',
      channel?.second ?? 'Periodic Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: _defaultIcon,
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    final firstSchedule = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      firstSchedule,
      platformChannelSpecifics,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
