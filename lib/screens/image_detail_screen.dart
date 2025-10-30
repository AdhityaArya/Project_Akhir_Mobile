// lib/screens/image_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive Flutter
// (Pastikan nama 'astroview_app' sesuai dengan nama proyek Anda)
import '/models/favorite_image.dart';

// 1. Ubah menjadi StatefulWidget
class ImageDetailScreen extends StatefulWidget {
  final String title;
  final String url;
  final String explanation;
  final String date; // Kita gunakan 'date' sebagai ID unik

  const ImageDetailScreen({
    super.key,
    required this.title,
    required this.url,
    required this.explanation,
    required this.date,
  });

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  // 2. Tambahkan variabel state untuk melacak status favorit
  bool _isFavorited = false;
  // Variabel untuk mengakses kotak Hive
  late Box<FavoriteImage> _favoritesBox;

  @override
  void initState() {
    super.initState();
    // 3. Buka kotak Hive saat halaman diinisialisasi
    _favoritesBox = Hive.box<FavoriteImage>('favorites');
    // 4. Cek apakah gambar ini sudah ada di favorit
    _checkIfFavorited();
  }

  // Fungsi untuk mengecek status favorit awal
  void _checkIfFavorited() {
    // Cek apakah 'key' (yaitu tanggal) ada di dalam kotak Hive
    setState(() {
      _isFavorited = _favoritesBox.containsKey(widget.date);
    });
  }

  // --- FUNGSI UNTUK MENGELOLA FAVORIT (Like/Unlike) ---
  void _toggleFavorite() {
    if (_isFavorited) {
      // JIKA SUDAH FAVORIT -> Hapus dari favorit
      _removeFromFavorites();
    } else {
      // JIKA BELUM FAVORIT -> Tambahkan ke favorit
      _saveToFavorites();
    }
    // Update status _isFavorited setelah aksi
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  // Fungsi untuk MENYIMPAN ke Database Hive
  void _saveToFavorites() {
    // Buat objek data baru
    final newFavorite = FavoriteImage(
      title: widget.title,
      url: widget.url,
      explanation: widget.explanation,
      date: widget.date,
    );
    // Simpan ke database menggunakan 'date' sebagai key
    _favoritesBox.put(widget.date, newFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ditambahkan ke favorit!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Fungsi untuk MENGHAPUS dari Database Hive
  void _removeFromFavorites() {
    // Hapus dari database menggunakan 'date' sebagai key
    _favoritesBox.delete(widget.date);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dihapus dari favorit.'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  // --- AKHIR FUNGSI FAVORIT ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // --- TOMBOL FAVORIT (Like/Unlike) ---
          IconButton(
            // 5. Ganti ikon berdasarkan state _isFavorited
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_outline,
              // Beri warna merah jika sudah favorit
              color: _isFavorited ? Colors.redAccent : null,
            ),
            tooltip: _isFavorited ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
            // 6. Panggil fungsi _toggleFavorite saat ditekan
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      // Body tetap sama
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(widget.date, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Text(
              widget.explanation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
