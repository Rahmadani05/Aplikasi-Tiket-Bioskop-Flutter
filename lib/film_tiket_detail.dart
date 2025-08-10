// lib/cinema_detail_page.dart

import 'package:flutter/material.dart';
import 'bioskop_page.dart'; // Impor class Cinema
import 'main.dart'; // Impor class Movie
import 'kursi.dart'; // Impor halaman yang AKAN kita buat

class CinemaDetailPage extends StatelessWidget {
  final Cinema cinema;
  final List<Movie> nowPlayingMovies; // Daftar film yang sedang tayang

  const CinemaDetailPage({
    super.key,
    required this.cinema,
    required this.nowPlayingMovies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cinema.mall),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: nowPlayingMovies.length,
        itemBuilder: (context, index) {
          final movie = nowPlayingMovies[index];
          // Tampilkan setiap film sebagai sebuah card
          return MovieScheduleCard(cinema: cinema, movie: movie);
        },
      ),
    );
  }
}

// Widget untuk menampilkan satu film beserta jadwalnya
class MovieScheduleCard extends StatelessWidget {
  const MovieScheduleCard({
    super.key,
    required this.cinema,
    required this.movie,
  });

  final Cinema cinema;
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    // Jadwal dummy untuk setiap film
    final List<String> schedules = ['12:30', '15:00', '17:30', '20:00'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Durasi: 128 Menit | Genre: Aksi, Sci-Fi',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24, thickness: 1),
            const Text(
              'Jadwal Hari Ini',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // Gunakan Wrap agar jadwal bisa pindah ke baris baru jika tidak muat
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  schedules.map((time) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade800,
                      ),
                      onPressed: () {
                        // Navigasi ke halaman pemilihan kursi
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SeatSelectionPage(
                                  cinema: cinema,
                                  movie: movie,
                                  selectedTime: time,
                                ),
                          ),
                        );
                      },
                      child: Text(time),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
