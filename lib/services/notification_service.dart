import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi dasar (tetap sama)
  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> cancelNotification({required int id}) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  Future<void> scheduleEventNotification({
    required int id,
    required String eventName,
    required DateTime eventTimeUtc,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'event_channel_id',
      'Notifikasi Event Astronomi',
      channelDescription: 'Notifikasi untuk event astronomi mendatang',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final formatJam = DateFormat('HH:mm');
    final localEventTime = tz.TZDateTime.from(eventTimeUtc, tz.local);
    final String bodyTeks =
        "Dalam 1 jam lagi! (${formatJam.format(localEventTime)}) benda angkasa ini akan melewati Bumi.";
    final String titleTeks = "Event Terdekat: $eventName";

    await flutterLocalNotificationsPlugin.show(
      id + 1,
      "PENGINGAT DIATUR!",
      "Pengingat untuk '$eventName' telah diatur 1 jam sebelum '$eventName' melewati bumi",
      notificationDetails,
    );

    final DateTime notificationTimeUtc =
        eventTimeUtc.subtract(const Duration(hours: 1));
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(notificationTimeUtc, tz.local);

    if (scheduledDate.isBefore(DateTime.now())) {
      print(
          "Waktu notifikasi untuk $eventName sudah lewat, tidak dijadwalkan.");
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      titleTeks,
      bodyTeks,
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print(
        "Notifikasi langsung ditampilkan DAN notifikasi 1 jam sebelumnya diatur untuk $eventName.");
  }
}
