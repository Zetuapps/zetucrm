import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
    );
  }

  static Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'zetucrm_tasks_channel',
      'Task Reminders',
      channelDescription: 'Notifications for upcoming CRM tasks and reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}
