// lib/models/user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart'; // File ini akan digenerate

@HiveType(typeId: 1) // Gunakan ID unik (0 sudah dipakai FavoriteImage)
class UserModel extends HiveObject {
  // Kita gunakan username sebagai Hive key (kunci) nanti

  @HiveField(0)
  final String username;

  @HiveField(1)
  final String hashedPassword; // KITA SIMPAN HASH, BUKAN PASSWORD ASLI

  @HiveField(2)
  final String salt; // "Garam" untuk membuat hash lebih aman

  UserModel({
    required this.username,
    required this.hashedPassword,
    required this.salt,
  });
}
