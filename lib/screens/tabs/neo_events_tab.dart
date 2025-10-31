import 'package:astroview/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/neo_event.dart';
import '/services/api_service.dart';

class NeoEventsTab extends StatefulWidget {
  const NeoEventsTab({super.key});

  @override
  State<NeoEventsTab> createState() => _NeoEventsTabState();
}

class _NeoEventsTabState extends State<NeoEventsTab> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  late Future<List<NeoEvent>> _futureNeoEvents;

  final Set<int> _activeNotificationIds = {};

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
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

  void _cancelNotification(int id, String eventName) {
    _notificationService.cancelNotification(id: id);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pengingat untuk $eventName dibatalkan'),
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 2),
    ));
  }

  void _toggleNotification(NeoEvent event) {
    final int notificationId = event.name.hashCode & 0x7FFFFFFF;
    setState(() {
      if (_activeNotificationIds.contains(notificationId)) {
        _activeNotificationIds.remove(notificationId);
        _cancelNotification(notificationId, event.name);
      } else {
        _activeNotificationIds.add(notificationId);
        _scheduleNotification(event);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NeoEvent>>(
      future: _futureNeoEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Gagal memuat data asteroid.\nError: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              final diameterFormat = NumberFormat("#,##0.##");
              final diameterText =
                  "${diameterFormat.format(event.estimatedDiameterMinMeters)} - ${diameterFormat.format(event.estimatedDiameterMaxMeters)} meter";

              final int notificationId = event.name.hashCode & 0x7FFFFFFF;
              final bool isNotificationActive =
                  _activeNotificationIds.contains(notificationId);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              event.isPotentiallyHazardous
                                  ? Tooltip(
                                      message: "Berpotensi Berbahaya",
                                      child: Text("Berpotensi Berbahaya",
                                          style: TextStyle(
                                              color: Colors.red[400],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    )
                                  : Tooltip(
                                      message: "Tidak Berpotensi Berbahaya",
                                      child: Text('Tidak Berpotensi Berbahaya',
                                          style: TextStyle(
                                              color: Colors.green[400],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ),
                              const SizedBox(height: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isNotificationActive
                                      ? Icons.notification_add
                                      : Icons.notification_add_outlined,
                                ),
                                color: isNotificationActive
                                    ? Colors.amber
                                    : Colors.indigoAccent,
                                tooltip: isNotificationActive
                                    ? 'Batalkan pengingat'
                                    : 'Atur pengingat 1 jam sebelum event',
                                onPressed: () {
                                  _toggleNotification(event);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Perkiraan Diameter: $diameterText',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const Divider(height: 20, color: Colors.grey),
                      _TimezoneDisplay(
                          eventTimeUtc: event.closeApproachTimeUtc),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
              child: Text(
            'Tidak ada asteroid mendekat terdeteksi minggu ini.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ));
        }
      },
    );
  }
}

class _TimezoneDisplay extends StatefulWidget {
  final DateTime eventTimeUtc;

  const _TimezoneDisplay({required this.eventTimeUtc});

  @override
  State<_TimezoneDisplay> createState() => _TimezoneDisplayState();
}

class _TimezoneDisplayState extends State<_TimezoneDisplay> {
  final Map<String, Duration> _timezones = {
    'London (UTC)': Duration.zero,
    'WIB (UTC+7)': const Duration(hours: 7),
    'WITA (UTC+8)': const Duration(hours: 8),
    'WIT (UTC+9)': const Duration(hours: 9),
  };

  late String _selectedTimezoneKey;

  @override
  void initState() {
    super.initState();
    _selectedTimezoneKey = _timezones.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final formatTanggal = DateFormat('EEE, d MMM yyyy', 'id_ID');
    final formatJam = DateFormat('HH:mm');

    final selectedOffset = _timezones[_selectedTimezoneKey]!;
    final selectedTime = widget.eventTimeUtc.add(selectedOffset);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Waktu Pendekatan Terdekat (${formatTanggal.format(widget.eventTimeUtc)})',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<String>(
              value: _selectedTimezoneKey,
              isDense: true,
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimezoneKey = newValue;
                  });
                }
              },
              items: _timezones.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
            ),
            const Spacer(),
            Text(
              formatJam.format(selectedTime),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
