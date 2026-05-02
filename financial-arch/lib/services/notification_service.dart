import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    'income_notifications',
    'Income Notifications',
    channelDescription: 'Notifications for income recording and reminders',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );

  static const DarwinNotificationDetails _iosNotificationDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  NotificationDetails get _notificationDetails => const NotificationDetails(
        android: _androidNotificationDetails,
        iOS: _iosNotificationDetails,
      );

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // handle notification tap if needed
      },
    );

    await _configureLocalTimeZone();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> scheduleIncomeNotification({
    required double amount,
    String? note,
  }) async {
    final title = 'Income recorded';
    final body = note != null && note.isNotEmpty
        ? 'You added ${amount.toStringAsFixed(2)} EGP. $note'
        : 'You added ${amount.toStringAsFixed(2)} EGP.';

    await _plugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      _notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }
}
