import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/models/favorite_image.dart';
import '/screens/image_detail_screen.dart';

class ProfileTab extends StatelessWidget {
  final String username;
  const ProfileTab({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(username),
          accountEmail: Text("$username@astroview.com"),
          currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('/assets/bintang.jpg')),
          decoration: const BoxDecoration(color: Colors.indigo),
        ),
        ListTile(
          leading: const Icon(Icons.edit_note),
          title: const Text('Saran dan Kesan Mata Kuliah'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/saran_kesan');
          },
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
