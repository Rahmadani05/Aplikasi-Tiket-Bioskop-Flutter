import 'package:flutter/material.dart';
import 'api_service.dart';
import 'film_tiket_detail.dart';

class Cinema {
  final String name;
  final String mall;
  final String distance;
  final String logoAsset;
  final String city;

  Cinema({
    required this.name,
    required this.mall,
    required this.distance,
    required this.logoAsset,
    required this.city,
  });
}

class BioskopScreen extends StatefulWidget {
  final String selectedCity;

  const BioskopScreen({super.key, required this.selectedCity});

  @override
  _BioskopScreenState createState() => _BioskopScreenState();
}

class _BioskopScreenState extends State<BioskopScreen> {
  final List<Cinema> allCinemas = [
    // Data bioskop (tidak perlu diubah)
    // SURABAYA
    Cinema(
      name: 'XXI',
      mall: 'Tunjungan Plaza 5',
      distance: '2.1 km',
      logoAsset: 'assets/images/xxi.png',
      city: 'SURABAYA',
    ),
    Cinema(
      name: 'CGV',
      mall: 'Marvell City',
      distance: '3.5 km',
      logoAsset: 'assets/images/cgv.png',
      city: 'SURABAYA',
    ),
    Cinema(
      name: 'Cinépolis',
      mall: 'City of Tomorrow',
      distance: '8.2 km',
      logoAsset: 'assets/images/cinepolis.png',
      city: 'SURABAYA',
    ),
    Cinema(
      name: 'XXI',
      mall: 'Pakuwon Mall',
      distance: '10.5 km',
      logoAsset: 'assets/images/xxi.png',
      city: 'SURABAYA',
    ),
    // JAKARTA
    Cinema(
      name: 'XXI',
      mall: 'Plaza Senayan',
      distance: '1.5 km',
      logoAsset: 'assets/images/xxi.png',
      city: 'JAKARTA',
    ),
    Cinema(
      name: 'CGV',
      mall: 'Grand Indonesia',
      distance: '3.8 km',
      logoAsset: 'assets/images/cgv.png',
      city: 'JAKARTA',
    ),
    Cinema(
      name: 'Cinépolis',
      mall: 'Plaza Semanggi',
      distance: '2.5 km',
      logoAsset: 'assets/images/cinepolis.png',
      city: 'JAKARTA',
    ),
    Cinema(
      name: 'XXI',
      mall: 'Gandaria City',
      distance: '6.2 km',
      logoAsset: 'assets/images/xxi.png',
      city: 'JAKARTA',
    ),
    // BANDUNG
    Cinema(
      name: 'XXI',
      mall: 'Cihampelas Walk',
      distance: '2.2 km',
      logoAsset: 'assets/images/xxi.png',
      city: 'BANDUNG',
    ),
    Cinema(
      name: 'CGV',
      mall: 'Paris Van Java',
      distance: '4.1 km',
      logoAsset: 'assets/images/cgv.png',
      city: 'BANDUNG',
    ),
  ];

  List<Cinema> _cinemasInSelectedCity = [];
  List<Cinema> _displayedCinemas = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filterByCity();
    _searchController.addListener(_filterBySearch);
  }

  @override
  void didUpdateWidget(covariant BioskopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCity != oldWidget.selectedCity) {
      _filterByCity();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBySearch);
    _searchController.dispose();
    super.dispose();
  }

  void _filterByCity() {
    setState(() {
      _cinemasInSelectedCity =
          allCinemas
              .where((cinema) => cinema.city == widget.selectedCity)
              .toList();
      _searchController.clear();
      _displayedCinemas = _cinemasInSelectedCity;
    });
  }

  void _filterBySearch() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedCinemas = _cinemasInSelectedCity;
      } else {
        _displayedCinemas =
            _cinemasInSelectedCity.where((cinema) {
              final cinemaName = cinema.name.toLowerCase();
              final mallName = cinema.mall.toLowerCase();
              return cinemaName.contains(query) || mallName.contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build method tidak ada perubahan
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bioskop di ${widget.selectedCity}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari bioskop atau mall...",
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Expanded(
            child:
                _displayedCinemas.isEmpty
                    ? Center(
                      child: Text(
                        'Tidak ada bioskop ditemukan di ${widget.selectedCity}',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _displayedCinemas.length,
                      itemBuilder: (context, index) {
                        final cinema = _displayedCinemas[index];
                        return cinemaListItem(cinema);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // ===== FUNGSI INI YANG DIUBAH =====
  Widget cinemaListItem(Cinema cinema) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(
                cinema.logoAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.business, color: Colors.grey);
                },
              ),
            ),
          ),
          title: Text(
            cinema.mall,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(cinema.name),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.location_on, color: Colors.blue, size: 18),
              SizedBox(height: 4),
              Text(cinema.distance, style: TextStyle(fontSize: 12)),
            ],
          ),
          onTap: () async {
            final apiService = ApiService();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );
            try {
              final allMovies = await apiService.getNowPlayingMovies();

              // Filter film berdasarkan nama bioskop (XXI, CGV, dll)
              final filteredMovies =
                  allMovies
                      .where((movie) => movie.category == cinema.name)
                      .toList();

              Navigator.pop(context); // Close loading dialog

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CinemaDetailPage(
                        cinema: cinema,
                        nowPlayingMovies:
                            filteredMovies, // Kirim data yang sudah difilter
                      ),
                ),
              );
            } catch (e) {
              Navigator.pop(context); // Close loading dialog on error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat daftar film: $e')),
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
        ),
      ],
    );
  }
}
