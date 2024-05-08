class SongModel {
  String id;
  String title;
  String author;
  String url;
  int duration;

  SongModel({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.duration,
  });

  @override
  String toString() {
    return 'SongModel{id: $id, title: $title, author: $author, url: $url, duration: $duration}';
  }
}
