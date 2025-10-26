// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import '/models/favorite_image.dart';
import '/screens/home_screen.dart';
import '/screens/load_screen.dart';
import '/screens/login_screen.dart';
import '/services/notification_service.dart';

void main() async {
  // Pastikan semua binding Flutter siap
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi format tanggal Indonesia (untuk Konverter Waktu)
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Timezone (untuk Notifikasi)
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Set zona waktu lokal

  // Inisialisasi Hive (Database Lokal - Syarat #3)
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteImageAdapter()); // Daftarkan 'cetakan'
  await Hive.openBox<FavoriteImage>('favorites'); // Buka 'kotak' database

  // Inisialisasi Notifikasi Lokal (Syarat #7)
  // await NotificationService().initNotifications();
  // Jadwalkan notifikasi APOD harian
  //NotificationService().scheduleDailyApodNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroView',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
