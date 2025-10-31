import 'package:astroview/screens/saran_kesan_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import '/models/favorite_image.dart';
import '/screens/home_screen.dart';
import '/screens/load_screen.dart';
import '/screens/login_screen.dart';
import '/models/user_model.dart';
import '/screens/register_screen.dart';
import '/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteImageAdapter());
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<FavoriteImage>('favorites');

  await NotificationService().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/register': (context) => const RegisterScreen(),
        '/saran_kesan': (context) => const SaranKesanScreen(),
      },
    );
  }
}
