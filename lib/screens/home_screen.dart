import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? username =
        ModalRoute.of(context)!.settings.arguments as String?;

    final List<String> contentList = [];
    Widget bodyContent;
    if (contentList.isEmpty) {
      bodyContent = const Center(
        child: Text(
          'Konten tidak tersedia',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    } else {
      bodyContent = ListView.builder(
        itemCount: contentList.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(contentList[index]));
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
