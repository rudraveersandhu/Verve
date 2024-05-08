import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/material.dart'; // Import BuildContext
import '../models/playlists.dart';
import '../utilities/playlist_provider.dart';

class YouTubeService {
  final BuildContext context;
  YouTubeService(this.context);
  final YoutubeExplode _youtube = YoutubeExplode();
   // Add context field

  Future<List<String>> fetchPlaylistItems(String playlistId, BuildContext context) async {
    List<String> playlistItems = [];
    var playlist                = await _youtube.playlists.get(playlistId);
    String playlist_name        = playlist.title;
    String playlist_description = playlist.description;
    String playlist_author      = playlist.author;
    int?   playlist_length      = playlist.videoCount;
    String playlist_id          = playlist.id.toString();


    //for (var playlistId in playlistIds) {  //playlistIds must be present in the parameter
    //  var playlist                = await _youtube.playlists.get(playlistId);
    //  String playlist_name        = playlist.title;
    //  String playlist_description = playlist.description;
    //  String playlist_author      = playlist.author;
    //  int?   playlist_length      = playlist.videoCount;
    //  String playlist_id          = playlist.id.toString();

      await for (var video in _youtube.playlists.getVideos(playlistId)) {
        await addToPlaylist(
            context,
            playlist_id,
            playlist_name,
            playlist_description,
            playlist_author,
            playlist_length!,
            video.title,
            video.author,
            video.thumbnails.mediumResUrl,
            '',
            video.id.toString(),
            video.thumbnails.mediumResUrl,
            video.duration!.inSeconds);
        String playlist_song = "${video.id}|${video.title}|${video.author}|${video.description}|${video.thumbnails.mediumResUrl}|${video.duration}";
        playlistItems.add(playlist_song);
      }
    //}
    return playlistItems;
  }

  void close() {
    _youtube.close();
  }

}

Future<void> addToPlaylist(
    BuildContext context,
    String playlistId,
    String playlistName,
    String playlistDescription,
    String playlistAuthor,
    int playlistLength,
    String songTitle,
    String artist,
    String thumb,
    String audPath,
    String vId ,
    String tempUrl,
    int dur) async {
      //var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
      //final nav = Provider.of<Playlists>(context, listen: false);

       final box = await Hive.openBox('playlists');
      List<dynamic> storedPlaylists = await box.get('playlists', defaultValue: []);


      var mySongsPlaylist = storedPlaylists.firstWhere((playlist) => playlist['id'] == playlistId,
        orElse: () => {'name': playlistName, 'songs': []},
      );

      List<dynamic> songs = mySongsPlaylist['songs'];
      int songsLength = mySongsPlaylist['NumOfSongs'];

      bool isSongAlreadyPresent = songs.any((song) => song['vId'] == vId );

      if (isSongAlreadyPresent) {
        print('Song is already present in $playlistName playlist.');
      } else {
        songs.add({
          'songTitle': songTitle,
          'songAuthor': artist,
          'tUrl': thumb,
          'vId': vId,
          'audPath': audPath,
          'thumbnail': thumb,
          'duration': dur,
        });
        await box.put('playlists', storedPlaylists);
        }
}
