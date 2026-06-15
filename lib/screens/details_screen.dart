import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/anime_item.dart';

class DetailsScreen extends StatefulWidget {
  final AnimeItem anime;

  const DetailsScreen({super.key, required this.anime});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // obsluga stanu ladowania z api
  bool _isDetailsLoading = false;
  String _synopsisText = '';

  // dodatkowe info
  // ilosc odcinkow moze byc null
  int? _episodes;
  String _type = '';
  String _status = '';

  // rok wydania tez moze byc null
  int? _year;

  @override
  void initState() {
    super.initState();

    _loadCachedSynopsis();
    _fetchFullDetails();
  }

  // metoda do ladowania opisu i szczegolow z cachea
  void _loadCachedSynopsis() {
    final box = Hive.box('aniqueue_box');
    final List<dynamic>? cachedList = box.get('cached_anime_list');
    if (cachedList != null) {
      for (var item in cachedList) {
        if (item['malId'] == widget.anime.malId) {
          final String? cachedSynopsis = item['synopsis'];

          if (cachedSynopsis != null && cachedSynopsis.isNotEmpty) {
            _synopsisText = cachedSynopsis;
          }

          _episodes = item['episodes'];
          _type = item['type'] ?? '';
          _status = item['status'] ?? '';
          _year = item['year'];

          if (cachedSynopsis != null && cachedSynopsis.isNotEmpty) return;
        }
      }
    }

    // domyslny opis z listy jako fallback
    _synopsisText = widget.anime.synopsis;
  }

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

  // funkcja zapisujaca stan po modyfikacjach flag
  // przez uzytkownika
  void _saveCurrentState() {
    final box = Hive.box('aniqueue_box');
    final List<dynamic>? cachedList = box.get('cached_anime_list');
    if (cachedList != null) {
      final List<Map<String, dynamic>> updatedList = cachedList.map((item) {
        if (item['malId'] == widget.anime.malId) {
          final updatedAnimeMap = widget.anime.toMap();

          updatedAnimeMap['synopsis'] = _synopsisText;
          updatedAnimeMap['episodes'] = _episodes;
          updatedAnimeMap['type'] = _type;
          updatedAnimeMap['status'] = _status;
          updatedAnimeMap['year'] = _year;

          return updatedAnimeMap;
        }
        return Map<String, dynamic>.from(item);
      }).toList();
      box.put('cached_anime_list', updatedList);
    }
  }

  // drugie zapytanie rest pobierajace szczegoly
  // danego anime
  Future<void> _fetchFullDetails() async {
    setState(() {
      _isDetailsLoading = true;
    });

    try {
      final url = Uri.parse('https://api.jikan.moe/v4/anime/${widget.anime.malId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];
        final fullSynopsis = data['synopsis'];

        setState(() {
          if (fullSynopsis != null) {
            _synopsisText = fullSynopsis;
          }
          _episodes = data['episodes'];
          _type = data['type'] ?? 'Nieznany';
          _status = data['status'] ?? 'Nieznany';
          _year = data['year'];
        });

        _saveCurrentState();
      } else if (response.statusCode == 429) {
        _showSnackBar('Serwer jest zajęty.');
      } else {
        throw Exception();
      }
    } catch (e) {
      _showSnackBar('Nie udało się połączyć z API - tryb offline.');
    } finally {
      setState(() {
        _isDetailsLoading = false;
      });
    }
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
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    width: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.movie, size: 100, color: Colors.grey),
                  ),
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
                        _saveCurrentState();
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
                        _saveCurrentState();
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
            const SizedBox(height: 12),
            // Nowa sekcja z dodatkowymi szczegolami
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                if (_type.isNotEmpty)
                  Chip(
                    label: Text('Typ: $_type'),
                    backgroundColor: Colors.grey.shade100,
                  ),
                if (_episodes != null)
                  Chip(
                    label: Text('Odcinki: $_episodes'),
                    backgroundColor: Colors.grey.shade100,
                  ),
                if (_year != null)
                  Chip(
                    label: Text('Rok: $_year'),
                    backgroundColor: Colors.grey.shade100,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Opis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isDetailsLoading && _synopsisText.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : Text(
              _synopsisText,
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