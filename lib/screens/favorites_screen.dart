import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import 'details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<AnimeItem> allAnime;

  const FavoritesScreen({super.key, required this.allAnime});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesList = widget.allAnime.where((anime) => anime.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: favoritesList.isEmpty
          ? const Center(child: Text('Brak danych'))
          : ListView.builder(
        itemCount: favoritesList.length,
        itemBuilder: (context, index) {
          final anime = favoritesList[index];

          return Dismissible(
            key: Key(anime.malId.toString()),
            direction: DismissDirection.horizontal,
            background: Container(
              color: Colors.red.shade700,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red.shade700,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                anime.isFavorite = false;
              });
              _showSnackBar('Usunięto z ulubionych');
            },
            child: Card(
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
            ),
          );
        },
      ),
    );
  }
}