// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Ganti 'astroview' dengan nama proyek Anda
import 'package:astroview/screens/tabs/home_tab.dart';
import 'package:astroview/screens/tabs/neo_events_tab.dart';
import 'package:astroview/screens/tabs/location_tab.dart';
import 'package:astroview/screens/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _storage = const FlutterSecureStorage();
  String _username = "Guest";

  @override
  void initState() {
    super.initState();
    print('HomeScreen [DEBUG]: initState() dipanggil.');
    _loadUsername();
  }

  void _loadUsername() async {
    print('HomeScreen [DEBUG]: _loadUsername() mulai...');
    String? storedUsername = await _storage.read(key: 'username');

    if (storedUsername == null) {
      print(
          'HomeScreen [DEBUG]: _storage.read(key: "username") mengembalikan NULL.');
    } else {
      print('HomeScreen [DEBUG]: Berhasil membaca username: "$storedUsername"');
    }

    if (mounted) {
      setState(() {
        _username = storedUsername ?? "Guest";
      });
    }
  }

  void _logout(BuildContext context) async {
    print(
        'HomeScreen [DEBUG]: Logout dipanggil, menghapus token dan username...');
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'username');

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<String> _widgetTitles = [
    'Beranda',
    'Event',
    'Lokasi',
    'Profil'
  ];
  List<Widget>? _buildAppBarActions() {
    if (_selectedIndex == 3) {
      return [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _logout(context),
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const HomeTab(),
      const NeoEventsTab(),
      const LocationsTab(),
      ProfileTab(username: _username),
    ];

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            _widgetTitles[_selectedIndex],
            key: ValueKey<int>(_selectedIndex),
          ),
        ),
        actions: _buildAppBarActions(),
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: 'Event'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), label: 'Lokasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }
}
