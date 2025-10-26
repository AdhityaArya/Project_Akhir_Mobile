import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/screens/tabs/apod_tab.dart';
import '/screens/tabs/search_tab.dart';
import '/screens/tabs/location_tab.dart';
import '/screens/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<String> _widgetTitles = <String>[
    'Astronomy Picture of the Day',
    'Search NASA Library',
    'Observatory Locations',
    'Profile',
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
    final Object? arguments = ModalRoute.of(context)!.settings.arguments;
    String username;
    if (arguments != null && arguments is String) {
      username = arguments;
    } else {
      username = "Guest";
    }

    // Daftar 4 halaman tab kita
    final List<Widget> _widgetOptions = <Widget>[
      const ApodTab(),
      const SearchTab(),
      const LocationsTab(),
      ProfileTab(username: username),
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
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'APOD'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
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
