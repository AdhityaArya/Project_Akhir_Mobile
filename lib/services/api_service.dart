// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// (Pastikan nama 'astroview_app' sesuai dengan nama proyek Anda)
import '/models/apod_image.dart';
import '/models/nasa_image.dart';

class ApiService {
  // ⚠️ GANTI 'DEMO_KEY' DENGAN API KEY ANDA
  final String _apiKey = '2lt3cHutoK27UDftvQSnhp4zcoweu3K1orKaehmX';
  final String _apodUrl = 'https://api.nasa.gov/planetary/apod';
  final String _searchUrl = 'https://images-api.nasa.gov/search';

  // --- FUNGSI 1: MENGAMBIL APOD (Syarat #4) ---
  Future<ApodImage> getApod() async {
    final url = '$_apodUrl?api_key=$_apiKey';
    print('Memanggil API: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return ApodImage.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal memuat APOD. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server NASA.');
    }
  }

  // --- FUNGSI 2: MENCARI GAMBAR (Syarat #7) ---
  Future<List<NasaImage>> searchImages(String query) async {
    final url = '$_searchUrl?q=$query&media_type=image';
    print('Memanggil API Pencarian: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['collection']['items'];

        List<NasaImage> images = [];
        for (var item in items) {
          // Kita cek data JSON agar tidak error
          if (item['links'] != null &&
              item['links'][0]['href'] != null &&
              item['data'] != null &&
              item['data'][0]['title'] != null) {
            images.add(
              NasaImage(
                title: item['data'][0]['title'],
                description:
                    item['data'][0]['description'] ?? 'Tidak ada deskripsi.',
                imageUrl: item['links'][0]['href'],
                date: item['data'][0]['date_created'] ?? 'N/A',
              ),
            );
          }
        }
        return images;
      } else {
        throw Exception('Gagal mencari gambar. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server pencarian.');
    }
  }
}
