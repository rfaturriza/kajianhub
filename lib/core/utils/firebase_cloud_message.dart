import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/core/utils/local_notification.dart';

import '../../injection.dart';

Future<void> initializeFCM() async {
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (Platform.isIOS && apnsToken == null) {
    debugPrint('APNS Token is null');
    return;
  }
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await FirebaseMessaging.instance.requestPermission(provisional: true);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print('FCM Token: $fcmToken');
    print('APNS Token: $apnsToken');
  }
  await FirebaseMessaging.instance.subscribeToTopic("daily-general");
  await FirebaseMessaging.instance.subscribeToTopic("fasting-reminder");
  configureFCMListeners();
}

void configureFCMListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle incoming data message when the app is in the foreground
    if (kDebugMode) {
      print(
        "Data message received: ${message.notification?.title} ${message.notification?.body}",
      );
    }
    sl<LocalNotification>().show(
      title: message.notification?.title ?? emptyString,
      body: message.notification?.body ?? emptyString,
      payload: message.data.toString(),
    );
  });
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
}

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling background message: ${message.data}");
  }
  sl<LocalNotification>().show(
    title: message.notification?.title ?? emptyString,
    body: message.notification?.body ?? emptyString,
    payload: message.data.toString(),
  );
}
