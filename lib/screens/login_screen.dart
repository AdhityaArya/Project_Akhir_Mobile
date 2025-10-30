// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Tidak dipakai di file ini
// Ganti 'astroview_app' dengan nama proyek Anda
import '/services/auth_service.dart'; // Impor AuthService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil teks dari input pengguna
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Buat instance dari AuthService (yang akan mengecek ke Hive)
  final AuthService _authService = AuthService();

  // State untuk melacak UI
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Untuk menampilkan loading spinner

  // --- FUNGSI LOGIN DINAMIS ---
  void _login() async {
    // 1. Tampilkan loading spinner
    setState(() {
      _isLoading = true;
    });

    // 2. Panggil fungsi login dari AuthService,
    //    kirimkan teks yang diketik pengguna
    bool success = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    // 3. Hentikan loading spinner
    setState(() {
      _isLoading = false;
    });

    // 4. Cek hasil login
    if (mounted) {
      // Pastikan widget masih ada di layar
      if (success) {
        // JIKA BERHASIL (data ada di Hive dan password cocok):
        // Pindah ke halaman /home dan kirim username
        Navigator.of(context).pushReplacementNamed(
          '/home', // Pastikan rute ini ada di main.dart
          arguments: _usernameController.text,
        );
      } else {
        // JIKA GAGAL (username tidak ada atau password salah):
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('LOGIN GAGAL, PERIKSA KEMBALI USERNAME DAN PASSWORD'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // --- AKHIR FUNGSI LOGIN DINAMIS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0), // Padding diubah ke 32
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height - (kToolbarHeight * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Ikon
              CircleAvatar(
                radius: 50,
                // Warna background disesuaikan
                backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                child: const Icon(
                  Icons.satellite_alt_rounded, // Ikon satelit
                  size: 60,
                  color: Colors.indigoAccent, // Warna ikon
                ),
              ),
              const SizedBox(height: 24.0),

              // Teks Judul
              const Text(
                'Welcome to AstroView',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please Login to Continue', // Typo 'Plase' diperbaiki
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[400]), // Warna disesuaikan
              ),
              const SizedBox(height: 40),

              // Field Username
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field Password (dengan ikon mata)
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility // Ikon mata terbuka
                          : Icons.visibility_off, // Ikon mata tertutup
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Baris Remember Me & Forgot Password
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Agar terpisah
                children: [
                  Row(
                    // Checkbox Remember Me
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  // Tombol Forgot Password (placeholder)
                  TextButton(
                    onPressed: () {
                      // Fungsi Lupa Password bisa ditambahkan di sini
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Login
              ElevatedButton(
                // Nonaktifkan tombol saat _isLoading == true
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading // Tampilkan loading atau teks
                    ? const SizedBox(
                        // Gunakan SizedBox agar ukurannya konsisten
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'LOGIN',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16), // Jarak

              // --- TOMBOL BARU UNTUK REGISTER (DITAMBAHKAN DI SINI) ---
              TextButton(
                // Nonaktifkan tombol saat sedang loading login
                onPressed: _isLoading
                    ? null
                    : () {
                        // Pindah ke halaman /register
                        // Pastikan rute '/register' sudah ada di main.dart
                        Navigator.of(context).pushNamed('/register');
                      },
                child: const Text('Belum punya akun? Registrasi di sini'),
              ),
              // --- AKHIR TOMBOL BARU ---
            ],
          ),
        ),
      ),
    );
  }
}
