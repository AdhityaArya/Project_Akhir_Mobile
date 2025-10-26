// lib/screens/tabs/apod_tab.dart
import 'package:flutter/material.dart';
// (Pastikan nama 'astroview_app' sesuai dengan nama proyek Anda)
import '/models/apod_image.dart';
import '/services/api_service.dart';
import '/screens/image_detail_screen.dart';

class ApodTab extends StatefulWidget {
  const ApodTab({super.key});

  @override
  State<ApodTab> createState() => _ApodTabState();
}

class _ApodTabState extends State<ApodTab> {
  late Future<ApodImage> futureApod;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureApod = apiService.getApod();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApodImage>(
      future: futureApod,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final apod = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apod.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(apod.date, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 16),

                // --- Tambahkan GestureDetector (Tombol Klik) ---
                GestureDetector(
                  onTap: () {
                    // Navigasi ke Halaman Detail (Syarat #7 - Pemilihan)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailScreen(
                          title: apod.title,
                          url: apod.hdurl ?? apod.url, // Kirim URL HD
                          explanation: apod.explanation,
                          date: apod.date,
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    apod.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  apod.explanation,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('Tidak ada data.'));
      },
    );
  }
}
