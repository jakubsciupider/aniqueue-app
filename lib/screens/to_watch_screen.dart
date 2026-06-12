import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import 'details_screen.dart';

class ToWatchScreen extends StatefulWidget {
  final List<AnimeItem> allAnime;

  const ToWatchScreen({super.key, required this.allAnime});

  @override
  State<ToWatchScreen> createState() => _ToWatchScreenState();
}

class _ToWatchScreenState extends State<ToWatchScreen> {
  @override
  Widget build(BuildContext context) {
    final toWatchList = widget.allAnime.where((anime) => anime.isToWatch).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Do obejrzenia'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: toWatchList.isEmpty
          ? const Center(child: Text('Brak danych'))
          : ListView.builder(
        itemCount: toWatchList.length,
        itemBuilder: (context, index) {
          final anime = toWatchList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  anime.imageUrl,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.movie, color: Colors.green),
                ),
              ),
              title: Text(anime.title),
              subtitle: Text('Ocena: ${anime.score}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(anime: anime),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          );
        },
      ),
    );
  }
}