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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../audio_player_handler.dart';
import '../main.dart';
import '../models/album.dart';
import '../models/bottom_player.dart';
import '../models/playlists.dart';
import '../services/download_video.dart';
import '../utilities/playlist_provider.dart';

class AlbumCollection extends StatefulWidget {
  final int index;
  AlbumCollection(this.index);

  @override
  State<AlbumCollection> createState() => _AlbumCollectionState();
}

class _AlbumCollectionState extends State<AlbumCollection> with TickerProviderStateMixin {
  final ScrollController _controller1 = ScrollController();
  final ScrollController _controller2 = ScrollController();
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<bool> isInPlaylist ;
  List<Future<bool>> futures = [];
  int currentlydownloadingIndex = -1;
  bool track1 = false;
  late List<bool> isPlayingList ;
  int currentlyPlayingIndex = -1;
  int check = 0;
  bool _isMounted = false;
  bool linear = false;
  bool shuffle = false;
  bool repeat = false ;

  void _onScrollEvent() {
    _controller1.jumpTo(_controller2.offset);
    track1 = true;
  }

  @override
  void initState() {
    _isMounted = true;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = Tween(begin: 0.0,end: 1.0).animate(_controller);
    final ABmodel = Provider.of<AlbumModel>(context, listen: false);
    isPlayingList = List.generate(ABmodel.playlistLength , (index) => false);
    print("Printing playlist detains from album collection : ${ABmodel.playlistLength}");
    _controller2.addListener(_onScrollEvent);
    super.initState();
  }

  fetchData(playlistDetails) async {
    isInPlaylist = List.generate(playlistDetails!.length, (index) => false);
    for (int i = 0; i < playlistDetails.length; i++) {
      futures.add(checkInPlaylist('My Songs', playlistDetails[i]['vId'].toString()));
    }
    List<bool> results = await Future.wait(futures);
    print(results);

    setState(() {
      isInPlaylist = results;
      check = 3;
    });
  }


  Future<bool> checkInPlaylist(String targetPlaylistName, String id) async {
    final box = await Hive.openBox('playlists');
    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var targetPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == targetPlaylistName,
      orElse: () => <String, Object>{},
    );

