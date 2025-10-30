// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
// Ganti 'astroview' dengan nama proyek Anda
import 'package:astroview/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // --- FUNGSI LOGIN DINAMIS ---
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    bool success = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        // JIKA BERHASIL:
        // Pindah ke /home TANPA MENGIRIM ARGUMENTS
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // JIKA GAGAL:
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
        padding: const EdgeInsets.all(32.0),
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
                backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                child: const Icon(
                  Icons.satellite_alt_rounded,
                  size: 60,
                  color: Colors.indigoAccent,
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
                'Please Login to Continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),
              // Field Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Field Password
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
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tombol Login
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('LOGIN',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              // Tombol Register
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pushNamed('/register');
                      },
                child: const Text('Belum punya akun? Registrasi di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
