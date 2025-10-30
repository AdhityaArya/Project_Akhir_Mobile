// lib/services/auth_service.dart
import 'dart:convert'; // Untuk utf8
import 'dart:math'; // Untuk Random (salt)
import 'package:crypto/crypto.dart'; // Untuk hashing SHA-256
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
// Ganti 'astroview_app' dengan nama proyek Anda
import '/models/user_model.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  // Nama untuk kotak Hive dan kunci enkripsi
  static const String _userBoxName = 'userAccounts';
  static const String _encryptionKeyName = 'hiveEncryptionKey';

  // --- FUNGSI HASHING (ENKRIPSI) PASSWORD ---

  // Membuat "garam" (salt) acak untuk setiap password
  String _generateSalt() {
    final random = Random.secure();
    // Buat 16 byte acak dan ubah jadi string
    final saltBytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  // Melakukan hash pada password + salt
  String _hashPassword(String password, String salt) {
    // Gabungkan password dan salt
    final bytes = utf8.encode(password + salt);
    // Lakukan hash SHA-256
    final digest = sha256.convert(bytes);
    // Kembalikan sebagai string
    return digest.toString();
  }
  // --- AKHIR FUNGSI HASHING ---

  // --- FUNGSI PENGELOLA KOTAK (BOX) HIVE TERENKRIPSI ---

  // 1. Mendapatkan atau membuat kunci enkripsi utama
  Future<List<int>> _getEncryptionKey() async {
    // Cek apakah kunci sudah ada di Secure Storage
    String? base64Key = await _secureStorage.read(key: _encryptionKeyName);

    if (base64Key == null) {
      // Jika belum ada, buat kunci baru
      final key = Hive.generateSecureKey();
      // Simpan kunci ini di Secure Storage agar tidak hilang
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Url.encode(key),
      );
      return key;
    } else {
      // Jika sudah ada, baca dan kembalikan
      return base64Url.decode(base64Key);
    }
  }

  // 2. Membuka "brankas" (kotak) Hive yang terenkripsi
  Future<Box<UserModel>> _openUserBox() async {
    // Ambil kunci enkripsi
    final encryptionKey = await _getEncryptionKey();

    // Buka kotak Hive dengan kunci tersebut
    // Ini memenuhi Syarat TA #3 (Koneksi Database Hive)
    return Hive.openBox<UserModel>(
      _userBoxName,
      // Berikan kunci enkripsi ke Hive
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }
  // --- AKHIR FUNGSI PENGELOLA KOTAK ---

  // --- FUNGSI LOGIN & REGISTER DINAMIS ---

  // Fungsi untuk login
  Future<bool> login(String username, String password) async {
    // Buka brankas akun
    final userBox = await _openUserBox();

    // Ambil data pengguna berdasarkan username (username adalah 'key')
    final UserModel? user = userBox.get(username);

    // 1. Cek apakah username ada
    if (user == null) {
      print('Login Gagal: Username tidak ditemukan');
      return false; // Gagal, username tidak ada
    }

    // 2. Jika username ada, kita hash password yang baru dimasukkan
    //    menggunakan 'salt' yang tersimpan di database
    final String inputHash = _hashPassword(password, user.salt);

    // 3. Bandingkan hash yang baru dibuat dengan hash yang tersimpan
    if (inputHash == user.hashedPassword) {
      // Jika HASH COCOK, login berhasil
      // Simpan token sesi (Syarat TA #2)
      await _secureStorage.write(
          key: 'auth_token', value: 'token_dinamis_untuk_$username');
      return true;
    } else {
      // Jika HASH TIDAK COCOK
      print('Login Gagal: Password salah');
      return false;
    }
  }

  // Fungsi untuk registrasi
  Future<bool> register(String username, String password) async {
    // Buka brankas akun
    final userBox = await _openUserBox();

    // Cek apakah username sudah dipakai (username adalah 'key')
    if (userBox.containsKey(username)) {
      print('Registrasi Gagal: Username sudah dipakai');
      return false; // Gagal, username sudah ada
    }

    // Jika belum ada:
    // 1. Buat "garam" (salt) baru
    final String salt = _generateSalt();
    // 2. Buat HASH dari password + salt (Syarat TA #2 - Enkripsi)
    final String hashedPassword = _hashPassword(password, salt);

    // 3. Buat objek UserModel baru
    final newUser = UserModel(
      username: username,
      hashedPassword: hashedPassword,
      salt: salt,
    );

    // 4. Simpan pengguna baru ke database HIVE (username sebagai 'key')
    await userBox.put(username, newUser);

    print('Registrasi Berhasil: $username');
    print('Database Akun sekarang berisi: ${userBox.keys.toList()}');
    return true; // Sukses
  }
}
