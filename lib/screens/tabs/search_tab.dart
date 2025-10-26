// lib/screens/tabs/search_tab.dart
import 'package:flutter/material.dart';
// (Pastikan nama 'astroview_app' sesuai dengan nama proyek Anda)
import '/models/nasa_image.dart';
import '/services/api_service.dart';
import '/screens/image_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<NasaImage> _searchResults = [];
  bool _isLoading = false;

  void _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.searchImages(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- UI PENCARIAN (Syarat #7) ---
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Ketik pencarian (cth: Mars, Nebula)...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _performSearch(_searchController.text);
                },
              ),
            ),
          ),
        ),

        // --- HASIL PENCARIAN ---
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final image = _searchResults[index];
                    return ListTile(
                      leading: Image.network(
                        image.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(image.title),
                      subtitle: Text(
                        image.date,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // Navigasi ke Halaman Detail (Syarat #7 - Pemilihan)
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
                    );
                  },
                ),
        ),
      ],
    );
  }
}
