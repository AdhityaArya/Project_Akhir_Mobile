import 'dart:convert'; // Untuk jsonDecode
import 'package:http/http.dart' as http; // Untuk panggilan API
import 'package:intl/intl.dart'; // Untuk format tanggal (DateFormat)

// Impor semua model data kita
// (Pastikan nama 'astroview_app' sesuai dengan nama proyek Anda)
import '/models/apod_image.dart';
import '/models/nasa_image.dart';
import '/models/neo_event.dart';

class ApiService {
  // ⚠️ GANTI 'MASUKKAN_API_KEY_ANDA_DI_SINI' DENGAN API KEY NASA ANDA
  // Anda bisa mendapatkannya gratis di https://api.nasa.gov/
  final String _apiKey = '2lt3cHutoK27UDftvQSnhp4zcoweu3K1orKaehmX';

  // URL dasar untuk setiap layanan API NASA
  final String _apodUrl = 'https://api.nasa.gov/planetary/apod';
  final String _searchUrl = 'https://images-api.nasa.gov/search';
  final String _neoUrl = 'https://api.nasa.gov/neo/rest/v1/feed';

  // --- FUNGSI 1: MENGAMBIL APOD (Gambar Hari Ini) ---
  // Memenuhi Syarat TA #4 (Web Service / API)
  Future<ApodImage> getApod() async {
    final url = '$_apodUrl?api_key=$_apiKey';
    print('Memanggil API APOD: $url'); // Log untuk debugging

    try {
      final response = await http.get(Uri.parse(url)); // Lakukan panggilan GET

      // Cek apakah panggilan berhasil (status code 200 OK)
      if (response.statusCode == 200) {
        // Jika berhasil, ubah JSON response menjadi objek ApodImage
        return ApodImage.fromJson(json.decode(response.body));
      } else {
        // Jika gagal, lempar error beserta status code
        throw Exception('Gagal memuat APOD. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Tangkap error jaringan (misal: tidak ada internet)
      print('Error getApod: $e');
      throw Exception('Gagal terhubung ke server APOD NASA.');
    }
  }

  // --- FUNGSI 2: MENCARI GAMBAR DI NASA ---
  // Memenuhi Syarat TA #7 (Fasilitas Pencarian)
  Future<List<NasaImage>> searchImages(String query) async {
    // Buat URL pencarian dengan query pengguna dan filter hanya gambar
    final url = '$_searchUrl?q=$query&media_type=image';
    print('Memanggil API Pencarian Gambar: $url'); // Log untuk debugging

    try {
      final response = await http.get(Uri.parse(url)); // Lakukan panggilan GET

      if (response.statusCode == 200) {
        // Decode JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        // Ambil daftar 'items' dari dalam JSON ('collection' -> 'items')
        // Gunakan '?? []' sebagai fallback jika 'items' tidak ada
        final List<dynamic> items = data['collection']?['items'] ?? [];

        List<NasaImage> images = []; // List kosong untuk menampung hasil
        // Loop melalui setiap 'item' dalam daftar
        for (var item in items) {
          // Lakukan pengecekan keamanan (null check) sebelum mengakses data
          if (item['links'] != null && item['links'].isNotEmpty && item['links'][0]['href'] != null &&
              item['data'] != null && item['data'].isNotEmpty && item['data'][0]['title'] != null) {
            // Jika data aman, buat objek NasaImage dan tambahkan ke list
            images.add(NasaImage(
              title: item['data'][0]['title'],
              description: item['data'][0]['description'] ?? 'Tidak ada deskripsi.',
              imageUrl: item['links'][0]['href'], // URL gambar thumbnail
              // Ambil tanggal pembuatan jika ada, jika tidak 'N/A'
              date: item['data'][0]['date_created'] ?? 'N/A',
            ));
          }
        }
        return images; // Kembalikan list hasil pencarian
      } else {
        // Jika gagal, lempar error
        throw Exception('Gagal mencari gambar. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Tangkap error jaringan
      print('Error searchImages: $e');
      throw Exception('Gagal terhubung ke server pencarian NASA.');
    }
  }

  // --- FUNGSI 3: MENGAMBIL ASTEROID MENDEKAT (NEO) ---
  // Memenuhi Syarat TA #4 (API) & #6 (Data Waktu Konverter)
  Future<List<NeoEvent>> getUpcomingNeos() async {
    // Tentukan tanggal mulai (hari ini) dan tanggal akhir (7 hari dari sekarang)
    final today = DateTime.now();
    final endDate = today.add(const Duration(days: 7));
    // Format tanggal menjadi 'YYYY-MM-DD' sesuai permintaan API
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateStr = formatter.format(today);
    final endDateStr = formatter.format(endDate);

    // Buat URL API NEO dengan rentang tanggal dan API key
    final url = '$_neoUrl?start_date=$startDateStr&end_date=$endDateStr&api_key=$_apiKey';
    print('Memanggil API NEO: $url'); // Log untuk debugging

    try {
      final response = await http.get(Uri.parse(url)); // Lakukan panggilan GET

      if (response.statusCode == 200) {
        // Decode JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        // Data NEO dikelompokkan berdasarkan tanggal ('near_earth_objects')
        final Map<String, dynamic> neoDataByDate = data['near_earth_objects'] ?? {};
        List<NeoEvent> events = []; // List kosong untuk hasil

        // Loop melalui setiap tanggal dalam data NEO
        neoDataByDate.forEach((date, neoList) {
          // Loop melalui setiap asteroid (neo) dalam tanggal tersebut
          for (var neo in neoList) {
            // Ambil data pendekatan terdekat ('close_approach_data')
            if (neo['close_approach_data'] != null && neo['close_approach_data'].isNotEmpty) {
              // Ambil data pendekatan pertama (biasanya yang terdekat)
              final approach = neo['close_approach_data'][0];
              // Ambil string waktu pendekatan penuh
              final String? timeString = approach['close_approach_date_full'];
              DateTime? approachTimeUtc; // Variabel untuk menyimpan waktu UTC

              // Coba parse string waktu menjadi objek DateTime UTC
              if (timeString != null) {
                 try {
                   // Format umum dari API: "YYYY-MMM-DD HH:MM" (cth: "2025-Oct-29 14:35")
                   final parsedDate = DateFormat('yyyy-MMM-d HH:mm', 'en_US').parseUtc(timeString);
                   approachTimeUtc = parsedDate;
                 } catch (e) {
                   // Tangkap error jika format tanggal/waktu berbeda dari ekspektasi
                   print("Gagal parse waktu NEO: $timeString, Error: $e");
                 }
              }

              // Jika waktu berhasil diparse
              if (approachTimeUtc != null) {
                // Ambil data ukuran (diameter) dari JSON
                double minDiameter = 0.0;
                double maxDiameter = 0.0;
                if (neo['estimated_diameter'] != null && neo['estimated_diameter']['meters'] != null) {
                  // Konversi dari 'num' ke 'double' dengan aman
                  minDiameter = (neo['estimated_diameter']['meters']['estimated_diameter_min'] as num?)?.toDouble() ?? 0.0;
                  maxDiameter = (neo['estimated_diameter']['meters']['estimated_diameter_max'] as num?)?.toDouble() ?? 0.0;
                }
                // Ambil status potensi bahaya dari JSON
                bool isHazardous = neo['is_potentially_hazardous_asteroid'] ?? false;

                // Buat objek NeoEvent dan tambahkan ke list hasil
                events.add(NeoEvent(
                  name: neo['name'] ?? 'Asteroid Tidak Dikenal',
                  closeApproachTimeUtc: approachTimeUtc, // Waktu UTC
                  // Ambil data jarak dan kecepatan (opsional, dengan fallback 0.0)
                  missDistanceKm: double.tryParse(approach['miss_distance']?['kilometers'] ?? '0.0') ?? 0.0,
                  relativeVelocityKps: double.tryParse(approach['relative_velocity']?['kilometers_per_second'] ?? '0.0') ?? 0.0,
                  // Masukkan data baru (ukuran dan bahaya)
                  estimatedDiameterMinMeters: minDiameter,
                  estimatedDiameterMaxMeters: maxDiameter,
                  isPotentiallyHazardous: isHazardous,
                ));
              }
            }
          }
        });
        // Urutkan daftar event berdasarkan waktu terdekat
        events.sort((a, b) => a.closeApproachTimeUtc.compareTo(b.closeApproachTimeUtc));
        return events; // Kembalikan list event yang sudah diurutkan

      } else {
        // Jika API mengembalikan error
        throw Exception('Gagal memuat data NEO. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Tangkap error jaringan atau parsing
      print("Error getUpcomingNeos: $e");
      throw Exception('Gagal terhubung atau memproses data server NEO.');
    }
  }
} // Akhir class ApiService