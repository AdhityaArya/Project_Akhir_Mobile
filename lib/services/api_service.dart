import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '/models/apod_image.dart';
import '/models/nasa_image.dart';
import '/models/neo_event.dart';

class ApiService {
  final String _apiKey = '2lt3cHutoK27UDftvQSnhp4zcoweu3K1orKaehmX';
  final String _apodUrl = 'https://api.nasa.gov/planetary/apod';
  final String _searchUrl = 'https://images-api.nasa.gov/search';
  final String _neoUrl = 'https://api.nasa.gov/neo/rest/v1/feed';

  Future<ApodImage> getApod() async {
    final url = '$_apodUrl?api_key=$_apiKey';
    print('Memanggil API APOD: $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return ApodImage.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal memuat APOD. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getApod: $e');
      throw Exception('Gagal terhubung ke server APOD NASA.');
    }
  }

  Future<List<NasaImage>> searchImages(String query) async {
    final url = '$_searchUrl?q=$query&media_type=image';
    print('Memanggil API Pencarian Gambar: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['collection']?['items'] ?? [];

        List<NasaImage> images = [];
        for (var item in items) {
          if (item['links'] != null &&
              item['links'].isNotEmpty &&
              item['links'][0]['href'] != null &&
              item['data'] != null &&
              item['data'].isNotEmpty &&
              item['data'][0]['title'] != null) {
            images.add(NasaImage(
              title: item['data'][0]['title'],
              description:
                  item['data'][0]['description'] ?? 'Tidak ada deskripsi.',
              imageUrl: item['links'][0]['href'],
              date: item['data'][0]['date_created'] ?? 'N/A',
            ));
          }
        }
        return images;
      } else {
        throw Exception('Gagal mencari gambar. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searchImages: $e');
      throw Exception('Gagal terhubung ke server pencarian NASA.');
    }
  }

  Future<List<NeoEvent>> getUpcomingNeos() async {
    final today = DateTime.now();
    final endDate = today.add(const Duration(days: 7));
    final formatter = DateFormat('yyyy-MM-dd');
    final startDateStr = formatter.format(today);
    final endDateStr = formatter.format(endDate);

    final url =
        '$_neoUrl?start_date=$startDateStr&end_date=$endDateStr&api_key=$_apiKey';
    print('Memanggil API NEO: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> neoDataByDate =
            data['near_earth_objects'] ?? {};
        List<NeoEvent> events = [];

        neoDataByDate.forEach((date, neoList) {
          for (var neo in neoList) {
            if (neo['close_approach_data'] != null &&
                neo['close_approach_data'].isNotEmpty) {
              final approach = neo['close_approach_data'][0];
              final String? timeString = approach['close_approach_date_full'];
              DateTime? approachTimeUtc;

              if (timeString != null) {
                try {
                  final parsedDate = DateFormat('yyyy-MMM-d HH:mm', 'en_US')
                      .parseUtc(timeString);
                  approachTimeUtc = parsedDate;
                } catch (e) {
                  print("Gagal parse waktu NEO: $timeString, Error: $e");
                }
              }

              if (approachTimeUtc != null) {
                double minDiameter = 0.0;
                double maxDiameter = 0.0;
                if (neo['estimated_diameter'] != null &&
                    neo['estimated_diameter']['meters'] != null) {
                  minDiameter = (neo['estimated_diameter']['meters']
                              ['estimated_diameter_min'] as num?)
                          ?.toDouble() ??
                      0.0;
                  maxDiameter = (neo['estimated_diameter']['meters']
                              ['estimated_diameter_max'] as num?)
                          ?.toDouble() ??
                      0.0;
                }
                bool isHazardous =
                    neo['is_potentially_hazardous_asteroid'] ?? false;

                events.add(NeoEvent(
                  name: neo['name'] ?? 'Asteroid Tidak Dikenal',
                  closeApproachTimeUtc: approachTimeUtc,
                  missDistanceKm: double.tryParse(
                          approach['miss_distance']?['kilometers'] ?? '0.0') ??
                      0.0,
                  relativeVelocityKps: double.tryParse(
                          approach['relative_velocity']
                                  ?['kilometers_per_second'] ??
                              '0.0') ??
                      0.0,
                  estimatedDiameterMinMeters: minDiameter,
                  estimatedDiameterMaxMeters: maxDiameter,
                  isPotentiallyHazardous: isHazardous,
                ));
              }
            }
          }
        });
        events.sort(
            (a, b) => a.closeApproachTimeUtc.compareTo(b.closeApproachTimeUtc));
        return events;
      } else {
        throw Exception(
            'Gagal memuat data NEO. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error getUpcomingNeos: $e");
      throw Exception('Gagal terhubung atau memproses data server NEO.');
    }
  }
}
