import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String hashedPassword;

  @HiveField(2)
  final String salt;

  UserModel({
    required this.username,
    required this.hashedPassword,
    required this.salt,
  });
}
