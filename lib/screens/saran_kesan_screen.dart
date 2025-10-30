import 'package:flutter/material.dart';

class SaranKesanScreen extends StatelessWidget {
  const SaranKesanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Saran dan Kesan'),
          backgroundColor: Colors.indigo,
        ),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined,
                    size: 80, color: Colors.indigoAccent),
                SizedBox(height: 24),
                Text(
                  'Aplikasi AstroView ini dibuat untuk memenuhi Tugas Akhir Pemrograman Aplikasi Mobile. Aplikasi ini mengintegrasikan API (NASA), LBS (OpenStreetMap), Database (Hive), Notifikasi, Konverter Waktu/Mata Uang, dan Login Dinamis Terenkripsi.',
                  style: TextStyle(fontSize: 17, height: 1.5),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ));
  }
}
