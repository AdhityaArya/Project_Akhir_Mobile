// lib/models/favorite_image.dart
import 'package:hive/hive.dart';

part 'favorite_image.g.dart';

@HiveType(typeId: 0) // 'Cetakan' untuk Hive
class FavoriteImage extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String explanation;

  @HiveField(3)
  final String date; // Gunakan 'date' sebagai ID unik

  FavoriteImage({
    required this.title,
    required this.url,
    required this.explanation,
    required this.date,
  });
}
