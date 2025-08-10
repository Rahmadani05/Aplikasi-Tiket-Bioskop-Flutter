import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'main.dart';
import 'api_service.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ApiService apiService = ApiService();
  YoutubePlayerController? _youtubeController;
  bool _isLoadingTrailer = true;
  bool _isPlayerVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchTrailer();
  }

  Future<void> _fetchTrailer() async {
    final trailerKey = await apiService.getYoutubeTrailerKey(widget.movie.id);
    if (trailerKey != null && mounted) {
      setState(() {
        _youtubeController = YoutubePlayerController(
          initialVideoId: trailerKey,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
        _isLoadingTrailer = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoadingTrailer = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildRatingAndReleaseInfo(),
                  const SizedBox(height: 24),
                  Text(
                    'Trailer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTrailerSection(),
                  const SizedBox(height: 24),
                  Text(
                    'Sinopsis',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTrailerSection() {
    if (_isPlayerVisible) {
      if (_youtubeController != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            progressColors: const ProgressBarColors(
              playedColor: Colors.blue,
              handleColor: Colors.blueAccent,
            ),
            onReady: () {},
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.movie.backdropPath,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.hide_image_outlined, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        _isLoadingTrailer
            ? const CircularProgressIndicator(color: Colors.white)
            : IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 60,
              ),
              onPressed: () {
                if (_youtubeController != null) {
                  setState(() {
                    _isPlayerVisible = true;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trailer untuk film ini tidak tersedia.'),
                    ),
                  );
                }
              },
            ),
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          widget.movie.backdropPath,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 250,
              color: Colors.grey,
              child: const Icon(
                Icons.movie_creation_outlined,
                color: Colors.white,
                size: 80,
              ),
            );
          },
        ),
        Container(
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRatingAndReleaseInfo() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          '${widget.movie.rating.toStringAsFixed(1)}/10',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 24),
        const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
        const SizedBox(width: 6),
        Text(widget.movie.releaseDate, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
