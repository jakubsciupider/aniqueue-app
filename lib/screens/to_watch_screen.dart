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
  // metoda wyswielatjaca snackbar
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
                anime.isToWatch = false;
              });
              _showSnackBar('Usunięto z planowanych');
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