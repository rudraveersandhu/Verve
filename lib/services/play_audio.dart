// *
// * This file is an essential component of Verve, a free music playing app.

// * Verve is an open-source software project, released under the terms
// * of the GNU Lesser General Public License (GPL), version 3 or any later version.


// * The primary mission of Verve is to provide an accessible platform for
// * free music enjoyment for all users. By redistributing or modifying this software,
// * you are agreeing to the terms specified in the GPL.


// * Verve is distributed with the aspiration to contribute to the musical
// * experience of users worldwide. However, it comes with no warranty, either
// * implied or expressed,regarding its merchantability or fitness for a specific purpose.

// * For detailed information, refer to the GNU Lesser General Public License. If you did
// * not receive a copy of the GNU Lesser General Public License along with Verve, please
// * visit <http://www.gnu.org/licenses/>.

// * Copyright (c) 2023-2024, Rudraveer Singh Sandhu
// * Project Git: https://github.com/rudraveersandhu/Verve
// *

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';

class PlayAudio with ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();

  PlayAudio() {
    audioPlayer.playerStateStream.listen((playerState) {
      print('Player state changed: $playerState');
      print('Duration: ${getDuration()} seconds');
      print('Current Position: ${getCurrentPosition()} seconds');
      // Check for the condition to reset position
      if (playerState.playing &&
          playerState.processingState == ProcessingState.completed) {
        print('Resetting player position to initial');
        audioPlayer.seek(Duration(seconds: 0));
        playAudio();
      }
    });
  }

  Future<void> initializeAudioPlayer(String filePath, String mode) async {

    if(mode == 'stream'){
      await audioPlayer.setUrl(filePath);
      notifyListeners();

    } else if(mode == 'downloaded') {
      await audioPlayer.setFilePath(filePath);
      notifyListeners();
    }
  }

  int getDuration() {
    return audioPlayer.duration?.inSeconds ?? 0;
  }

  int getCurrentPosition() {
    return audioPlayer.position.inSeconds;
  }

  Future<void> playAudio() async {
    //getDuration();
    await audioPlayer.play();
    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<List<Map<String, Object>>> accessPlaylist(
      String targetPlaylistName) async {
    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var targetPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == targetPlaylistName,
      orElse: () => <String, Object>{},
    );

    box.put('about', targetPlaylist['about']);

    if (targetPlaylist != null) {
      List<dynamic> songs = targetPlaylist['songs'];
      List<Map<String, Object>> playlistDetails = [];

      for (var song in songs) {
        String songTitle = song['songTitle'].toString();
        String songAuthor = song['songAuthor'].toString();
        String tUrl = song['tUrl'].toString();
        String vId = song['vId'].toString();

        playlistDetails.add({
          'songTitle': songTitle,
          'songAuthor': songAuthor,
          'tUrl': tUrl,
          'vId': vId,
          'thumbnail': ""
        });
      }

      return playlistDetails;
    } else {
      print('Playlist not found: $targetPlaylistName');
      return [];
    }
  }
}


