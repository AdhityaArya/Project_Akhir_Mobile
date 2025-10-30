// lib/screens/tabs/locations_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class LocationsTab extends StatefulWidget {
  const LocationsTab({super.key});

  @override
  State<LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<LocationsTab> {
  final List<Map<String, dynamic>> _observatoryData = [
    {
      "name": "Observatorium Bosscha",
      "description":
          "Observatorium astronomi tertua di Indonesia, dikelola oleh ITB.",
      "latitude": -6.8249,
      "longitude": 107.6186,
      "event_time_utc": "2026-09-07T19:00:00Z",
      "ticket_price_usd": 3.0
    },
    {
      "name": "Planetarium Jakarta",
      "description":
          "Planetarium dan observatorium publik di Taman Ismail Marzuki, Jakarta.",
      "latitude": -6.1920,
      "longitude": 106.8400,
      "event_time_utc": "2026-10-20T14:00:00Z",
      "ticket_price_usd": 1.0
    },
    {
      "name": "Observatorium Nasional TIMAU",
      "description":
          "Observatorium nasional baru Indonesia yang terletak di Kupang, NTT.",
      "latitude": -9.9984,
      "longitude": 123.7712,
      "event_time_utc": "2026-11-15T18:00:00Z",
      "ticket_price_usd": 5.0
    },
    {
      "name": "Observatorium Mauna Kea (Hawaii)",
      "description":
          "Kumpulan teleskop besar di puncak gunung Mauna Kea, Hawaii, USA.",
      "latitude": 19.8206,
      "longitude": -155.4681,
      "event_time_utc": "2026-11-05T08:00:00Z",
      "ticket_price_usd": 0.0
    },
    {
      "name": "Very Large Telescope (VLT)",
      "description":
          "Observatorium ESO di Gurun Atacama, Chile, salah satu yang tercanggih.",
      "latitude": -24.6272,
      "longitude": -70.4042,
      "event_time_utc": "2027-01-10T02:00:00Z",
      "ticket_price_usd": 0.0
    },
    {
      "name": "Observatorium Griffith (Los Angeles)",
      "description":
          "Observatorium publik ikonik dengan pemandangan kota Los Angeles, USA.",
      "latitude": 34.1184,
      "longitude": -118.3004,
      "event_time_utc": "2027-02-14T04:00:00Z",
      "ticket_price_usd": 10.0
    }
  ];

  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  Map<String, dynamic>? _selectedObservatory;
  LatLng? _currentLocationMarker;

  @override
  void initState() {
    super.initState();
    _processObservatoryData();
  }

  void _processObservatoryData() {
    try {
      List<Marker> newMarkers = [];
      for (var observatory in _observatoryData) {
        final double lat = (observatory['latitude'] as num?)?.toDouble() ?? 0.0;
        final double lng =
            (observatory['longitude'] as num?)?.toDouble() ?? 0.0;
        final LatLng point = LatLng(lat, lng);
        newMarkers.add(
          Marker(
            point: point,
            width: 80.0,
            height: 80.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedObservatory = observatory;
                  _mapController.move(point, 13.0);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ),
          ),
        );
      }
      setState(() {
        _markers = newMarkers;
        if (_observatoryData.isNotEmpty) {
          _selectedObservatory = _observatoryData[0];
        }
      });
    } catch (e) {
      print("Error processing data: $e");
    }
  }

  Future<void> _getCurrentLocationAndMoveMap() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final currentLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(currentLatLng, 15.0);
      setState(() {
        _currentLocationMarker = currentLatLng;
      });
    } catch (e) {
      print("Location error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> allMarkers = List.from(_markers);
    if (_currentLocationMarker != null) {
      allMarkers.add(Marker(
        point: _currentLocationMarker!,
        width: 80.0,
        height: 80.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
        ),
      ));
    }

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                    initialCenter: const LatLng(-2.5489, 118.0149),
                    initialZoom: 4.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, __) {
                      setState(() {
                        _selectedObservatory = null;
                      });
                    }),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.astroview',
                  ),
                  MarkerLayer(markers: allMarkers),
                ],
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: Column(
                  children: [
                    _buildMapButton(
                      icon: Icons.add,
                      heroTag: 'zoom_in',
                      onPressed: () {
                        double z = _mapController.camera.zoom;
                        _mapController.move(_mapController.camera.center,
                            (z + 1.0).clamp(3.0, 18.0));
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMapButton(
                      icon: Icons.remove,
                      heroTag: 'zoom_out',
                      onPressed: () {
                        double z = _mapController.camera.zoom;
                        _mapController.move(_mapController.camera.center,
                            (z - 1.0).clamp(3.0, 18.0));
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMapButton(
                      icon: Icons.my_location,
                      heroTag: 'my_location',
                      onPressed: _getCurrentLocationAndMoveMap,
                      isLarge: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedObservatory == null
                ? Container(
                    key: const ValueKey('no_selection'),
                    color: Colors.grey[850],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app,
                              size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text('Tap marker di peta untuk melihat detail',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  )
                : _buildObservatoryDetailCard(_selectedObservatory!),
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String heroTag,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
        child: Container(
          width: isLarge ? 56 : 40,
          height: isLarge ? 56 : 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
          ),
          child: Icon(icon, color: Colors.blue[700], size: isLarge ? 28 : 20),
        ),
      ),
    );
  }

  Widget _buildObservatoryDetailCard(Map<String, dynamic> observatory) {
    String name = observatory['name'] ?? 'Nama Tidak Diketahui';
    String description = observatory['description'] ?? 'Tidak ada deskripsi.';
    DateTime eventTimeUtc =
        DateTime.tryParse(observatory['event_time_utc'] ?? '')?.toUtc() ??
            DateTime.now().toUtc();
    double ticketPriceUsd =
        (observatory['ticket_price_usd'] as num?)?.toDouble() ?? 0.0;

    return Container(
      key: ValueKey(name),
      width: double.infinity,
      color: Colors.grey[850],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_city,
                          color: Colors.blue[400], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(name,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[300])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(description,
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey[300], height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _buildCurrencyConverter(context, ticketPriceUsd),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyConverter(BuildContext context, double priceUsd) {
    const idrRate = 16500.0;
    const eurRate = 0.92;
    const jpyRate = 155.0;
    final formatIDR =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final formatUSD = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final formatEUR = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    final formatJPY =
        NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green[400], size: 20),
              const SizedBox(width: 8),
              Text(
                'Estimasi Biaya Tiket',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[300]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('(Harga perkiraan)',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const Divider(height: 24, color: Colors.grey),
          _buildCurrencyRow('🇺🇸', 'USD', formatUSD.format(priceUsd)),
          _buildCurrencyRow(
              '🇮🇩', 'IDR', formatIDR.format(priceUsd * idrRate)),
          _buildCurrencyRow(
              '🇪🇺', 'EUR', formatEUR.format(priceUsd * eurRate)),
          _buildCurrencyRow(
              '🇯🇵', 'JPY', formatJPY.format(priceUsd * jpyRate)),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String flag, String currency, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(currency,
                style: TextStyle(fontSize: 15, color: Colors.grey[300])),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(amount,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
