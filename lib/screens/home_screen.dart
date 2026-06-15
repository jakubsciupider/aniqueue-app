import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/anime_item.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';
import 'to_watch_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  // string przechowujacy komunikat bledu jezeli api padnie
  String _errorMessage = '';

  // aktualny indeks dolnego paska nawigacji
  int _currentIndex = 0;

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

  // funkcja zapisujaca aktualny stan listy do lokalnego boxa hive
  void _saveToHive() {
    final box = Hive.box('aniqueue_box');
    final List<Map<String, dynamic>> mappedData = _allAnime.map((anime) => anime.toMap()).toList();
    box.put('cached_anime_list', mappedData);
  }

  // fetchowanie danych z obsluga trybu offline i bledow
  Future<void> _fetchAnimeData() async {
    setState(() {
      _isLoading = true;

      // czyszczenie poprzednich bledow
      _errorMessage = '';
    });

    final box = Hive.box('aniqueue_box');

    try {
      // zapytanie rest do api o 25 najpopularniejszych anime
      final url = Uri.parse('https://api.jikan.moe/v4/top/anime?limit=25');
      final response = await http.get(url);

      // print('Status: ${response.statusCode}, body: ${response.body}');

      // kod odpowiedzi HTTP
      if (response.statusCode == 429) {
        _loadOfflineData(box);
        _showSnackBar('Serwer jest zajęty.');
        return;
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData == null || jsonData['data'] == null) {
          _loadOfflineData(box);
          _showSnackBar('API zwróciło pustą strukturę. Spróbuj za chwilę.');
          return;
        }

        final List<dynamic> dataList = jsonData['data'];

        final List<AnimeItem> fetchedAnime = dataList.map((item) {
          int id = item['mal_id'];

          final List<dynamic>? cachedList = box.get('cached_anime_list');
          bool localFavorite = false;
          bool localToWatch = false;
          bool localWatched = false;

          if (cachedList != null) {
            for (var cachedItem in cachedList) {
              if (cachedItem is Map && cachedItem['malId'] == id) {
                localFavorite = cachedItem['isFavorite'] ?? false;
                localToWatch = cachedItem['isToWatch'] ?? false;
                localWatched = cachedItem['isWatched'] ?? false;
                break;
              }
            }
          }

          return AnimeItem(
            malId: id,
            title: item['title'] ?? 'Brak tytułu',
            imageUrl: item['images']['jpg']['large_image_url'] ?? '',
            score: (item['score'] as num?)?.toDouble() ?? 0.0,
            synopsis: item['synopsis'] ?? 'Brak opisu fabuły.',
            isFavorite: localFavorite,
            isToWatch: localToWatch,
            isWatched: localWatched,
          );
        }).toList();

        setState(() {
          _allAnime.clear();
          _allAnime.addAll(fetchedAnime);
        });

        // nadpisujemy lokalny cache swiezymi danymi
        _saveToHive();
      } else {
        throw Exception('Serwer zwrócił błąd: ${response.statusCode}');
      }
    } catch (error) {
      // bezpieczne lapanie wyjatkow braku internetu i ladowanie z lokalnego hive
      final List<dynamic>? cachedList = box.get('cached_anime_list');

      if (cachedList != null && cachedList.isNotEmpty) {
        try {
          final List<AnimeItem> offlineAnime = cachedList.map((item) => AnimeItem.fromMap(Map<String, dynamic>.from(item))).toList();
          setState(() {
            _allAnime.clear();
            _allAnime.addAll(offlineAnime);
          });
          _showSnackBar('Załadowano dane offline.');
        } catch (e) {
          setState(() {
            _errorMessage = 'Błąd struktury pamięci lokalnej. Odśwież ponownie.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Brak połączenia z internetem/brak danych lokalnych\n(Serwer zwrócił: $error)';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // metoda do ladowania danych z pamieci hive
  void _loadOfflineData(Box box) {
    final List<dynamic>? cachedList = box.get('cached_anime_list');

    if (cachedList != null && cachedList.isNotEmpty) {
      try {
        final List<AnimeItem> offlineAnime = cachedList.map((item) => AnimeItem.fromMap(Map<String, dynamic>.from(item))).toList();
        setState(() {
          _allAnime.clear();
          _allAnime.addAll(offlineAnime);
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Błąd parsowania bazy lokalnej';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Brak połączenia z internetem/brak danych lokalnych';
      });
    }
  }

  // metoda zwracajaca glowna zawartosc listy home
  Widget _buildHomeBody() {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.green.shade700))
        : _errorMessage.isNotEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          _errorMessage,
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    )
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
          child: InkWell(
            onTap: () {
              // Prosty, klasyczny Navigator.push
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(anime: anime),
                ),
              ).then((_) {
                _saveToHive();
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
                  child: CachedNetworkImage(
                    imageUrl: anime.imageUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 100,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // sterowanie wyswietlanym body na podstawie currentIndex
    final List<Widget> screens = [
      _buildHomeBody(),
      FavoritesScreen(allAnime: _allAnime),
      ToWatchScreen(allAnime: _allAnime),
    ];

    // tytuly dla aplikacji w zaleznosci od ekranu
    final List<String> titles = [
      'AniQueue',
      'Ulubione',
      'Do obejrzenia',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          // przycisk ten bedzie odswiezal zawartosc/zapytanie do API tylko na ekranie glownym
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchAnimeData,
            )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // zapisujemy zmiany przy kazdej zmianie zakladki dla pewnosci danych
          _saveToHive();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Ulubione',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Do obejrzenia',
          ),
        ],
      ),
    );
  }
}