class PlaylistModel {
  String id;
  String title;
  String author;
  String url;

  PlaylistModel({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
  });

  @override
  String toString() {
    return 'PlaylistModel{id: $id, title: $title, author: $author, url: $url}';
  }
}
