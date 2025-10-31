import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/models/favorite_image.dart';

class ImageDetailScreen extends StatefulWidget {
  final String title;
  final String url;
  final String explanation;
  final String date;

  const ImageDetailScreen({
    super.key,
    required this.title,
    required this.url,
    required this.explanation,
    required this.date,
  });

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  bool _isFavorited = false;
  late Box<FavoriteImage> _favoritesBox;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<FavoriteImage>('favorites');
    _checkIfFavorited();
  }

  void _checkIfFavorited() {
    setState(() {
      _isFavorited = _favoritesBox.containsKey(widget.date);
    });
  }

  void _toggleFavorite() {
    if (_isFavorited) {
      _removeFromFavorites();
    } else {
      _saveToFavorites();
    }
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  void _saveToFavorites() {
    final newFavorite = FavoriteImage(
      title: widget.title,
      url: widget.url,
      explanation: widget.explanation,
      date: widget.date,
    );
    _favoritesBox.put(widget.date, newFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ditambahkan ke favorit!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeFromFavorites() {
    _favoritesBox.delete(widget.date);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dihapus dari favorit.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_outline,
              color: _isFavorited ? Colors.redAccent : null,
            ),
            tooltip: _isFavorited ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(widget.date, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Text(
              widget.explanation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
