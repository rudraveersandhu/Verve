// *
// * This file is an essential component of Verve, a free music playing app.
// *
// * Verve is an open-source software project, released under the terms
// * of the GNU Lesser General Public License (GPL), version 3 or any later version.
// *
// * The primary mission of Verve is to provide an accessible platform for
// * free music enjoyment for all users. By redistributing or modifying this software,
// * you are agreeing to the terms specified in the GPL.
// *
// * Verve is distributed with the aspiration to contribute to the musical
// * experience of users worldwide. However, it comes with no warranty, either
// * implied or expressed,regarding its merchantability or fitness for a specific purpose.
// *
// * For detailed information, refer to the GNU Lesser General Public License. If you did
// * not receive a copy of the GNU Lesser General Public License along with Verve, please
// * visit <http://www.gnu.org/licenses/>.
// *
// * Copyright (c) 2023-2024, Rudraveer Singh Sandhu
// * Project Git: https://github.com/rudraveersandhu/Verve
// *

import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../models/playlists.dart';
import '../models/bottom_player.dart';
import '../services/play_audio.dart';
import '../utilities/playlist_provider.dart';

class Player extends StatefulWidget {
  final Color color;
  const Player({Key? key, required this.color}) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin{
  bool isPlaylistSelectorVisible = false;

  bool linear = false;
  bool shuffle = false;
  bool repeat = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  double _sliderValue = 0.0;

  String formatSecondsToTime(int seconds) {
    int hours = seconds ~/ 3600;
    int remainingMinutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String formattedTime =
        '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 0.0,end: 1.0).animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BottomPlayerModel>();
    final audio = Provider.of<PlayAudio>(context);
    //final ABmodel = context.read<AlbumModel>();
    _controller.forward();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Text('Now playing',
              style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: PopupMenuButton(
              icon: Icon(Icons.more_horiz, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Option 1'),
                  value: 'option1',
                ),
                PopupMenuItem(
                  child: Text('Option 2'),
                  value: 'option2',
                ),
                // Add more items as needed
              ],
              onSelected: (value) {
                // Handle the selected option
                print('Selected: $value');
              },
            ),
          ),
        ],
      ),
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [model.cardBackgroundColor, Colors.black],
            ),
          ),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140,
              ),
              Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    width: 330.0,
                    height: 330.0,
                    decoration: BoxDecoration(

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          spreadRadius: 25,
                          blurRadius: 85,
                          offset: Offset(22, 22),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: PhotoView(
                        imageProvider: CachedNetworkImageProvider(
                          cacheManager: CacheManager(
                            Config(
                              'verve',
                              stalePeriod: Duration(days: 7),
                            ),
                          ),
                          model.tUrl,
                        ),
                        customSize: Size(590, 590),
                        enableRotation: true,
                        gaplessPlayback: true,
                        backgroundDecoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 50, left: 50),
                  child: Text(
                    model.currentTitle,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white.withAlpha(980),
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  model.currentAuthor,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height:5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                        onTap: () {
                          print("adding to playlist: My Songs \n Item details: \n 1) Title : ${model.currentTitle} \n 2) Author: ${model.currentAuthor} \n 3) Filepath: ${model.filePath} \n 4) TUrl: ${model.tUrl} \n 5) Duration: ${model.currentDuration} \n 6) VID: ${model.vId}");
                          addToPlaylist(
                              "My Songs",
                              model.currentTitle,
                              model.currentAuthor,
                              model.tUrl,
                              model.filePath,
                              model.tUrl,
                              model.vId,
                              model.currentDuration);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Added to "My Songs" successfully !',style: TextStyle(
                                      fontSize: 12
                                  ),),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          showPlaylistSelector();
                                        });
                                      },
                                      child: Container(
                                          width: 50,
                                          child: Text('Change',overflow: TextOverflow.ellipsis,style: TextStyle(
                                              fontSize: 12
                                          ),))),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: Colors.orange.withAlpha(
                                  900),
                              duration: Duration(
                                  seconds:
                                  1),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.playlist_add,
                          color: Colors.white70,
                          size: 35,
                        )
                    ),
                  ),
                ],
              ),
              StreamBuilder<int>(
                stream: audio.positionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Slider(value: 0.0, onChanged: (double value) {  },thumbColor: Colors.transparent,); // Display a loading indicator
                  } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Display an error message
                  } else if (snapshot.hasData && snapshot.data!.toDouble() <= model.currentDuration.toDouble()){
                  // Data snapshot is ready
                    _sliderValue = snapshot.data!.toDouble(); // Update slider value based on stream data
                  } else {
                    _sliderValue = 0.0;
                  }

                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      activeTrackColor: Colors.white,
                      thumbShape: SliderComponentShape.noThumb,
                      inactiveTrackColor: model.cardBackgroundColor.withRed(model.cardBackgroundColor.red +20).withBlue(model.cardBackgroundColor.blue +20).withGreen(model.cardBackgroundColor.blue + 20),
                    ),
                    child: Slider(
                      value: _sliderValue <= model.currentDuration.toDouble() ? _sliderValue : 0,
                      min: 0,
                      max: model.currentDuration.toDouble(),
                      onChanged: (value)  {
                        if(value < model.currentDuration.toDouble()){
                          setState(() {
                            _sliderValue = value;
                            audio.seekAudio(value.toInt());
                          });
                        }
                      },
                    ),
                  );
                }
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<int>(
                        stream: audio.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.toDouble() <= model.currentDuration.toDouble()) {
                            _sliderValue = snapshot.data!.toDouble(); // Update slider value based on stream data
                          }
                          return Text(
                            "${formatSecondsToTime(_sliderValue.toInt())}",
                            style: TextStyle(
                                color: Colors.grey, fontWeight: FontWeight.w500),
                          );
                        }
                      ),
                      Text(
                        "${formatSecondsToTime(model.currentDuration)}",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){

                    },
                    child: Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 60,
                    ),
                  ),
                  model.playButtonOn
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              model.playButtonOn = false;
                            });
                            audio.pauseAudio();
                          },
                          child: Icon(
                            Icons.pause_circle_filled_rounded,
                            color: Colors.white.withOpacity(.85),
                            size: 80,
                          ))
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              model.playButtonOn = true;
                            });
                            audio.playAudio();
                          },
                          child: Icon(
                            Icons.play_circle_filled_rounded,
                            color: Colors.white.withOpacity(.85),
                            size: 80,
                          ),
                        ),
                  GestureDetector(
                    onTap: (){

                    },
                    child: Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 60,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<PlayAudio>(
                      builder:((context, playmodeModel, child)=>
                      playmodeModel.mode == "linear" ? GestureDetector(
                          onTap: () {
                            //final ABmodel = Provider.of<AlbumModel>(context, listen: false);
                            setState(() {
                              linear = false;
                              playmodeModel.mode = 'none';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 22,
                                  offset: Offset(0, 0), // changes position of shadow
                                ),
                              ],

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 5,top: 5,bottom: 5),
                              child: Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                          )
                      )
                          : GestureDetector(
                              onTap: () {
                                //final ABmodel = context.read<AlbumModel>();
                                setState(() {
                                  linear = true;
                                  shuffle = false;
                                  repeat = false;
                                  playmodeModel.mode = 'linear';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0,right: 5,top: 5,bottom: 5),
                                  child: Icon(
                                    Icons.playlist_play,
                                    color: Colors.white70,
                                    size: 45,
                                  ),
                                ),
                              )
                          )
                      ),
                    ),
                    SizedBox(width: 10,),
                    Consumer<PlayAudio>(
                      builder:((context, playmodeModel, child)=>
                      playmodeModel.mode == "shuffle" ? GestureDetector(
                          onTap: () {
                            //final ABmodel = context.read<AlbumModel>();
                            setState(() {
                              shuffle = false;
                              playmodeModel.mode = 'none';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 22,
                                  offset: Offset(0, 0), // changes position of shadow
                                ),
                              ],

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10,bottom: 10),
                              child: Icon(
                                Icons.shuffle,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          )
                      )
                          :  GestureDetector(
                              onTap: () {
                                //final ABmodel = context.read<AlbumModel>();
                                setState(() {
                                  shuffle = true;
                                  linear = false;
                                  repeat = false;
                                  playmodeModel.mode = 'shuffle';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10,bottom: 10),
                                  child: Icon(
                                    Icons.shuffle,
                                    color: Colors.white70,
                                    size: 35,
                                  ),
                                ),
                              )
                          )
                      ),
                        ),
                    SizedBox(width: 10),
                    Consumer<PlayAudio>(
                      builder:((context, playmodeModel, child)=>
                      playmodeModel.mode == "repeat" ? GestureDetector(
                          onTap: () {
                            setState(() {
                              repeat = false;
                              playmodeModel.mode = 'none';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 22,
                                  offset: Offset(0, 0), // changes position of shadow
                                ),
                              ],

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10,bottom: 10),
                              child: Icon(
                                Icons.repeat,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          )
                      )
                        : GestureDetector(
                            onTap: () {
                              //final ABmodel = context.read<AlbumModel>();
                              setState(() {
                                shuffle = false;
                                linear = false;
                                repeat = true;
                                playmodeModel.mode = 'repeat';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10,bottom: 10),
                                child: Icon(
                                  Icons.repeat,
                                  color: Colors.white70,
                                  size: 35,
                                ),
                              ),
                            )
                        )
                      ),
                      ),

                    SizedBox(width: 20,)
                  ],
                ),
              ),
            ],
          ),
        ),
        isPlaylistSelectorVisible ? PlaylistSelector() : Container(),
      ]),
    );
  }

  String getTime(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength);
    }
  }

  Future<void> addToPlaylist(String playlistName, String songTitle,
      String artist, String thumb, String audPath, String tempUrl, String vId, int dur) async {
    var playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    final nav = Provider.of<Playlists>(context, listen: false);
    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var mySongsPlaylist = storedPlaylists.firstWhere(
      (playlist) => playlist['name'] == playlistName,
      orElse: () => {
        'name': playlistName,
        'songs': []
      },
    );

    List<dynamic> songs = mySongsPlaylist['songs'];

    bool isSongAlreadyPresent = songs.any((song) =>
        song['songTitle'] == songTitle && song['songAuthor'] == artist);

    if (isSongAlreadyPresent) {
      print('Song is already present in $playlistName playlist.');
    } else {
      songs.add({
        'songTitle': songTitle,
        'songAuthor': artist,
        'tUrl': thumb,
        'vId': vId,
        'audPath' : audPath,
        'thumbnail': thumb,
        'duration' : dur,
      });

      box.put('playlists', storedPlaylists);
      await box.close();

      setState(() {
        if (!nav.playlist.contains(playlistName)) {
          nav.playlist.add(playlistName);
          playlistProvider.updatePlaylist(nav.playlist);
        }
      });

      print('Song added to "My Songs" playlist successfully.');
    }
  }

  Widget PlaylistSelector() {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: InkWell(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withAlpha(480), Colors.black],
                        stops: [0.2, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: Text(
                                  "Choose Playlist",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: buildList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget buildList() {
    final nav = Provider.of<Playlists>(context, listen: false);
    final model = context.read<BottomPlayerModel>();
    return Container(
      color: Colors.black.withAlpha(300),
      height: 200,
      child: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0,left: 5),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: playlistProvider.playlist.length,
              itemBuilder: (context, index) {
                bool isMySongs = nav.playlist[index] == "My Songs";
                bool isBlank = nav.playlist[index] == "blank";
                bool Trending = nav.playlist[index] == "Trending";
                bool Punjabi = nav.playlist[index] == "Punjabi";
                bool Top10Indian = nav.playlist[index] == "Top10Indian";
                bool EngRom = nav.playlist[index] == "EngRom";

                if (!isBlank) {
                  List<Color> gradientColors = [Colors.grey, Colors.grey.shade700];

                  IconData iconData = isMySongs
                      ? Icons.thumb_up
                      : Icons.sports_gymnastics;
                  return (!Trending && !Punjabi && !Top10Indian && !EngRom) ? ListTile(
                    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    onTap: () {
                      addToPlaylist(
                          nav.playlist[index],
                          model.currentTitle,
                          model.currentAuthor,
                          model.tUrl,
                          model.filePath,
                          model.tUrl,
                          model.vId,
                      model.currentDuration);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Added successfully !'),

                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      showPlaylistSelector();
                                    });
                                  },
                                  child: Container(
                                    //color: Colors.red,
                                    width: 50,
                                    child: Text('Change',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 13),),
                                  )),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: widget.color.withAlpha(
                              1000), // Customize the background color
                          duration: Duration(
                              seconds:
                              1),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      nav.playlist[index],
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Playlist',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ) : Container();
                } else {
                  return Container();
                }
              },
            ),
          );
        },
      ),
    );
  }

  void showPlaylistSelector() {
    setState(() {
      isPlaylistSelectorVisible = true;
    });
  }
}
