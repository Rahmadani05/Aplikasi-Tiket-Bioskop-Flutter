import 'package:flutter/material.dart';
import 'bioskop_page.dart';
import 'api_service.dart';
import 'film_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'tiket_page.dart';

class Movie {
  String title;
  String posterPath;
  String category;
  String overview;
  double rating;
  String backdropPath;
  String releaseDate;
  int id;

  Movie({
    required this.title,
    required this.posterPath,
    required this.category,
    required this.overview,
    required this.rating,
    required this.backdropPath,
    required this.releaseDate,
    required this.id,
  });

  factory Movie.fromJson(Map<String, dynamic> json, String category) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: ApiService.getPosterUrl(json['poster_path']),
      backdropPath: ApiService.getBackdropUrl(json['backdrop_path']),
      category: category,
      overview: json['overview'],
      rating: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'],
    );
  }
}

void main() async {
  // Pastikan semua widget sudah siap sebelum menjalankan kode platform
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(TixIDCloneApp());
}

class TixIDCloneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIX ID Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedCity = 'SURABAYA';

  void _updateCity(String newCity) {
    setState(() {
      _selectedCity = newCity;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWidgetOptions = <Widget>[
      HomeScreenContent(
        selectedCity: _selectedCity,
        onCityChanged: _updateCity,
      ),
      BioskopScreen(selectedCity: _selectedCity),
      // ===== GANTI SCAFFOLD INI =====
      TicketPage(), // dengan TicketPage yang baru
    ];

    return Scaffold(
      body: Center(child: currentWidgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: "Bioskop",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Tiket",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  final String selectedCity;
  final Function(String) onCityChanged;

  const HomeScreenContent({
    super.key,
    required this.selectedCity,
    required this.onCityChanged,
  });

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final List<String> categories = ['Semua Film', 'XXI', 'CGV', 'Cinepolis'];
  String _selectedCategory = 'Semua Film';

  late Future<List<Movie>> _moviesFuture;
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  void _fetchMovies() {
    final apiService = ApiService();
    _moviesFuture = apiService.getNowPlayingMovies();
    _moviesFuture.then((movies) {
      if (mounted) {
        setState(() {
          _allMovies = movies;
          _filterMovies();
        });
      }
    });
  }

  void _filterMovies() {
    setState(() {
      if (_selectedCategory == 'Semua Film') {
        _filteredMovies = _allMovies;
      } else {
        _filteredMovies =
            _allMovies
                .where((movie) => movie.category == _selectedCategory)
                .toList();
      }
    });
  }

  void _showCitySelectionSheet(BuildContext context) {
    final List<String> availableCities = [
      'SURABAYA',
      'JAKARTA',
      'BANDUNG',
      'MEDAN',
      'MAKASSAR',
      'SEMARANG',
      'YOGYAKARTA',
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Lokasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableCities.length,
                  itemBuilder: (context, index) {
                    final city = availableCities[index];
                    return ListTile(
                      title: Text(city),
                      trailing:
                          widget.selectedCity == city
                              ? Icon(Icons.check, color: Colors.blue)
                              : null,
                      onTap: () {
                        widget.onCityChanged(city);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _showCitySelectionSheet(context),
              child: Row(
                children: [
                  Text(widget.selectedCity, style: TextStyle(fontSize: 16)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            promoBanner(),
            vipBanner(),
            sectionHeader("Sedang Tayang", showAll: true),
            categoryChips(),
            movieList(),
          ],
        ),
      ),
    );
  }

  Widget categoryChips() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: EdgeInsets.only(left: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (isSelected) {
                if (isSelected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _filterMovies();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget movieList() {
    return Container(
      height: 250,
      child: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.only(left: 6, right: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = _filteredMovies[index];
                return movieCard(movie);
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget movieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 150,
            child: Image.network(movie.posterPath, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget promoBanner() {
    final List<String> promoImages = [
      'assets/images/promo1.jpeg',
      'assets/images/promo2.jpeg',
    ];
    return Container(
      margin: EdgeInsets.all(10),
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: PageView.builder(
          itemCount: promoImages.length,
          itemBuilder: (context, index) {
            return Image.asset(
              promoImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        ),
      ),
    );
  }

  Widget vipBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.amberAccent.withOpacity(0.3),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text("Jadilah TAD ID VIP dan Dapatkan untung lebih 😍"),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget sectionHeader(String title, {bool showAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.movie),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (showAll) TextButton(onPressed: () {}, child: Text("Semua >")),
        ],
      ),
    );
  }
}
