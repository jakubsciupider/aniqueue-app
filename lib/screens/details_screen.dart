import 'package:flutter/material.dart';
import '../models/anime_item.dart';

class DetailsScreen extends StatefulWidget {
  final AnimeItem anime;

  const DetailsScreen({super.key, required this.anime});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // snackbar wyswietlanie na dole
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anime.title),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.anime.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.movie, size: 100, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.anime.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    // ikona favorites
                    IconButton(
                      icon: Icon(
                        widget.anime.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: widget.anime.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.anime.isFavorite = !widget.anime.isFavorite;
                        });
                        _showSnackBar(
                          widget.anime.isFavorite ? 'Dodano do ulubionych' : 'Usunięto z ulubionych',
                        );
                      },
                    ),
                    // ikonka do bookmarkowania
                    IconButton(
                      icon: Icon(
                        widget.anime.isToWatch ? Icons.bookmark : Icons.bookmark_border,
                        color: widget.anime.isToWatch ? Colors.green.shade600 : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.anime.isToWatch = !widget.anime.isToWatch;
                        });
                        _showSnackBar(
                          widget.anime.isToWatch ? 'Dodano do watchlisty' : 'Usunięto z watchlisty',
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      widget.anime.score.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Opis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.anime.synopsis,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}