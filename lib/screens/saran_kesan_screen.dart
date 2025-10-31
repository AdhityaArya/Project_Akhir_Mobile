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
                  'Mata kuliah ini adalah salah satu yang paling banyak prateknya. Kami belajar teori sekaligus langsung praktek secara bersamaan untuk membuat aplikasi yang bisa dijalankan di smartphone. Kami jadi paham konsep-konsep penting dalam pengembangan aplikasi, seperti state management, navigasi antar halaman, dan bahkan penyimpanan data lokal',
                  style: TextStyle(fontSize: 17, height: 1.5),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ));
  }
}
