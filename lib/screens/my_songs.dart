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


import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../models/bottom_player.dart';
import '../services/play_audio.dart';

class MySongs extends StatefulWidget {
  final String title;

  const MySongs({Key? key, required this.title})
      : super(key: key);

  @override
  State<MySongs> createState() => _MySongsState();
}

class _MySongsState extends State<MySongs> {
  String audpath = "";
  Color cardBackgroundColor = Colors.indigo;

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
        String tUrl = song['tUrl'];
        String vId = song['vId'];

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

  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
    final audio = Provider.of<PlayAudio>(context);
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
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Map<String, Object>>? playlistDetails = snapshot.data;
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: playlistDetails?.length,
                        itemBuilder: (context, index) {
                          Map<String, Object>? songDetails = playlistDetails?[index];
                          return Slidable(
                            key: const ValueKey(0),
                            endActionPane:  ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: ((context){
                                    setState(() {
                                      deleteSongFromPlaylist(widget.title,songDetails!['songTitle'].toString());
                                    });
                                  }),
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                await _updateCardColor(songDetails['tUrl'].toString());
                                updateRetain(songDetails['songTitle'].toString(), songDetails['songAuthor'].toString(), songDetails['tUrl'].toString(), songDetails['vId'].toString(), songDetails['tUrl'].toString());
                                audio.initializeAudioPlayer(songDetails['vId'].toString());
                                audio.playAudio();
                                setState(() {
                                  model.isCardVisible = true;
                                  model.tUrl = songDetails['tUrl'].toString();
                                  model.currentTitle = songDetails['songTitle'].toString();
                                  model.currentAuthor = songDetails['songAuthor'].toString();
                                  model.filePath = songDetails['vId'].toString();
                                  model.isCardVisible = true;
                                  model.playButtonOn = true;
                                });
                              },
                              child: ListTile(
                                leading: Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.8),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: Offset(2, 3),
                                    ),
                                  ],
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: PhotoView(
                                    imageProvider: NetworkImage(
                                        songDetails!['tUrl'].toString()
                                    ),
                                    customSize: Size(120, 120),
                                    enableRotation: true,
                                    backgroundDecoration: BoxDecoration(
                                      color: Theme.of(context).canvasColor,
                                    ),
                                  ),
                                ),
                              ),
                                title: Text(songDetails['songTitle'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),),
                                subtitle: Text('${songDetails['songAuthor']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    //fontWeight: FontWeight.w700,
                                  ),),

                              ),
                            ),
                          );
                        },
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

    PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));
    final box = await Hive.openBox('retain');

    setState(() {
      model.cardBackgroundColor = paletteGenerator.dominantColor!.color;
      box.put('color', model.cardBackgroundColor.toString());
    });
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

  void updateRetain(String songTitle, String artist, String thumb, String audPath, String tempUrl) async {
    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', audpath);
    box.put('tempUrl', tempUrl);

  }
}
