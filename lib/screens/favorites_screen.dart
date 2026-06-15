import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

  // funkcja zapisujaca zmiany w liscie do lokalnego hive
  void _saveChangesToHive() {
    final box = Hive.box('aniqueue_box');
    final List<Map<String, dynamic>> mappedData = widget.allAnime.map((anime) => anime.toMap()).toList();
    box.put('cached_anime_list', mappedData);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesList = widget.allAnime.where((anime) => anime.isFavorite).toList();

    return favoritesList.isEmpty
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
            _saveChangesToHive(); // zapis stanu dismissible w hive lokalnym
            _showSnackBar('Usunięto z ulubionych');
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(anime: anime),
                  ),
                ).then((_) {
                  _saveChangesToHive();
                  setState(() {});
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Image.network(
                      anime.imageUrl,
                      width: 70,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.movie, color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anime.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'Ocena: ${anime.score}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}