    if (targetPlaylist != null) {
      List<dynamic> songs = targetPlaylist['songs'];

      for (var song in songs) {
        String vId = song['vId'];

        if (vId == id) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }


  @override
  void dispose() {
    _isMounted = false;
    _controller1.dispose();
    _controller2.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
    final nav = context.watch<Playlists>();
    _controller.forward();
    final ABmodel = Provider.of<AlbumModel>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ABmodel.cardBackgroundColor,
              Colors.black.withOpacity(.96)
            ],
            stops: [
              0.3,
              .65
            ]),
      ),
      child: Stack(
        children: [
          NestedScrollView(
              physics: const BouncingScrollPhysics(),
              controller: _controller1,
              headerSliverBuilder: (
                  BuildContext context,
                  bool innerBoxScrolled,
                  ) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 260,
                    backgroundColor: ABmodel.cardBackgroundColor,
                    elevation: 0,
                    pinned: true,
                    toolbarHeight: 40,
                    //floating: true,
                    automaticallyImplyLeading: true,
                    flexibleSpace: LayoutBuilder(
                      builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                          ) {
                        return FlexibleSpaceBar(
                          background: GestureDetector(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 60,
                                ),
                                Center(
                                  child: Container(
                                    width: 203.0,
                                    height: 203.0,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.6),
                                          spreadRadius: 10,
                                          blurRadius: 35,
                                          offset: Offset(15, 15),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            FadeTransition(
                                              opacity: _animation,
                                              child: Container(
                                                height: 100,
                                                width: 100,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.zero,
                                                      topLeft:
                                                      Radius.circular(15)),
                                                  child: PhotoView(
                                                    imageProvider: CachedNetworkImageProvider(
                                                      ABmodel.ab1,
                                                    ),
                                                    customSize: Size(180, 180),
                                                    enableRotation: true,
                                                    gaplessPlayback: true,
                                                    backgroundDecoration: BoxDecoration(
                                                      color: Theme.of(context).canvasColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 100,
                                              width: 3,
                                            ),
                                            FadeTransition(
                                              opacity: _animation,
                                              child: Container(
                                                height: 100,
                                                width: 100,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                      bottomRight: Radius.zero,
                                                      topRight:
                                                      Radius.circular(15),
                                                      bottomLeft: Radius.zero),
                                                  child: PhotoView(
                                                    imageProvider: CachedNetworkImageProvider(
                                                      ABmodel.ab2,
                                                    ),
                                                    customSize: Size(180, 180),
                                                    enableRotation: true,
                                                    gaplessPlayback: true,
                                                    backgroundDecoration: BoxDecoration(
                                                      color: Theme.of(context).canvasColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 3,
                                          width: 200,
                                        ),
                                        Row(
                                          children: [
                                            FadeTransition(
                                              opacity: _animation,
                                              child: Container(
                                                height: 100,
                                                width: 100,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                    Radius.circular(15),
                                                  ),
                                                  child: PhotoView(
                                                    imageProvider: CachedNetworkImageProvider(
                                                      ABmodel.ab3,
                                                    ),
                                                    customSize: Size(180, 180),
                                                    enableRotation: true,
                                                    gaplessPlayback: true,
                                                    backgroundDecoration: BoxDecoration(
                                                      color: Theme.of(context).canvasColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 100,
                                              width: 3,
                                            ),
                                            FadeTransition(
                                              opacity: _animation,
                                              child: Container(
                                                height: 100,
                                                width: 100,
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.only(bottomRight: Radius.circular(10) ),
                                                  child: PhotoView(
                                                    imageProvider: CachedNetworkImageProvider(
                                                      ABmodel.ab4,
                                                    ),
                                                    customSize: Size(180, 180),
                                                    enableRotation: true,
                                                    gaplessPlayback: true,
                                                    backgroundDecoration: BoxDecoration(
                                                      color: Theme.of(context).canvasColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 13),
                              ],
                            ),
                          ),
                        ); // the vanishing upper part
                      },
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                //controller: _scrollController2,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, bottom: 35, top: 15),
                                child: Container(
                                    width: MediaQuery.of(context).size.width - 120,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.waveform_path,
                                              color: Colors.grey.shade500,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "Listen on verve",
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, top: 10),
                                          child: Consumer<PlaylistProvider>(
                                              builder: (context, playlistProvider, child) {
                                              List<String> names = playlistProvider.youtube_playlists;
                                              return Text(
                                                names[widget.index],
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              );
                                              }
                                          ),

                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Consumer<AudioPlayerHandler>(
                                              builder:((context, playmodeModel, child)=>
                                              playmodeModel.playbac == "linear" ? GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = Provider.of<AlbumModel>(context, listen: false);
                                                    setState(() {
                                                      linear = false;
                                                      playmodeModel.playbac = 'none';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.playlist_play,
                                                    color: ABmodel.cardBackgroundColor.withRed(ABmodel.cardBackgroundColor.red + 80).withGreen(ABmodel.cardBackgroundColor.green + 80).withBlue(ABmodel.cardBackgroundColor.blue + 80),
                                                    size: 40,
                                                  )
                                              )
                                                  : GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      linear = true;
                                                      shuffle = false;
                                                      repeat = false;
                                                      playmodeModel.playbac = 'linear';
                                                      playback = 'linear';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.playlist_play,
                                                    color: Colors.white70,
                                                    size: 40,
                                                  )
                                              )
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Consumer<AudioPlayerHandler>(
                                              builder:((context, playmodeModel, child)=>
                                              playmodeModel.playbac == "shuffle" ? GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      shuffle = false;
                                                      playmodeModel.playbac = 'none';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.shuffle,
                                                    color: ABmodel.cardBackgroundColor.withRed(ABmodel.cardBackgroundColor.red + 80).withGreen(ABmodel.cardBackgroundColor.green + 80).withBlue(ABmodel.cardBackgroundColor.blue + 80),
                                                    size: 30,
                                                  )
                                              )
                                                  :  GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      shuffle = true;
                                                      linear = false;
                                                      repeat = false;
                                                      playmodeModel.playbac = 'shuffle';
                                                      playback = 'shuffle';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.shuffle,
                                                    color: Colors.white70,
                                                    size: 30,
                                                  )
                                              )
                                              ),
                                            ),
                                            SizedBox(width: 12,),
                                            Consumer<AudioPlayerHandler>(
                                              builder:((context, playmodeModel, child)=>
                                              playmodeModel.playbac == "repeat" ? GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      repeat = false;
                                                      playmodeModel.playbac = 'none';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.repeat,
                                                    color: ABmodel.cardBackgroundColor.withRed(ABmodel.cardBackgroundColor.red + 80).withGreen(ABmodel.cardBackgroundColor.green + 80).withBlue(ABmodel.cardBackgroundColor.blue + 80),
                                                    size: 30,
                                                  )
                                              )
                                                  : GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      shuffle = false;
                                                      linear = false;
                                                      repeat = true;
                                                      playback = 'repeat';
                                                      playmodeModel.playbac = 'repeat';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.repeat,
                                                    color: Colors.white70,
                                                    size: 30,
                                                  )
                                              )
                                              ),
                                            ),
                                            //SizedBox(width: 20,)
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.play_circle_filled_rounded,
                                  color: Colors.white,
                                  size: 77,
                                ),
                              ),
                            ],
                          ),
                          Consumer<PlaylistProvider>(
                            builder: (context, playlistProvider, child) {
                              List<String> names = playlistProvider.youtube_playlists;
                              return Container(
                                height:MediaQuery.of(context).size.height-kBottomNavigationBarHeight-200,
                                child: buildRow(model.rows[widget.index], names[widget.index])
                              );

                            },
                          )
                          /*FutureBuilder<List<Map<String, Object>>>(
                            future: accessPlaylist(ABmodel.playlistName),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(color: Colors.white),
                                );
                              } else {
                                List<Map<String, Object>>? playlistDetails =
                                    snapshot.data;

                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  //width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    controller: _controller2,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    itemCount: playlistDetails?.length,
                                    itemBuilder: (context, index) {
                                      Map<String, Object>? songDetails =
                                      playlistDetails?[index];

                                      return GestureDetector(
                                        onTap: () async {
                                          final List path_dur = await DownloadVideo().downloadVideo(songDetails['vId'].toString());  // Download the audio file, return a list with file location and duration

                                          await _updateCardColor(
                                            songDetails['tUrl'].toString(),
                                              songDetails['songTitle'].toString(),
                                              songDetails['songAuthor'].toString(),
                                              path_dur[1].toInt()
                                          );

                                          updateRetain(songDetails['songTitle'].toString(), songDetails['songAuthor'].toString(), songDetails['tUrl'].toString(), path_dur[0], songDetails['tUrl'].toString());

                                          hplaylist = playlistDetails;
                                          strack = index;
                                          playback = 'linear';
                                          //totalDuration = Duration(seconds: path_dur[1].toInt());

                                          await AudioPlayerHandler().initializePlaylistAudioPlayer(playlistDetails,index,path_dur,0,'linear');

                                          audioHandler.play();

                                          setState(()  {

                                            isPlayingList[index] = !isPlayingList[index];
                                            if (currentlyPlayingIndex != index) {
                                              if (currentlyPlayingIndex != -1) { // If a new item is clicked, this stops the currently playing item
                                                isPlayingList[currentlyPlayingIndex] = false;
                                              }
                                              currentlyPlayingIndex = index; // Updating the currently playing index
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 3.0),
                                          child: Container(
                                            height: 70,
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 15.0),
                                                  child: FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(0.8),
                                                            spreadRadius: 2,
                                                            blurRadius: 7,
                                                            offset: Offset(2, 3),
                                                          ),
                                                        ],
                                                        color: Colors.orange,
                                                        borderRadius:
                                                        BorderRadius.circular(2.0),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.circular(2),
                                                        child: PhotoView(
                                                          imageProvider: CachedNetworkImageProvider(
                                                            songDetails!['tUrl'].toString(),

                                                          ),
                                                          customSize: Size(120, 120),
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
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 12.0,
                                                          left: 12,
                                                          right: 12
                                                      ),
                                                      child: Container(
                                                        width: 260,
                                                        child: Text(
                                                          songDetails['songTitle']
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5.0),
                                                      child: Container(
                                                        width: 220,
                                                        child: Text(
                                                          songDetails['songAuthor']
                                                              .toString(),
                                                          style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 13,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: 10,),

                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 10.0),
                                                  child: Builder(
                                                      builder: (context) {
                                                        return AnimatedSwitcher(
                                                          duration: Duration(milliseconds: 500),
                                                          child: isPlayingList[index] //&& model.playButtonOn
                                                              ? Icon(CupertinoIcons.pause_solid, color: Colors.white, key: Key('pause'))
                                                              : Icon(CupertinoIcons.play_arrow_solid,color: Colors.white, key: Key('play')),
                                                          transitionBuilder: (child, animation) {
                                                            return ScaleTransition(
                                                              scale: animation,
                                                              child: child,
                                                            );
                                                          },
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          )*/
                        ],
                      )),
                ),
              )
          )
        ],
      ),
    );
  }

  Widget buildRow(List<dynamic> items, String name) {
    final ABmodel = context.watch<AlbumModel>();
    //print(items);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height:MediaQuery.of(context).size.height-kBottomNavigationBarHeight,
        width: MediaQuery.of(context).size.width,
        //color: Colors.white,// Adjust the height as needed
        child: ListView.builder(
          controller: _controller2,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {

            try {
              final video = items[index];
              return GestureDetector(
                onTap: () async {
                  final model = context.read<BottomPlayerModel>();
                  final List path_dur = await DownloadVideo().downloadVideo(video.id);  // Download the audio file, return a list with file location and duration

                  await _updateCardColor(
                      video.url,
                      video.title,
                      video.author,
                      path_dur[1].toInt()
                  );

                  updateRetain(video.title, video.author, video.url, path_dur[0], video.url);
                  //hplaylist = playlistDetails;
                  strack = index;
                  playback = 'linear';
                  //totalDuration = Duration(seconds: path_dur[1].toInt());
                  await AudioPlayerHandler().initializePlaylistAudioPlayer(items,index,path_dur,0,'linear');

                  audioHandler.play();

                  setState(()  {
                    model.isCardVisible = true;

                    isPlayingList[index] = !isPlayingList[index];
                    if (currentlyPlayingIndex != index) {
                      if (currentlyPlayingIndex != -1) { // If a new item is clicked, this stops the currently playing item
                        isPlayingList[currentlyPlayingIndex] = false;
                      }
                      currentlyPlayingIndex = index; // Updating the currently playing index
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Container(
                    height: 70,
                    width: MediaQuery.of(context).size.height,
                    //color: Colors.transparent,
                    child: Row(

                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0),
                          child: FadeTransition(
                            opacity: _animation,
                            child: Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.8),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(2, 3),
                                  ),
                                ],
                                color: Colors.orange,
                                borderRadius:
                                BorderRadius.circular(2.0),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(2),
                                child: PhotoView(
                                  imageProvider: CachedNetworkImageProvider(
                                    video.url,

                                  ),
                                  customSize: Size(120, 120),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 12.0,
                                  left: 12,
                                  right: 12
                              ),
                              child: Container(
                                width: 260,
                                child: Text(
                                  video.title,
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5.0,left: 12),
                              child: Container(
                                width: 220,
                                child: Text(
                                  video.author,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Builder(
                                builder: (context) {
                                  return AnimatedSwitcher(
                                    duration: Duration(milliseconds: 500),
                                    child: isPlayingList[index] //&& model.playButtonOn
                                        ? Icon(CupertinoIcons.pause_solid, color: Colors.white, key: Key('pause'))
                                        : Icon(CupertinoIcons.play_arrow_solid,color: Colors.white, key: Key('play')),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                  );
                                }
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

            } catch (e) {
              print(e);
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> addToPlaylist(String playlistName, String songTitle,
      String artist, String thumb, String audPath, String vId , String tempUrl,int dur) async {
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
        'tUrl': tempUrl,
        'vId': vId,
        'audPath': audPath,
        'thumbnail': thumb,
        'duration': dur,
      });

      box.put('playlists', storedPlaylists);
      await box.close();

      setState(() {
        if (!nav.playlist.contains(playlistName)) {
          nav.playlist.add(playlistName);
          playlistProvider.updateLocalPlaylist(nav.playlist);
        }
      });

      print('Song added to "My Songs" playlist successfully.');
    }
  }


  getDuration() async {
    var box = await Hive.openBox('duration');
    final ABmodel = Provider.of<AlbumModel>(context);

    setState(() {
      ABmodel.currentDuration = box.get('duration');
    });

  }

  Future<List<Map<String, Object>>> accessPlaylist(String targetPlaylistName) async {

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
        });
      }



      return playlistDetails;
    } else {
      print('Playlist not found: $targetPlaylistName');
      return [];
    }
  }

  void updateRetain(String songTitle, String artist, String thumb,
      String audPath, String tempUrl) async {
    final model = context.read<BottomPlayerModel>();
    setState(() {
      model.isCardVisible = true;
    });

    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', audPath);
    box.put('tempUrl', tempUrl);
    box.put('color', (model.cardBackgroundColor).toString());
    print("color being stored in retain: ${(model.cardBackgroundColor).toString()}");
  }


  Future<void> _updateCardColor(String thumbnailUrl,String title, String author, int dur ) async {
    PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));
    final model = context.read<BottomPlayerModel>();
    final box = await Hive.openBox('retain');

    setState(() {
      model.cardBackgroundColor = paletteGenerator.dominantColor!.color;
      box.put('color', paletteGenerator.dominantColor!.color.toString());
      model.currentTitle = title;
      model.currentAuthor = author;
      model.tUrl = thumbnailUrl;
      model.playButtonOn = true;
      model.isCardVisible = true;
      model.currentDuration = dur;
      box.put('color', paletteGenerator.dominantColor!.color.toString());

    });
  }
}