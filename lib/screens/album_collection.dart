import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../models/album.dart';
import '../models/bottom_player.dart';
import '../services/download_video.dart';
import '../services/play_audio.dart';

class AlbumCollection extends StatefulWidget {
  const AlbumCollection({super.key});

  @override
  State<AlbumCollection> createState() => _AlbumCollectionState();
}

class _AlbumCollectionState extends State<AlbumCollection> {
  final ScrollController _controller1 = ScrollController();
  final ScrollController _controller2 = ScrollController();
  bool track1 = false;
  late List<bool> isPlayingList ;
  int currentlyPlayingIndex = -1;
  bool _isMounted = false;
  bool linear = false;
  bool shuffle = false;
  bool repeat = false ;

  void _onScrollEvent() {
    //final extentAfter = _controller1.position.extentAfter;
    //final extentAfter2 = _controller2.position.extentAfter;
    _controller1.jumpTo(_controller2.offset);
    track1 = true;

  }

  @override
  void initState() {
    // TODO: implement initState
    _isMounted = true;
    final ABmodel = Provider.of<AlbumModel>(context, listen: false);
    isPlayingList = List.generate(ABmodel.playlistLength , (index) => false);
    print("Printing playlist detains from album collection : ${ABmodel.playlistLength}");
    //_controller1.addListener(_onScrollEvent);
    _controller2.addListener(_onScrollEvent);
    /*_controller2.addListener(() {
      _controller1.jumpTo(_controller2.offset);
      print(_controller1.position);
      print(_controller2.position);
    });*/

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isMounted = false;
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ABmodel = Provider.of<AlbumModel>(context, listen: false);
    final model = context.read<BottomPlayerModel>();
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
                                            Container(
                                              height: 100,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    bottomRight: Radius.zero,
                                                    topLeft:
                                                        Radius.circular(15)),
                                                child: PhotoView(
                                                  imageProvider:
                                                      NetworkImage(ABmodel.ab1),
                                                  customSize: Size(180, 180),
                                                  enableRotation: true,
                                                  backgroundDecoration:
                                                      BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 100,
                                              width: 3,
                                            ),
                                            Container(
                                              height: 100,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    bottomRight: Radius.zero,
                                                    topRight:
                                                        Radius.circular(15),
                                                    bottomLeft: Radius.zero),
                                                child: PhotoView(
                                                  imageProvider:
                                                      NetworkImage(ABmodel.ab2),
                                                  customSize: Size(180, 180),
                                                  enableRotation: true,
                                                  backgroundDecoration:
                                                      BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor,
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
                                            Container(
                                              height: 100,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  bottomRight: Radius.zero,
                                                  topRight: Radius.zero,
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                ),
                                                child: PhotoView(
                                                  imageProvider:
                                                      NetworkImage(ABmodel.ab3),
                                                  customSize: Size(180, 180),
                                                  enableRotation: true,
                                                  backgroundDecoration:
                                                      BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 100,
                                              width: 3,
                                            ),
                                            Container(
                                              height: 100,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: PhotoView(
                                                  imageProvider:
                                                      NetworkImage(ABmodel.ab4),
                                                  customSize: Size(180, 180),
                                                  enableRotation: true,
                                                  backgroundDecoration:
                                                      BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor,
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
                                      child: Text(
                                        ABmodel.albumName,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                                      playmodeModel.mode = 'linear';
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
                                                      playmodeModel.mode = 'shuffle';
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
                                        Consumer<PlayAudio>(
                                          builder:((context, playmodeModel, child)=>
                                          playmodeModel.mode == "repeat" ? GestureDetector(
                                              onTap: () {
                                                //final ABmodel = context.read<AlbumModel>();
                                                setState(() {
                                                  repeat = false;
                                                  playmodeModel.mode = 'none';
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

                                                      playmodeModel.mode = 'repeat';
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
                      FutureBuilder<List<Map<String, Object>>>(
                        future: accessPlaylist(ABmodel.playlistName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
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
                              width: MediaQuery.of(context).size.width,
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
                                      int check ;
                                      final audio = Provider.of<PlayAudio>(context, listen: false);
                                      final model = context.read<BottomPlayerModel>();
                                      List path_dur = await DownloadVideo().downloadVideo(songDetails['vId'].toString());  // Download the audio file, return a list with file location and duration
                                      //ABmodel.playMode = 'shuffle';
                                      await _updateCard(
                                          songDetails['tUrl'].toString(),
                                          'playlist',
                                          songDetails['songTitle'].toString(),
                                          songDetails['songAuthor'].toString(),
                                          path_dur[1].toInt());
                                      updateRetain(
                                          songDetails['songTitle'].toString(),
                                          songDetails['songAuthor'].toString(),
                                          songDetails['tUrl'].toString(),
                                          path_dur[0],
                                          songDetails['tUrl'].toString());
                                      if (repeat == false && shuffle == false && linear == false){
                                        check = 0;
                                      } else {
                                        check = 1;
                                      }
                                      print("Check being passed: $check");
                                      print("Mode being passed: """);
                                      await audio.initializePlaylistAudioPlayer(playlistDetails,index,path_dur,check,'');
                                      await audio.playAudio();

                                      setState(()  {
                                        isPlayingList[index] = !isPlayingList[index];
                                        if (currentlyPlayingIndex != index) {
                                          if (currentlyPlayingIndex != -1) { // If a new item is clicked, this stops the currently playing item
                                            isPlayingList[currentlyPlayingIndex] = false;
                                          }
                                          currentlyPlayingIndex = index; // Updating the currently playing index
                                        }
                                        //ABmodel.currentDuration = (path_dur[1]).toInt();
                                        model.filePath = path_dur[0];
                                        //isPlayingList[index] = true;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 3.0),
                                      child: Container(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width - 5,
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0),
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
                                                    imageProvider: NetworkImage(
                                                        songDetails!['tUrl']
                                                            .toString()),
                                                    customSize: Size(120, 120),
                                                    enableRotation: true,
                                                    backgroundDecoration:
                                                        BoxDecoration(
                                                      color: Theme.of(context)
                                                          .canvasColor,
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
                                                    width: 220,
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
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Builder(
                                              builder: (context) {
                                                return AnimatedSwitcher(
                                                  duration: Duration(milliseconds: 500),
                                                  child: isPlayingList[index] && model.playButtonOn
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
                                            /*Icon(
                                              isPlayingList[index] && model.playButtonOn ? CupertinoIcons.pause : CupertinoIcons.play_arrow_solid,
                                              color: Colors.white,
                                            ),*/
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
                      )
                    ],
                  )),
                ),
              ))
        ],
      ),
    );
  }

  getDuration() async {
    var box = await Hive.openBox('duration');
    final ABmodel = Provider.of<AlbumModel>(context);

    setState(() {
      ABmodel.currentDuration = box.get('duration');
    });

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
  }

  Future<void> _updateCard(String thumbnailUrl, String mode, String title, String author, int dur) async {
    if(mode == 'playlist' && _isMounted){
      PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));
      final model = context.read<BottomPlayerModel>();
      //final box = await Hive.openBox('retain');
      print("automatic update sucessfull _____________________________________________________________");
      setState(() {
        model.cardBackgroundColor = paletteGenerator.dominantColor!.color;
        model.currentTitle = title;
        model.currentAuthor = author;
        model.tUrl = thumbnailUrl;
        model.playButtonOn = true;
        model.isCardVisible = true;
        model.currentDuration = dur.toInt();
        //box.put('color', paletteGenerator.dominantColor!.color.toString());
      });
    }
  }
}
