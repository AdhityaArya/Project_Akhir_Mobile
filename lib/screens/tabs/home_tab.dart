import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/models/nasa_image.dart';
import '/models/apod_image.dart';
import '/models/favorite_image.dart';
import '/services/api_service.dart';
import '/screens/image_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<NasaImage> _displayImages = [];
  bool _isLoading = false;
  bool _isShowingSearchResults = false;
  final String _defaultQuery = "NASA";

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _isShowingSearchResults = false;
      _searchController.clear();
    });
    try {
      final results = await _apiService.searchImages(_defaultQuery);
      if (mounted) {
        setState(() {
          _displayImages = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat rekomendasi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _loadRecommendations();
      FocusScope.of(context).unfocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _isShowingSearchResults = true;
    });

    try {
      final results = await _apiService.searchImages(query);
      if (mounted) {
        setState(() {
          _displayImages = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error pencarian: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showApodDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
    try {
      final ApodImage apod = await _apiService.getApod();
      if (!mounted) return;
      Navigator.of(context).pop();

      final favoritesBox = Hive.box<FavoriteImage>('favorites');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              bool isFavorited = favoritesBox.containsKey(apod.date);
              void toggleFavoriteApod() {
                if (isFavorited) {
                  favoritesBox.delete(apod.date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('APOD dihapus dari favorit.'),
                        duration: Duration(seconds: 1)),
                  );
                } else {
                  final newFavorite = FavoriteImage(
                    title: apod.title,
                    url: apod.url,
                    explanation: apod.explanation,
                    date: apod.date,
                  );
                  favoritesBox.put(apod.date, newFavorite);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('APOD ditambahkan ke favorit!'),
                        duration: Duration(seconds: 1)),
                  );
                }
                setDialogState(() {
                  isFavorited = !isFavorited;
                });
                setState(() {});
              }

              return AlertDialog(
                backgroundColor: Colors.grey[850],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(apod.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(apod.date,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[400])),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          apod.url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 50),
                                      child: Center(
                                          child: CircularProgressIndicator())),
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                  child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        'Gagal memuat gambar APOD',
                                        textAlign: TextAlign.center,
                                      ))),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        apod.explanation,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[300]),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorited ? Colors.redAccent : Colors.grey,
                      size: 28,
                    ),
                    tooltip: isFavorited
                        ? 'Hapus dari Favorit'
                        : 'Simpan ke Favorit',
                    onPressed: toggleFavoriteApod,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat APOD: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Cari gambar NASA...',
              hintText: 'Kosongkan untuk rekomendasi',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[800],
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      tooltip: 'Hapus Pencarian & Kembali ke Rekomendasi',
                      onPressed: () {
                        _performSearch('');
                      },
                    )
                  : null,
            ),
            onSubmitted: _performSearch,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        _buildApodCard(context),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4.0),
          child: Text(
            _isShowingSearchResults ? 'Hasil Pencarian' : 'Rekomendasi Gambar',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[400]),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _displayImages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _isShowingSearchResults
                              ? 'Tidak ada hasil ditemukan untuk "${_searchController.text}".'
                              : 'Gagal memuat rekomendasi.\nPeriksa koneksi internet atau coba lagi.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                      ),
                    )
                  : _buildImageGrid(),
        ),
      ],
    );
  }

  Widget _buildApodCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.indigo,
      child: InkWell(
        onTap: () => _showApodDialog(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.star, color: Colors.amber[300], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gambar Astronomi Hari Ini (APOD)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: _displayImages.length,
      itemBuilder: (context, index) {
        final image = _displayImages[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(
                  title: image.title,
                  url: image.imageUrl,
                  explanation: image.description,
                  date: image.date,
                ),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: Colors.grey[850],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    image.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress ==
                            null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.0)),
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey, size: 40)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    image.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
