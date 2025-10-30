// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
// Ganti 'astroview' dengan nama proyek Anda jika berbeda
import 'package:astroview/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk mengambil teks
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  // Instance AuthService untuk memanggil fungsi register
  final AuthService _authService = AuthService();
  // State untuk loading
  bool _isLoading = false;

  // --- FUNGSI UNTUK REGISTRASI ---
  void _register() async {
    // Validasi sederhana: pastikan tidak kosong
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return; // Hentikan fungsi jika kosong
    }

    // Mulai loading
    setState(() {
      _isLoading = true;
    });

    // Panggil fungsi register dari AuthService (yang menyimpan ke Hive)
    bool success = await _authService.register(
      _usernameController.text,
      _passwordController.text,
    );

    // Hentikan loading
    setState(() {
      _isLoading = false;
    });

    // Cek hasil registrasi
    if (mounted) {
      if (success) {
        // JIKA BERHASIL:
        // Beri pesan sukses dan kembali ke halaman Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan Login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context)
            .pop(); // 'pop' = kembali ke layar sebelumnya (Login)
      } else {
        // JIKA GAGAL (username sudah ada):
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Gagal! Username sudah dipakai.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // --- AKHIR FUNGSI REGISTRASI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar agar pengguna bisa kembali ke Login secara manual
      appBar: AppBar(
        title: const Text('Registrasi Akun Baru'),
        backgroundColor: Colors.transparent, // Transparan
        elevation: 0, // Hilangkan bayangan
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          // Posisikan konten di tengah
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Beri jarak dari AppBar
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            // Ikon
            Icon(
              Icons.person_add_alt_1,
              size: 80,
              color: Colors.indigoAccent,
            ),
            const SizedBox(height: 24),

            // Judul
            const Text(
              'Buat Akun Baru',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Field Username Baru
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username Baru',
                prefixIcon: const Icon(Icons.person_add_alt_1_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Field Password Baru
            TextField(
              controller: _passwordController,
              obscureText: true, // Sembunyikan password
              decoration: InputDecoration(
                labelText: 'Password Baru',
                prefixIcon: const Icon(Icons.lock_person_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Daftar
            ElevatedButton(
              // Nonaktifkan tombol saat sedang loading
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  // Tampilkan loading spinner jika sedang proses
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    )
                  // Tampilkan teks jika tidak loading
                  : const Text(
                      'DAFTAR',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
