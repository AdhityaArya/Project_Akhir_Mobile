// lib/services/auth_service.dart
import 'dart:convert'; // Untuk utf8
import 'dart:math'; // Untuk Random (salt)
import 'package:crypto/crypto.dart'; // Untuk hashing SHA-256
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
// Ganti 'astroview' dengan nama proyek Anda
import 'package:astroview/models/user_model.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  // Nama untuk kotak Hive dan kunci enkripsi
  static const String _userBoxName = 'userAccounts';
  static const String _encryptionKeyName = 'hiveEncryptionKey';

  // --- FUNGSI HASHING (ENKRIPSI) PASSWORD ---

  // Membuat "garam" (salt) acak untuk setiap password
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  // Melakukan hash pada password + salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  // --- AKHIR FUNGSI HASHING ---

  // --- FUNGSI PENGELOLA KOTAK (BOX) HIVE TERENKRIPSI ---

  // 1. Mendapatkan atau membuat kunci enkripsi utama
  Future<List<int>> _getEncryptionKey() async {
    String? base64Key = await _secureStorage.read(key: _encryptionKeyName);
    if (base64Key == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Url.encode(key),
      );
      return key;
    } else {
      return base64Url.decode(base64Key);
    }
  }

  // 2. Membuka "brankas" (kotak) Hive yang terenkripsi
  Future<Box<UserModel>> _openUserBox() async {
    final encryptionKey = await _getEncryptionKey();
    // Buka kotak Hive dengan kunci tersebut
    return Hive.openBox<UserModel>(
      _userBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }
  // --- AKHIR FUNGSI PENGELOLA KOTAK ---

  // --- FUNGSI LOGIN & REGISTER DINAMIS ---

  // Fungsi untuk login
  Future<bool> login(String username, String password) async {
    final userBox = await _openUserBox();
    final UserModel? user = userBox.get(username);

    // 1. Cek apakah username ada
    if (user == null) {
      print(
          'AuthService [DEBUG]: Login Gagal. Username "$username" tidak ditemukan di Hive.');
      return false; // Gagal, username tidak ada
    }

    // 2. Jika username ada, hash password yang diinput
    final String inputHash = _hashPassword(password, user.salt);

    // 3. Bandingkan hash
    if (inputHash == user.hashedPassword) {
      // Jika HASH COCOK
      print('AuthService [DEBUG]: Login Berhasil untuk "$username".');

      // --- INI BAGIAN PENTINGNYA ---
      // Simpan token sesi
      await _secureStorage.write(
          key: 'auth_token', value: 'token_dinamis_untuk_$username');
      // SIMPAN JUGA USERNAME
      await _secureStorage.write(key: 'username', value: username);
      print(
          'AuthService [DEBUG]: Token DAN Username "$username" berhasil disimpan.');
      // --- AKHIR BAGIAN PENTING ---

      return true;
    } else {
      // Jika HASH TIDAK COCOK
      print('AuthService [DEBUG]: Login Gagal. Password salah.');
      return false;
    }
  }

  // Fungsi untuk registrasi
  Future<bool> register(String username, String password) async {
    final userBox = await _openUserBox();

    // Cek apakah username sudah dipakai
    if (userBox.containsKey(username)) {
      print('Registrasi Gagal: Username sudah dipakai');
      return false;
    }

    // Buat salt dan hash password
    final String salt = _generateSalt();
    final String hashedPassword = _hashPassword(password, salt);

    // Buat objek UserModel baru
    final newUser = UserModel(
      username: username,
      hashedPassword: hashedPassword,
      salt: salt,
    );

    // Simpan pengguna baru ke database HIVE
    await userBox.put(username, newUser);

    print('Registrasi Berhasil: $username');
    print('Database Akun sekarang berisi: ${userBox.keys.toList()}');
    return true; // Sukses
  }
}
