import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:astroview/models/user_model.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  static const String _userBoxName = 'userAccounts';
  static const String _encryptionKeyName = 'hiveEncryptionKey';

  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

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

  Future<Box<UserModel>> _openUserBox() async {
    final encryptionKey = await _getEncryptionKey();
    return Hive.openBox<UserModel>(
      _userBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<bool> login(String username, String password) async {
    final userBox = await _openUserBox();
    final UserModel? user = userBox.get(username);

    if (user == null) {
      print(
          'AuthService [DEBUG]: Login Gagal. Username "$username" tidak ditemukan di Hive.');
      return false;
    }

    final String inputHash = _hashPassword(password, user.salt);

    if (inputHash == user.hashedPassword) {
      print('AuthService [DEBUG]: Login Berhasil untuk "$username".');

      await _secureStorage.write(
          key: 'auth_token', value: 'token_dinamis_untuk_$username');
      await _secureStorage.write(key: 'username', value: username);
      print(
          'AuthService [DEBUG]: Token DAN Username "$username" berhasil disimpan.');

      return true;
    } else {
      print('AuthService [DEBUG]: Login Gagal. Password salah.');
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    final userBox = await _openUserBox();

    if (userBox.containsKey(username)) {
      print('Registrasi Gagal: Username sudah dipakai');
      return false;
    }

    final String salt = _generateSalt();
    final String hashedPassword = _hashPassword(password, salt);

    final newUser = UserModel(
      username: username,
      hashedPassword: hashedPassword,
      salt: salt,
    );

    await userBox.put(username, newUser);

    print('Registrasi Berhasil: $username');
    print('Database Akun sekarang berisi: ${userBox.keys.toList()}');
    return true;
  }
}
