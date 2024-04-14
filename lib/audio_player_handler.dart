import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:verve/main.dart';
import 'package:verve/services/download_video.dart';
import 'package:verve/services/play_audio.dart';

var hplaylist ;
var strack;
List<bool> showCard = [false,false];
String playback  = 'linear';

/// An [AudioHandler] for playing a single item.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler, ChangeNotifier {
  //ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: [], useLazyPreparation: true);
  //late List<int> preferredCompactNotificationButton = [1, 2, 3];
  late var playlist ;
  late String playbac;
  late StreamSubscription<Duration> subscription;


  Map<String, bool> playmap = {
    "showCard": false,
    "songPlay": false,
  };


  final _player = AudioPlayer();

  //int strack = 0;

  //String playmode = '';


  /// Initialise our audio handler.
  AudioPlayerHandler() {
     playbac = playback;
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    //mediaItem.add(_item);


    // Load the player.
    //_player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
  }

  Future<void> initializeAudioPlayer(String filePath) async {
    playbac = "repeat";
    //playback = 'repeat';
    _player.setFilePath(filePath);
    //player.setSource(DeviceFileSource(filePath));
    notifyListeners();
  }

  Future<void> initializePlaylistAudioPlayer(rplaylist, int index, List path_dur, int check, String pmode) async {
    playbac = pmode;
    print("playback: $playbac");
    strack = index;
    playlist = rplaylist;
    String? color = await updateCardColor(playlist[index].url);
    print(rplaylist[index].title);

    MediaItem item = MediaItem(
        id: path_dur[0].toString(),
        album: rplaylist[index].author,
        title: rplaylist[index].title,
        artist: playlist[index].author,
        duration: Duration(seconds: path_dur[1].toInt()),
        artUri: Uri.parse(playlist[index].url),
        genre: color,
        playable: true,
        extras: playmap = {
          "showCard": true,
          "songPlay": true,
        }
    );
    audioHandler.updateMediaItem(item);
    audioHandler.play();
    notifyListeners();
  }

    Future<String?> updateCardColor(url) async {
    final box = await Hive.openBox('retain');
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(url));
    String color = paletteGenerator.dominantColor!.color.toString();
    box.put('color', paletteGenerator.dominantColor!.color.toString());
    return color;

  }

  Future<void> loadNextFromPlaylist(int index,String mode) async {
    print("Loading next from playlist, the mode is: $playbac");

    switch(mode){

      case 'linear':
        print("Current mode: linear");
        index = index + 1;
        List path_dur = await DownloadVideo().downloadVideo(hplaylist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration
        print("playing next: ${hplaylist[index]['songTitle'].toString()}");
        print("current index: $index");
        await AudioPlayerHandler().initializePlaylistAudioPlayer(hplaylist,index,path_dur, 1,playbac);
        notifyListeners();
        break;

      case 'shuffle':
        print("Current mode: shuffle");
        index = getRandomNumber(0, hplaylist.length);
        List path_dur = await DownloadVideo().downloadVideo(hplaylist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration
        await initializePlaylistAudioPlayer(hplaylist,index,path_dur, 1,playbac);
        notifyListeners();
        break;

      case 'repeat':
        print("Current mode: repeat");
        List path_dur = await DownloadVideo().downloadVideo(hplaylist[index]['vId'].toString());  // Download the audio file, return a list with file location and duration
        initializePlaylistAudioPlayer(hplaylist,index,path_dur,1,playbac);
        notifyListeners();
        break;

      case '':
        print("Current mode: none");
        await _player.seek(Duration(seconds: 0));
        await _player.play();
        break;
    }
  }

  getRandomNumber(int min, int max) {
    Random random = Random();
    // Generate a random number within the specified range
    int randomNumber = min + random.nextInt(max - min + 1);
    return randomNumber;
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() async {
    _player.play();
    playmap = {
      "songPlay": true};
    //playButtonOn=true;
  }

  @override
  Future<void> pause()async {
    _player.pause();
    playmap = {
      "songPlay": false};
    //playButtonOn=false;
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();



  @override
  Future<void> updateMediaItem(MediaItem myItem) async {
    // TODO: implement updateMediaItem
    mediaItem.add(myItem);
    _player.setAudioSource(AudioSource.file(myItem.id));
    //_player.play();
    playerTracker(myItem);
    //_player.setAudioSource(AudioSource.uri(Uri.parse(myItem.id)));
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  void playerTracker(MediaItem myItem) {
    subscription = _player.positionStream.listen((event) async {
      if(event.inSeconds == myItem.duration?.inSeconds){
        await stopListeningToPositionStream();
        await AudioPlayerHandler().loadNextFromPlaylist(strack,playback);
      }
    });
  }

  Future<void> stopListeningToPositionStream() async {
    print("unsubscribed!!!");
    await subscription.cancel();
  }
}