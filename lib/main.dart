import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import '/screens/login_screen.dart';
import '/screens/load_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AstroViewApp());
}

class AstroViewApp extends StatelessWidget {
  const AstroViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astroview',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        secondaryHeaderColor: Colors.indigoAccent,
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
