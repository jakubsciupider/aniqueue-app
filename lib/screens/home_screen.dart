import 'package:flutter/material.dart';
import '../models/anime_item.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';
import 'to_watch_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // oblsluga stanu ladowania
  bool _isLoading = false;

  // glowna lista obiektow AnimeItem
  final List<AnimeItem> _allAnime = [];

  // inicjalizacja stanu
  @override
  void initState() {
    super.initState();
    _fetchAnimeData();
  }

  // metoda pod wyswietlanie snackBara
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // fetchowanie mockowych danych, na razie bez uzycia API
  void _fetchAnimeData() {
    setState(() {
      _isLoading = true;
    });

    // future funckja do testu wyswietlania ladowania danych
    Future.delayed(const Duration(milliseconds: 500), () {
      // mockowe anime whatever na razie
      final mockData = [
        AnimeItem(
          malId: 5114,
          title: "Fullmetal Alchemist: Brotherhood",
          imageUrl: "https://cdn.myanimelist.net/images/anime/1208/94745.jpg",
          score: 9.10,
          synopsis: "Two brothers search for the Philosopher's Stone to restore their bodies.",
        ),
        AnimeItem(
          malId: 9253,
          title: "Steins;Gate",
          imageUrl: "https://cdn.myanimelist.net/images/anime/1935/127974.jpg",
          score: 9.07,
          synopsis: "A self-proclaimed mad scientist discovers time travel via a microwave.",
        ),
        AnimeItem(
          malId: 21,
          title: "One Piece",
          imageUrl: "https://cdn.myanimelist.net/images/anime/1244/138851.jpg",
          score: 8.75,
          synopsis: "Monkey D. Luffy seeks the ultimate treasure to become the Pirate King.",
        ),
        AnimeItem(
          malId: 52991,
          title: "Frieren: Beyond Journey's End",
          imageUrl: "https://cdn.myanimelist.net/images/anime/1015/138006.jpg",
          score: 9.39,
          synopsis: "An elf mage and her former party members' journeys after defeating the Demon King.",
        ),
      ];

      // zmiana stanu
      setState(() {
        _allAnime.clear();
        _allAnime.addAll(mockData);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AniQueue'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        // przyciski w AppBarze
        actions: [
          // przyciski przejscia do pozostalych ekranow
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(allAnime: _allAnime),
                ),
              ).then((_) => setState(() {})); // odswiezenie stanu po powrocie
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToWatchScreen(allAnime: _allAnime),
                ),
              ).then((_) => setState(() {})); // odswiezenie stanu po powrocie
            },
          ),

          // przycisk ten bedzie odswiezal zawartosc/zapytanie do API
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnimeData,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green.shade700))
          : _allAnime.isEmpty
          ? const Center(child: Text('Brak danych'))
          : ListView.builder(
        itemCount: _allAnime.length,
        itemBuilder: (context, index) {
          final anime = _allAnime[index];
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

                  // errorBuilder wyswietli ikonke jezeli wystapi blad
                  // przy wyszukiwaniu danego zdjecia na MALu
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.movie, color: Colors.green),
                ),
              ),
              title: Text(anime.title),
              subtitle: Text('Ocena: ${anime.score}'),
              onTap: () {
                // navigator przekierowywuje do page ze szczegolami
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