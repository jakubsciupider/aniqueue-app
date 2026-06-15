class AnimeItem {
  final int malId;
  final String title;
  final String imageUrl;
  final double score;
  final String synopsis;
  bool isWatched;
  bool isFavorite;
  bool isToWatch;

  AnimeItem({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.score,
    required this.synopsis,

    // domyslne wartosci
    this.isWatched = false,
    this.isFavorite = false,
    this.isToWatch = false,
  });

  // mapowanie obiektu pod zapis w hive boxie
  Map<String, dynamic> toMap() {
    return {
      'malId': malId,
      'title': title,
      'imageUrl': imageUrl,
      'score': score,
      'synopsis': synopsis,
      'isWatched': isWatched,
      'isFavorite': isFavorite,
      'isToWatch': isToWatch,
    };
  }

  // tworzenie obiektu z mapy pobranej z lokalnej bazy lub api
  factory AnimeItem.fromMap(Map<dynamic, dynamic> map) {
    return AnimeItem(
      malId: map['malId'] ?? 0,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      synopsis: map['synopsis'] ?? '',
      isWatched: map['isWatched'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
      isToWatch: map['isToWatch'] ?? false,
    );
  }
}