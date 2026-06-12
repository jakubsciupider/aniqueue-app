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
}