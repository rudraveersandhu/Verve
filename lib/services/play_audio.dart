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

import 'dart:async';
import 'dart:math';
//import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'download_video.dart';

class PlayAudio with ChangeNotifier {
  final Function(String, String, String, String, List, String ) updateCard;

  late StreamController<int> _positionController;
  Stream<int> get positionStream => _positionController.stream;

  AudioPlayer player = AudioPlayer();
  String tracker = '';
  int strack = 0;
  String playlistName = '' ;
  late int dur;
  late String loc;
  late var playlist ;
  String mode='';
  late var dur_in_hours;
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";

  Duration currentPosition = Duration.zero;

  PlayAudio({required this.updateCard}) {
    _positionController = StreamController<int>.broadcast();
      player.positionStream.listen((Duration p) {
        currentpos = p.inSeconds;
        _positionController.add(currentpos);

      });
  }

  Future<void> initializeAudioPlayer(String filePath) async {
    tracker = "single";
    loc = filePath;
    player.setFilePath(filePath);
    //player.setSource(DeviceFileSource(filePath));
    notifyListeners();
  }

  Future<void> initializePlaylistAudioPlayer(rplaylist, int index, List path_dur, int check, String pmode) async {

    if (check == 0 && pmode == ''){
      mode = 'linear';
      print("- Mode set to linear");
    }
    tracker = 'playlist';
    print("- Tracker set to playlist");
    playlist = rplaylist;
    strack = index;
    String audpath = path_dur[0];
    loc = audpath;

    player.setFilePath(audpath);
    //player.setSource(DeviceFileSource(audpath));
    //await audioPlayer.setSourceDeviceFile(audpath);
    notifyListeners();
  }

  Future<void> loadNextFromPlaylist(int index,playlistDetails, String mode) async {
    print("Loading next from playlist, the mode is: $mode");

    // Linear mode
    if(mode == 'linear'){
      index = index + 1;
      List path_dur = await DownloadVideo().downloadVideo(playlist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration
      await updateCard(playlist[index]['tUrl'].toString(),
          'playlist',
          playlist[index]['songTitle'].toString(),
          playlist[index]['songAuthor'].toString(),
          path_dur,
          playlist[index]['vId'].toString()
      );
      notifyListeners();
      await initializePlaylistAudioPlayer(playlistDetails,index,path_dur, 1,mode);
      await playAudio();
    }
    // Shuffle mode
    else if (mode == 'shuffle'){
      index = getRandomNumber(0, playlistDetails.length);
      List path_dur = await DownloadVideo().downloadVideo(playlist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration
      await updateCard(playlist[index]['tUrl'].toString(),
          'playlist',
          playlist[index]['songTitle'].toString(),
          playlist[index]['songAuthor'].toString(),
          path_dur,
          playlist[index]['vId'].toString());
      notifyListeners();
      await initializePlaylistAudioPlayer(playlistDetails,index,path_dur, 1,mode);
      await playAudio();

    }
    // None
    else if(mode == 'none'){
      player.seek(Duration(seconds: 0));
      player.play();
    }
    // Repeat mode
    else if (mode == 'repeat'){
      List path_dur = await DownloadVideo().downloadVideo(playlist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration
      await updateCard(playlist[index]['tUrl'].toString(),
          'playlist',
          playlist[index]['songTitle'].toString(),
          playlist[index]['songAuthor'].toString(),
          path_dur,
          playlist[index]['vId'].toString());
      notifyListeners();
      initializePlaylistAudioPlayer(playlistDetails,index,path_dur,1,mode);
      playAudio();
    }
    //Future<List<Map<String,Object>>> playlist = accessPlaylist(playlistName);
  }

  getRandomNumber(int min, int max) {
    Random random = Random();
    // Generate a random number within the specified range
    int randomNumber = min + random.nextInt(max - min + 1);
    return randomNumber;
  }


  int getCurrentPosition() {
    //return player.position.inSeconds;
    return 5;

  }

  Future<void> playAudio() async {
    //getDuration();
    await player.play();
    //await audioPlayer.play(AssetSource(loc));
    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await player.pause();
    notifyListeners();

  }

  Future<void> seekAudio(int position) async {
    await player.seek(Duration(seconds: position));
    notifyListeners();
  }

  Future<void> stopAudio() async {
    await player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    player.dispose();
    _positionController.close();
    super.dispose();
  }
}