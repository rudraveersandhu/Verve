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


import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../audio_player_handler.dart';
import '../main.dart';
import '../models/bottom_player.dart';
import '../services/play_audio.dart';

class MySongs extends StatefulWidget {
  final String title;

  const MySongs({Key? key, required this.title})
      : super(key: key);

  @override
  State<MySongs> createState() => _MySongsState();
}

class _MySongsState extends State<MySongs> with TickerProviderStateMixin,ChangeNotifier {
  String audpath = "";
  Color cardBackgroundColor = Colors.indigo;
  late AnimationController _controller;
  late Animation<double> _animation;

  Map<String, bool> playmap = {
    "showCard": false,
    "songPlay": false,
  };

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = Tween(begin: 0.0,end: 1.0).animate(_controller);
    super.initState();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }


  Future<List<Map<String, Object>>> accessPlaylist(String targetPlaylistName) async {
    final box = await Hive.openBox('playlists');
    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var targetPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == targetPlaylistName,
      orElse: () => <String, Object>{},
    );

    if (targetPlaylist != null) {
      List<dynamic> songs = targetPlaylist['songs'];
      List<Map<String, Object>> playlistDetails = [];

      for (var song in songs) {
        String songTitle = song['songTitle'];
        String songAuthor = song['songAuthor'];
        String tUrl = song['thumbnail'];
        String vId = song['vId'];
        String audPath = song['audPath'];
        int duration = song['duration'].toInt();

        playlistDetails.add({
          'songTitle': songTitle,
          'songAuthor': songAuthor,
          'tUrl': tUrl,
          'vId': vId,
          'audPath' : audPath,
          'duration' : duration,
        });
      }
      return playlistDetails;

    } else {
      print('Playlist not found: $targetPlaylistName');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();

    final model = context.read<BottomPlayerModel>();
    //final audio = Provider.of<PlayAudio>(context);
    return Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade900, Colors.black.withOpacity(.96)],
            ),
          ),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 60,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 23.0, top: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                    child: Icon(Icons.arrow_back_ios, color: Colors.white,)),
                                SizedBox(width: 10,),
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 33,
                                ),
                                SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 43,
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade700,
                  )
                ],
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, Object>>>(
                  future: accessPlaylist(widget.title),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Map<String, Object>>? playlistDetails = snapshot.data;
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: playlistDetails?.length,
                        itemBuilder: (context, index) {
                          Map<String,
                              Object>? songDetails = playlistDetails?[index];
                          String imageURL = songDetails!['tUrl'].toString();

                          return Slidable(
                                    key: const ValueKey(0),
                                    endActionPane: ActionPane(
                                      motion: ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: ((context) {
                                            setState(() {
                                              deleteSongFromPlaylist(
                                                  widget.title,
                                                  songDetails!['songTitle']
                                                      .toString());
                                            });
                                          }),
                                          backgroundColor: Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: Consumer<BottomPlayerModel>(
                                      builder: (context, value, child) =>
                                    GestureDetector(
                                      onTap: () async {
                                        value.playButtonOn = true;
                                        value.currentDuration =
                                            (songDetails['duration'] as int?) ??
                                                0;
                                        value.isCardVisible = true;
                                        value.tUrl =
                                            songDetails['tUrl'].toString();
                                        value.currentTitle =
                                            songDetails['songTitle'].toString();
                                        value.currentAuthor =
                                            songDetails['songAuthor']
                                                .toString();
                                        value.filePath =
                                            songDetails['audPath'].toString();
                                        value.vId =
                                            songDetails['vId'].toString();

                                        String color = await getColorFromRetain();
                                        updateRetain(
                                            songDetails['songTitle'].toString(),
                                            songDetails['songAuthor']
                                                .toString(),
                                            songDetails['tUrl'].toString(),
                                            songDetails['audPath'].toString(),
                                            songDetails['vId'].toString(),
                                            songDetails['tUrl'].toString(),
                                            color);
                                        await _updateCardColor(songDetails['tUrl'].toString());
                                        //await audio.initializeAudioPlayer(songDetails['audPath'].toString());
                                        //await audio.playAudio();
                                        //String? color = await updateCardColor(tempUrl);
                                        //model.currentDuration = path_dur[1].toInt();
                                        MediaItem item = MediaItem(
                                            id: songDetails['audPath'].toString(),
                                            album: songDetails['songAuthor']
                                                .toString(),
                                            title: songDetails['songTitle'].toString(),
                                            artist: songDetails['songAuthor'].toString(),
                                            duration: Duration(seconds: (songDetails['duration'] as int?) ??
                                                0),
                                            artUri: Uri.parse(songDetails['tUrl'].toString()),
                                            genre: color,
                                            playable: true,
                                            extras: playmap = {
                                              "showCard": true,
                                              "songPlay": true,
                                            }
                                        );

                                        await AudioPlayerHandler().initializeAudioPlayer(songDetails['audPath'].toString());
                                        audioHandler.updateMediaItem(item);
                                        audioHandler.play();


                                      },
                                      child: ListTile(
                                        leading: FadeTransition(
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
                                              borderRadius: BorderRadius
                                                  .circular(2.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius
                                                  .circular(2),
                                              child: PhotoView(
                                                imageProvider: CachedNetworkImageProvider(
                                                  imageURL,
                                                  cacheManager: CacheManager(
                                                    Config(
                                                      'verve',
                                                      stalePeriod: Duration(
                                                          days: 7),

                                                    ),
                                                  ),
                                                ),
                                                customSize: Size(120, 120),
                                                enableRotation: true,
                                                gaplessPlayback: true,
                                                backgroundDecoration: BoxDecoration(
                                                  color: Theme
                                                      .of(context)
                                                      .canvasColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          songDetails['songTitle'].toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),),
                                        subtitle: Text(
                                          '${songDetails['songAuthor']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                            //fontWeight: FontWeight.w700,
                                          ),),

                                      ),
                                    ),
                                  ),
                          );


                        }
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
  Future<void> _updateCardColor(String thumbnailUrl) async {
    final model = context.read<BottomPlayerModel>();
    try{
      PaletteGenerator paletteGenerator =await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(
        thumbnailUrl,
        cacheManager: CacheManager(
          Config(
            'verve',
            stalePeriod: Duration(days: 7),
          ),
        ),
      ));
      final box = await Hive.openBox('retain');

      setState(() {
        model.cardBackgroundColor = paletteGenerator.dominantColor!.color;
        box.put('color', model.cardBackgroundColor.toString());
      });
    }catch(e){
      print(e);
      setState(() {
        model.cardBackgroundColor = Colors.grey.shade800;
      });

    }

  }

  Future<String> getColorFromRetain() async {
    final box = await Hive.openBox('retain');
    final model = context.read<BottomPlayerModel>();
    String color = await box.get('color');
    Color col = convertStringToColor(color);

    setState(() {
      model.cardBackgroundColor = col;
    });

    return col.toString();

  }

  Color convertStringToColor(String colorString) {
    String hexString = colorString.replaceAll("Color(", "").replaceAll(")", "").replaceAll("0x", "");
    int hexValue = int.parse(hexString, radix: 16);
    Color color = Color(hexValue);
    return color;
  }

  Future<void> deleteSongFromPlaylist(String playlistName, String songName) async {
    var box = await Hive.openBox('playlists');
    List<dynamic> playlistsData = box.get('playlists', defaultValue: []) ?? [];
    List<Map<String, dynamic>> playlists =
    List<Map<String, dynamic>>.from(playlistsData.map(
          (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
    ));

    int playlistIndex =
    playlists.indexWhere((playlist) => playlist['name'] == playlistName);

    if (playlistIndex != -1) {
      int songIndex = playlists[playlistIndex]['songs']
          .indexWhere((song) => song['songTitle'] == songName);

      if (songIndex != -1) {
        playlists[playlistIndex]['songs'].removeAt(songIndex);
        await box.put('playlists', playlists);

      } else {
        print('Song $songName not found in playlist $playlistName.');
      }
    } else {
      print('Playlist $playlistName not found.');
    }

    await box.close();
  }

  void updateRetain(String songTitle, String artist, String thumb, String audPath, String vId, String tempUrl, String color) async {
    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', audPath);
    box.put('vId', vId);
    box.put('tempUrl', tempUrl);
    box.put('color', color);


  }
}
