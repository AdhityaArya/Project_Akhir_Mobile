// lib/services/notification_service.dart
/*import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Ikon aplikasi

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Syarat Notifikasi: Notifikasi harian untuk APOD jam 9 pagi
  Future<void> scheduleDailyApodNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID notifikasi
      'AstroView: Gambar Hari Ini!',
      'Lihat gambar astronomi terbaru dari NASA hari ini.',
      _nextInstanceOfNineAM(), // Jadwalkan jam 9 pagi setiap hari
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'apod_daily_channel',
          'Notifikasi APOD Harian',
          channelDescription: 'Channel untuk notifikasi APOD harian',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Fungsi helper untuk mendapatkan jam 9 pagi berikutnya
  tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}*/
