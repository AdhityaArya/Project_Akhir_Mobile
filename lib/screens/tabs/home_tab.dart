// lib/screens/tabs/home_tab.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Impor Hive Flutter
// Ganti 'astroview_app' dengan nama proyek Anda jika berbeda
import '/models/nasa_image.dart';
import '/models/apod_image.dart';
import '/models/favorite_image.dart'; // Impor model Favorit
import '/services/api_service.dart';
import '/screens/image_detail_screen.dart'; // Impor halaman detail

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Instance ApiService untuk memanggil API
  final ApiService _apiService = ApiService();
  // Controller untuk mengelola teks di search bar
  final TextEditingController _searchController = TextEditingController();

  // State (variabel internal) untuk menyimpan daftar gambar yang akan ditampilkan
  List<NasaImage> _displayImages = [];
  // State untuk menandai apakah aplikasi sedang memuat data dari API
  bool _isLoading = false;
  // State untuk menandai apakah yang sedang ditampilkan adalah hasil pencarian
  bool _isShowingSearchResults = false;
  // Kata kunci default yang digunakan untuk memuat rekomendasi awal
  final String _defaultQuery =
      "NASA"; // Anda bisa ganti ini (misal: "Mars", "galaxy")

  @override
  void initState() {
    super.initState();
    // Saat halaman ini pertama kali dibuka, panggil fungsi untuk memuat rekomendasi
    _loadRecommendations();
  }

  @override
  void dispose() {
    // Penting: Hapus controller saat widget tidak lagi digunakan
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK MEMUAT REKOMENDASI AWAL ---
  Future<void> _loadRecommendations() async {
    // Update state untuk menampilkan loading dan menandai bukan mode search
    setState(() {
      _isLoading = true;
      _isShowingSearchResults = false; // Kembali ke mode rekomendasi
      _searchController.clear(); // Hapus teks di search bar
    });
    try {
      // Panggil API untuk mencari gambar berdasarkan query default
      final results = await _apiService.searchImages(_defaultQuery);
      // Update state dengan hasil dari API dan matikan loading
      // Cek 'mounted' sebelum setState, best practice setelah await
      if (mounted) {
        setState(() {
          _displayImages = results; // Tampilkan hasil rekomendasi
          _isLoading = false;
        });
      }
    } catch (e) {
      // Jika terjadi error saat memanggil API
      if (mounted) {
        setState(() {
          _isLoading = false; // Matikan loading
        });
        // Tampilkan pesan error kepada pengguna
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat rekomendasi: ${e.toString()}')),
        );
      }
    }
  }

  // --- FUNGSI UNTUK MELAKUKAN PENCARIAN ---
  Future<void> _performSearch(String query) async {
    // Jika query (teks pencarian) kosong
    if (query.isEmpty) {
      // Panggil kembali fungsi untuk memuat rekomendasi
      _loadRecommendations();
      // Sembunyikan keyboard
      FocusScope.of(context).unfocus();
      return; // Hentikan eksekusi fungsi
    }

    // Jika query tidak kosong, mulai proses pencarian
    setState(() {
      _isLoading = true; // Tampilkan loading
      _isShowingSearchResults = true; // Masuk ke mode hasil pencarian
    });

    try {
      // Panggil API untuk mencari gambar berdasarkan query pengguna
      final results = await _apiService.searchImages(query);
      // Update state dengan hasil pencarian dan matikan loading
      if (mounted) {
        setState(() {
          _displayImages = results; // Tampilkan hasil pencarian
          _isLoading = false;
        });
      }
    } catch (e) {
      // Jika terjadi error saat pencarian
      if (mounted) {
        setState(() {
          _isLoading = false; // Matikan loading
        });
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error pencarian: ${e.toString()}')),
        );
      }
    }
  }

  // --- FUNGSI UNTUK MENAMPILKAN POPUP APOD DENGAN TOMBOL LIKE ---
  Future<void> _showApodDialog(BuildContext context) async {
    // Tampilkan dialog loading dulu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
    try {
      // Panggil API untuk mendapatkan data APOD
      final ApodImage apod = await _apiService.getApod();
      if (!mounted) return; // Cek mounted setelah await
      Navigator.of(context).pop(); // Tutup dialog loading

      // Buka kotak Hive untuk cek status favorit
      final favoritesBox = Hive.box<FavoriteImage>('favorites');

      // Tampilkan dialog utama
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Gunakan StatefulBuilder agar dialog bisa punya state sendiri (untuk tombol like)
          return StatefulBuilder(
            builder: (context, setDialogState) {
              // Cek status favorit awal untuk APOD ini (berdasarkan tanggal)
              bool isFavorited = favoritesBox.containsKey(apod.date);

              // Fungsi untuk menambah/menghapus APOD dari favorit di dalam dialog
              void toggleFavoriteApod() {
                if (isFavorited) {
                  // Jika sudah favorit -> Hapus dari Hive
                  favoritesBox.delete(apod.date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('APOD dihapus dari favorit.'),
                        duration: Duration(seconds: 1)),
                  );
                } else {
                  // Jika belum favorit -> Tambahkan ke Hive
                  final newFavorite = FavoriteImage(
                    title: apod.title,
                    url: apod.url, // Gunakan URL standar untuk thumbnail
                    explanation: apod.explanation, date: apod.date,
                  );
                  favoritesBox.put(
                      apod.date, newFavorite); // Gunakan date sebagai key
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('APOD ditambahkan ke favorit!'),
                        duration: Duration(seconds: 1)),
                  );
                }
                // Update state DI DALAM dialog agar ikon tombol berubah
                setDialogState(() {
                  isFavorited = !isFavorited;
                });
                // Update juga state di LUAR dialog (HomeTab) agar ProfileTab ikut refresh
                // Ini cara sederhana, mungkin perlu cara lebih baik via state management global
                setState(() {});
              }

              // Bangun tampilan AlertDialog
              return AlertDialog(
                backgroundColor: Colors.grey[850],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                // Gunakan SingleChildScrollView agar konten bisa di-scroll
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Agar dialog tidak memenuhi layar
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
                        // Beri sudut membulat pada gambar
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          apod.url,
                          fit: BoxFit.contain, // Tampilkan seluruh gambar
                          // Tampilkan loading saat gambar dimuat
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 50),
                                      child: Center(
                                          child: CircularProgressIndicator())),
                          // Tampilkan pesan jika gambar gagal dimuat
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
                      // Tampilkan deskripsi
                      Text(
                        apod.explanation,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                // Tombol aksi di bawah dialog
                actions: [
                  // Tombol Favorit (Like/Unlike)
                  IconButton(
                    icon: Icon(
                      // Ganti ikon berdasarkan status favorit
                      isFavorited ? Icons.favorite : Icons.favorite_outline,
                      // Beri warna merah jika sudah difavoritkan
                      color: isFavorited ? Colors.redAccent : Colors.grey,
                      size: 28, // Ukuran ikon
                    ),
                    tooltip: isFavorited
                        ? 'Hapus dari Favorit'
                        : 'Simpan ke Favorit',
                    // Panggil fungsi toggle saat ditekan
                    onPressed: toggleFavoriteApod,
                  ),
                  const Spacer(), // Dorong tombol Tutup ke kanan
                  // Tombol Tutup Dialog
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
      if (!mounted) return; // Cek mounted setelah await
      Navigator.of(context).pop(); // Tutup dialog loading jika error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat APOD: ${e.toString()}')),
      );
    }
  }
  // --- AKHIR FUNGSI POPUP APOD ---

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Ratakan judul Grid ke kiri
      children: [
        // --- BAGIAN 1: SEARCH BAR ---
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

        // --- BAGIAN 2: KARTU TOMBOL APOD ---
        _buildApodCard(context), // Panggil widget kartu APOD

        // Judul untuk Grid (berubah sesuai mode)
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

        // --- BAGIAN 3: KONTEN (REKOMENDASI / HASIL SEARCH) ---
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
                  : _buildImageGrid(), // Tampilkan Grid gambar
        ),
      ],
    );
  }

  // --- WIDGET UNTUK MEMBUAT KARTU TOMBOL APOD ---
  Widget _buildApodCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      clipBehavior: Clip.antiAlias, // Memotong sudut
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850], // Warna latar kartu
      child: InkWell(
        // Membuat Card bisa di-tap
        onTap: () =>
            _showApodDialog(context), // Panggil fungsi dialog saat di-tap
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0), // Padding dalam kartu
          child: Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: Colors.amber[300], size: 28), // Ikon bintang
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
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey), // Ikon panah
            ],
          ),
        ),
      ),
    );
  }
  // --- AKHIR WIDGET KARTU APOD ---

  // --- WIDGET UNTUK MEMBUAT GRID GAMBAR ---
  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0), // Padding di sekitar grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 gambar per baris
        crossAxisSpacing: 8.0, // Jarak horizontal
        mainAxisSpacing: 8.0, // Jarak vertikal
        childAspectRatio: 0.8, // Rasio gambar
      ),
      itemCount: _displayImages.length, // Jumlah gambar
      // Fungsi 'builder' yang akan dipanggil untuk membuat setiap item grid
      itemBuilder: (context, index) {
        final image = _displayImages[index]; // Ambil data gambar
        return GestureDetector(
          // Agar bisa di-klik
          onTap: () {
            // Navigasi ke Halaman Detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(
                  title: image.title,
                  url: image.imageUrl, // Kirim URL gambar
                  explanation: image.description, // Kirim deskripsi
                  date: image.date, // Kirim tanggal (untuk ID favorit)
                ),
              ),
            );
          },
          child: Card(
            // Tampilkan dalam Card
            clipBehavior: Clip.antiAlias,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: Colors.grey[850], // Warna latar card gambar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gambar
                Expanded(
                  child: Image.network(
                    image.imageUrl,
                    fit: BoxFit.cover, // Penuhi area
                    // Tampilkan loading indicator saat gambar sedang dimuat
                    loadingBuilder: (context, child, progress) => progress ==
                            null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.0)),
                    // Tampilkan ikon error jika gambar gagal dimuat
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 40)), // Icon jika gambar error
                  ),
                ),
                // Judul
                Padding(
                  padding:
                      const EdgeInsets.all(8.0), // Beri padding di sekitar teks
                  child: Text(
                    image.title, // Tampilkan judul
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70), // Warna teks judul
                    maxLines: 2, // Batasi judul maksimal 2 baris
                    overflow: TextOverflow
                        .ellipsis, // Tambahkan '...' jika judul terlalu panjang
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // --- AKHIR WIDGET GRID GAMBAR ---
} // Akhir _HomeTabState
