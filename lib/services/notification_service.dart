// lib/services/notification_service.dart
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

  // --- FUNGSI DIPERBARUI UNTUK MELAKUKAN 2 HAL ---
  Future<void> scheduleEventNotification({
    required int id, // ID unik (dari hashcode)
    required String eventName, // Nama asteroid
    required DateTime eventTimeUtc, // Waktu event dari API
  }) async {
    // Siapkan detail notifikasi
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'event_channel_id', // ID channel
      'Notifikasi Event Astronomi', // Nama channel
      channelDescription: 'Notifikasi untuk event astronomi mendatang',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Format jam untuk body notifikasi
    final formatJam = DateFormat('HH:mm');
    final localEventTime = tz.TZDateTime.from(eventTimeUtc, tz.local);
    final String bodyTeks =
        "Dalam 1 jam lagi! (${formatJam.format(localEventTime)}) benda angkasa ini akan melewati Bumi.";
    final String titleTeks = "Event Terdekat: $eventName";

    // --- 1. TAMPILKAN NOTIFIKASI LANGSUNG (SESUAI VIDEO) ---
    // (Gunakan ID yang sedikit berbeda agar tidak bentrok)
    await flutterLocalNotificationsPlugin.show(
      id + 1, // ID unik (ID asli + 1)
      "PENGINGAT DIATUR!", // Judul notifikasi langsung
      "Pengingat untuk '$eventName' telah diatur 1 jam sebelum '$eventName' melewati bumi", // Body
      notificationDetails, // Detail
    );
    // --- AKHIR NOTIFIKASI LANGSUNG ---

    // --- 2. JADWALKAN NOTIFIKASI 1 JAM SEBELUMNYA (TETAP ADA) ---
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
      id, // ID asli
      titleTeks, // Title (sesuai permintaan Anda)
      bodyTeks, // Body (sesuai permintaan Anda)
      scheduledDate, // Waktu (1 jam sebelum event)
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    // --- AKHIR NOTIFIKASI TERJADWAL ---

    print(
        "Notifikasi langsung ditampilkan DAN notifikasi 1 jam sebelumnya diatur untuk $eventName.");
  }
}
