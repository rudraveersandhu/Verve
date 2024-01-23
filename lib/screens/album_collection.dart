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

  void _onScrollEvent() {
    final extentAfter = _controller1.position.extentAfter;
    final extentAfter2 = _controller2.position.extentAfter;
    print("--------------------------------------------");
    print("Extent after: $extentAfter2");
    print("Extent after: $extentAfter");
    print("--------------------------------------------");

    _controller1.jumpTo(_controller2.offset);
    track1 = true;
    print('GPT');
  }

  @override
  void initState() {
    // TODO: implement initState
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
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ABmodel = context.watch<AlbumModel>();
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ABmodel.cardBackgroundColor.withAlpha(100),
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
                    backgroundColor: ABmodel.cardBackgroundColor.withAlpha(500),
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
                                        maxLines: 3,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
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
                                      final model = context.read<BottomPlayerModel>();
                                      final audio = Provider.of<PlayAudio>(
                                          context,
                                          listen: false);
                                      String audpath = await DownloadVideo().downloadVideo(songDetails['vId'].toString(),'download');
                                      await _updateCardColor(
                                          songDetails['tUrl'].toString());
                                      updateRetain(
                                          songDetails['songTitle'].toString(),
                                          songDetails['songAuthor'].toString(),
                                          songDetails['tUrl'].toString(),
                                          audpath,
                                          songDetails['tUrl'].toString());

                                      audio.initializeAudioPlayer(audpath,'downloaded');
                                      audio.playAudio();
                                      setState(() {
                                        model.isCardVisible = true;
                                        model.tUrl =
                                            songDetails['tUrl'].toString();
                                        model.currentTitle =
                                            songDetails['songTitle'].toString();
                                        model.currentAuthor =
                                            songDetails['songAuthor']
                                                .toString();
                                        model.filePath = audpath;
                                        model.isCardVisible = true;
                                        model.playButtonOn = true;
                                      });
                                    },
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
                                          Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 33,
                                          )
                                        ],
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

  Future<void> _updateCardColor(String thumbnailUrl) async {
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));
    final model = context.read<BottomPlayerModel>();
    final box = await Hive.openBox('retain');

    setState(() {
      model.cardBackgroundColor = paletteGenerator.dominantColor!.color;
      box.put('color', paletteGenerator.dominantColor!.color.toString());
    });
  }
}
