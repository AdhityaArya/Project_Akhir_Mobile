// lib/screens/image_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// (Pastikan nama 'astroview_app' sesuai dengan nama proyek Anda)
import '/models/favorite_image.dart';

class ImageDetailScreen extends StatelessWidget {
  final String title;
  final String url;
  final String explanation;
  final String date;

  const ImageDetailScreen({
    super.key,
    required this.title,
    required this.url,
    required this.explanation,
    required this.date,
  });

  // --- FUNGSI UNTUK MENYIMPAN KE DATABASE (Syarat #3) ---
  void _saveToFavorites(BuildContext context) {
    // Buka 'kotak' database
    final box = Hive.box<FavoriteImage>('favorites');

    // Kita gunakan 'date' sebagai key (ID) unik
    // Ini untuk mencegah data duplikat
    if (box.containsKey(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar ini sudah ada di favorit.')),
      );
      return;
    }

    // Buat objek data baru
    final newFavorite = FavoriteImage(
      title: title,
      url: url,
      explanation: explanation,
      date: date,
    );

    // Simpan ke database menggunakan 'date' sebagai key
    box.put(date, newFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil disimpan ke favorit!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // --- TOMBOL FAVORIT (Syarat #7 - Pemilihan) ---
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Simpan ke Favorit',
            onPressed: () => _saveToFavorites(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            Text(date, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Text(explanation, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
