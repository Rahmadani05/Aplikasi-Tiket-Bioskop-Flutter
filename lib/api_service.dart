import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'dart:math';

class ApiService {
  static const String _apiKey = '98ee155e2269339a4d914859451507e1';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      final List results = decodedJson['results'];
      final categories = ['XXI', 'CGV', 'Cinepolis'];
      final random = Random();

      return results.map((json) {
        String randomCategory = categories[random.nextInt(categories.length)];
        return Movie.fromJson(json, randomCategory);
      }).toList();
    } else {
      throw Exception('Gagal memuat daftar film');
    }
  }

  static String getPosterUrl(String path) {
    return '$_imageBaseUrl$path';
  }

  static String getBackdropUrl(String path) {
    return '$_imageBaseUrl$path';
  }

  Future<String?> getYoutubeTrailerKey(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      final List results = decodedJson['results'];

      final officialTrailer = results.firstWhere(
        (video) => video['official'] == true && video['type'] == 'Trailer',
        orElse:
            () => results.firstWhere(
              (video) => video['type'] == 'Trailer',
              orElse: () => null,
            ),
      );

      if (officialTrailer != null) {
        return officialTrailer['key'];
      }
    }
    return null;
  }
}
