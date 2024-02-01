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

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'download_video.dart';

class PlayAudio with ChangeNotifier {

  final Function(String, String, String, String, List  ) updateCard;

  final AudioPlayer audioPlayer = AudioPlayer();
  String tracker = '';
  int strack = 0;
  String playlistName = '' ;
  late int dur;
  late var playlist ;
  String mode='';

  PlayAudio({required this.updateCard}) {
    audioPlayer.playerStateStream.listen((playerState) {
      //print('Player state changed: $playerState');
      //print('Duration: ${getDuration()} seconds');
      //print('Current Position: ${getCurrentPosition()} seconds');
      //print("Tracker: $tracker");
      //print("Index: $strack");

      // Check for the condition to reset position
      if (tracker == 'single' &&  playerState.playing && playerState.processingState == ProcessingState.completed ) {
          print('Resetting player position to initial');
          audioPlayer.seek(Duration(seconds: 0));
          playAudio();
      }
      if (playerState.playing && playerState.processingState == ProcessingState.completed && tracker == 'playlist' ){
        print("hogaya khatam bsdk");
        print("current mode : $mode");
        stopAudio();
        //audioPlayer.seek(Duration(seconds: 0));
        loadNextFromPlaylist(strack, playlist, mode);
        //initializePlaylistAudioPlayer(playlist, strack+1,[]);
      }
    });
  }

  Future<int> getDuration() async {
    return audioPlayer.duration?.inSeconds ?? 0;
  }

  Future<void> initializeAudioPlayer(String filePath) async {
    await audioPlayer.setFilePath(filePath);
    notifyListeners();
  }

  Future<void> initializePlaylistAudioPlayer(rplaylist, int index, List path_dur, int check, String pmode) async {
    if (check == 0 && pmode == ''){
      mode = 'linear';
    }
    tracker = 'playlist';
    playlist = rplaylist;
    strack = index;
    //print(index);
    //print(rplaylist[index]['songTitle']);
    String audpath = path_dur[0];
    //print(audpath);
    await audioPlayer.setFilePath(audpath);
    notifyListeners();
  }

  Future<void> loadNextFromPlaylist(int index,playlistDetails, String mode) async {

    // Linear mode
    if(mode == 'linear'){
      index = index + 1;
      List path_dur = await DownloadVideo().downloadVideo(playlist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration

      await updateCard(playlist[index]['tUrl'].toString(),
          'playlist',
          playlist[index]['songTitle'].toString(),
          playlist[index]['songAuthor'].toString(),
          path_dur
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
          path_dur);
      notifyListeners();
      await initializePlaylistAudioPlayer(playlistDetails,index,path_dur, 1,mode);
      await playAudio();

    }
    // None
    else if(mode == 'none'){
      audioPlayer.seek(Duration(seconds: 0));
    }
    // Repeat mode
    else if (mode == 'repeat'){
      List path_dur = await DownloadVideo().downloadVideo(playlist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration
      await updateCard(playlist[index]['tUrl'].toString(),
          'playlist',
          playlist[index]['songTitle'].toString(),
          playlist[index]['songAuthor'].toString(),
          path_dur);
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
    return audioPlayer.position.inSeconds;

  }

  Future<void> playAudio() async {
    getDuration();
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
}