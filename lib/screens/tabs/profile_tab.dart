// lib/screens/tabs/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
// (Pastikan nama 'astroview_app' sesuai dengan nama proyek Anda)
import '/models/favorite_image.dart';
import '/screens/image_detail_screen.dart';

class ProfileTab extends StatelessWidget {
  final String username;
  const ProfileTab({super.key, required this.username});

  void _logout(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _showSaranKesan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saran dan Kesan Mata Kuliah'),
        content: const Text(
          'Aplikasi AstroView ini dibuat untuk memenuhi Tugas Akhir Pemrograman Aplikasi Mobile. Aplikasi ini mengintegrasikan API (NASA), LBS (Google Maps), Database (Hive), Notifikasi, dan Konverter Waktu/Mata Ulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(username),
          accountEmail: Text("$username@astroview.com"),
          currentAccountPicture: const CircleAvatar(
            child: Icon(Icons.person, size: 50),
          ),
          decoration: const BoxDecoration(color: Colors.indigo),
        ),
        ListTile(
          leading: const Icon(Icons.edit_note),
          title: const Text('Saran dan Kesan Mata Kuliah'),
          onTap: () => _showSaranKesan(context),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Gambar Favorit (dari Database Hive)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // --- MENAMPILKAN DATA DARI HIVE (Syarat #3) ---
        ValueListenableBuilder(
          // 'Dengarkan' perubahan di 'kotak' favorit
          valueListenable: Hive.box<FavoriteImage>('favorites').listenable(),
          builder: (context, Box<FavoriteImage> box, _) {
            // Ambil semua data dari kotak
            final favorites = box.values.toList().cast<FavoriteImage>();

            if (favorites.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Anda belum menyimpan gambar favorit.'),
                ),
              );
            }
            // Tampilkan data dalam ListView
            return ListView.builder(
              shrinkWrap: true, // Penting di dalam ListView lain
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];
                return ListTile(
                  leading: Image.network(
                    fav.url,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(fav.title),
                  subtitle: Text(fav.date),
                  onTap: () {
                    // Buka lagi halaman detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailScreen(
                          title: fav.title,
                          url: fav.url,
                          explanation: fav.explanation,
                          date: fav.date,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
