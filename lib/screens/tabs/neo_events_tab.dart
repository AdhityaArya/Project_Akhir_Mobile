// lib/screens/tabs/neo_events_tab.dart
import 'package:astroview/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Ganti 'astroview_app' dengan nama proyek Anda jika berbeda
import '/models/neo_event.dart';
import '/services/api_service.dart';

class NeoEventsTab extends StatefulWidget {
  const NeoEventsTab({super.key});

  @override
  State<NeoEventsTab> createState() => _NeoEventsTabState();
}

class _NeoEventsTabState extends State<NeoEventsTab> {
  // Instance ApiService untuk memanggil API
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  // Future untuk menampung hasil panggilan API
  late Future<List<NeoEvent>> _futureNeoEvents;

  @override
  void initState() {
    super.initState();
    // Panggil API NEO saat tab ini pertama kali dibuka
    _futureNeoEvents = _apiService.getUpcomingNeos();
  }

  void _scheduleNotification(NeoEvent event) {
    final int notificationId = event.name.hashCode & 0x7FFFFFFF;

    _notificationService.scheduleEventNotification(
      id: notificationId,
      eventName: event.name,
      eventTimeUtc: event.closeApproachTimeUtc,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pengingat untuk ${event.name} telah diatur'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan FutureBuilder untuk menampilkan data dari API secara asynchronous
    return FutureBuilder<List<NeoEvent>>(
      future: _futureNeoEvents, // Future yang dipantau
      builder: (context, snapshot) {
        // Tampilkan loading indicator saat data sedang diambil
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Tampilkan pesan error jika terjadi masalah saat mengambil data
        else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Gagal memuat data asteroid.\nError: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent), // Warna error
              ),
            ),
          );
        }
        // Jika data berhasil diambil dan tidak kosong
        else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final events = snapshot.data!;
          // Tampilkan data dalam bentuk ListView
          return ListView.builder(
            padding:
                const EdgeInsets.all(8.0), // Beri padding di sekeliling list
            itemCount: events.length, // Jumlah item dalam list
            itemBuilder: (context, index) {
              final event = events[index]; // Ambil data event untuk baris ini

              // Format perkiraan diameter agar mudah dibaca (0-2 desimal)
              final diameterFormat = NumberFormat("#,##0.##");
              final diameterText =
                  "${diameterFormat.format(event.estimatedDiameterMinMeters)} - ${diameterFormat.format(event.estimatedDiameterMaxMeters)} meter";

              // Buat Card untuk setiap event agar rapi
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 6.0), // Jarak antar card
                color: Colors.grey[850], // Warna latar card
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)), // Sudut membulat
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Padding di dalam card
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Ratakan teks ke kiri
                    children: [
                      // Baris 1: Nama Asteroid dan Ikon Bahaya
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Nama kiri, ikon kanan
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Ratakan atas
                        children: [
                          // Expanded agar nama tidak overflow jika panjang
                          Expanded(
                            child: Text(
                              event.name, // Tampilkan nama asteroid
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                              overflow: TextOverflow
                                  .ellipsis, // Tambah '...' jika terlalu panjang
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notification_add_outlined),
                            color: Colors.indigoAccent,
                            tooltip: 'Atur pengingat 1 jam sebelum event',
                            onPressed: () {
                              _scheduleNotification(event);
                            },
                          ),
                          // Tampilkan ikon peringatan HANYA jika berbahaya
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            // Gunakan ternary operator (if/else singkat)
                            child: event.isPotentiallyHazardous
                                // JIKA true -> Tampilkan ikon warning
                                ? Tooltip(
                                    message: "Berpotensi Berbahaya",
                                    child: Text("Berpotensi Berbahaya",
                                        style: TextStyle(
                                            color: Colors.red[400],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  )
                                // JIKA false -> Tampilkan ikon checklist (atau teks)
                                : Tooltip(
                                    message: "Tidak Berpotensi Berbahaya",
                                    child: Text('Tidak Bepontesi Berbahaya',
                                        style: TextStyle(
                                            color: Colors.green[400],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6), // Jarak vertikal

                      // Baris 2: Perkiraan Ukuran Asteroid
                      Text(
                        'Perkiraan Diameter: $diameterText',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const Divider(
                          height: 20, color: Colors.grey), // Garis pemisah

                      // Baris 3: Konverter Waktu Pendekatan
                      _buildNeoTimeConverter(
                          context, event.closeApproachTimeUtc),
                    ],
                  ),
                ),
              );
            },
          );
        }
        // Jika data berhasil diambil tapi kosong
        else {
          return const Center(
              child: Text(
            'Tidak ada asteroid mendekat terdeteksi minggu ini.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ));
        }
      },
    );
  }

  // Widget untuk Konverter Waktu NEO (Memenuhi Syarat TA #6)
  Widget _buildNeoTimeConverter(BuildContext context, DateTime eventTimeUtc) {
    // Format Tanggal (cth: Sel, 7 Sep 2026)
    final formatTanggal = DateFormat('EEE, d MMM yyyy', 'id_ID');
    // Format Jam (cth: 19:00)
    final formatJam = DateFormat('HH:mm');

    // Konversi waktu UTC dari API ke 4 zona waktu yang dibutuhkan
    final wibTime = eventTimeUtc.add(const Duration(hours: 7));
    final witaTime = eventTimeUtc.add(const Duration(hours: 8));
    final witTime = eventTimeUtc.add(const Duration(hours: 9));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // Tampilkan tanggal event
          'Waktu Pendekatan Terdekat (${formatTanggal.format(eventTimeUtc)})',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[400]),
        ),
        const SizedBox(height: 8), // Jarak
        // Tampilkan 4 baris waktu sesuai syarat TA
        Text('⚫ London (UTC): ${formatJam.format(eventTimeUtc)}',
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text('🔵 WIB (UTC+7): ${formatJam.format(wibTime)}',
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text('🟢 WITA (UTC+8): ${formatJam.format(witaTime)}',
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text('🟡 WIT (UTC+9): ${formatJam.format(witTime)}',
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }
}
