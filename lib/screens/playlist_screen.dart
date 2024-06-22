import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/bottom_player.dart';
import '../models/playlists.dart';
import '../utilities/playlist_provider.dart';
import 'album_collection.dart';
import 'my_songs.dart';

class MyPlaylistsScreen extends StatefulWidget {
  const MyPlaylistsScreen({super.key});

  @override
  State<MyPlaylistsScreen> createState() => _MyPlaylistsScreenState();
}

class _MyPlaylistsScreenState extends State<MyPlaylistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade900, Colors.black.withOpacity(.96)],
        ),
      ),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 355,
              child:
              Consumer<PlaylistProvider>(
                builder: (context, playlistProvider, child) {

                  final ABmodel = context.watch<AlbumModel>();
                  //print(playlistProvider.youtube_playlists.length);
                  final nav = context.watch<PlaylistProvider>();
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: nav.local_playlists.length,
                    itemBuilder: (context, index) {
                      //bool isMySongs = nav.playlist[index] == "My Songs";
                      bool isBlank = nav.local_playlists[index] == "blank";
                      //final video = model.rows[index];
                      //print("Model rows: ${model.rows.length}");

                      if (!isBlank) {
                        IconData iconData = true
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.music_albums_fill;



                        return Slidable(
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: ((context) {
                                  setState(() {
                                    if(nav.local_playlists[index] != "My Songs"){
                                      setState(() {
                                        deletePlaylist(nav.local_playlists[index]);
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Center(
                                                child: Text(
                                                  'Deleted playlist successfully!',
                                                  style: TextStyle(fontSize: 13,letterSpacing: 1.0,fontWeight: FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                              ),

                                            ],
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                          ),
                                          backgroundColor:
                                          Colors.green.shade500.withAlpha(200),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Center(
                                                child: Text(
                                                  'Cannot delete default playlist "My Songs"!',
                                                  style: TextStyle(fontSize: 13,letterSpacing: 1.0,fontWeight: FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                              ),

                                            ],
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                          ),
                                          backgroundColor:
                                          Colors.orange.shade500.withAlpha(200),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  });



                                }),
                                backgroundColor: Colors.black.withRed(400),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: ListTile(
                              onTap: () async {
                                //await _updateAlbumBgColor(video[index].url);
                                /*updateRetain(
                                            songDetails['songTitle']
                                                .toString(),
                                            songDetails['songAuthor']
                                                .toString(),
                                            songDetails['tUrl'].toString(),
                                            songDetails['vId'].toString(),
                                            songDetails['tUrl'].toString());*/
                                pushScreen(
                                  context,
                                  screen: MySongs(
                                      playlistId: nav
                                          .local_playlists[index], index: index),
                                  withNavBar: true,
                                );

                              },
                              leading: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  iconData,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              title: Text(
                                nav.local_playlists[index],
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,

                                ),
                                maxLines: 2,
                              ),
                              subtitle: const Text(
                                'Playlist',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container(); // Exclude the item with the title "blank"
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> deletePlaylist(String playlistName) async {
    var box = await Hive.openBox('playlists');
    final nav = Provider.of<PlaylistProvider>(context, listen: false);
    List<dynamic> playlistsData = box.get('playlists', defaultValue: []) ?? [];

    List<Map<String, dynamic>> playlists = List<Map<String, dynamic>>.from(playlistsData.map((item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),)); // Convert each element to Map<String, dynamic>

    int playlistIndex = playlists.indexWhere((playlist) => playlist['name'] == playlistName); // Find the index of the playlist to be deleted

    if (playlistIndex != -1) {  // Check if the playlist with the given name exists

      playlists.removeAt(playlistIndex); // Remove the playlist from the list
      nav.local_playlists.removeAt(playlistIndex);
      await box.put('playlists', playlists);  // Save the updated list back to the box

      print('Playlist $playlistName deleted successfully.');
    } else {
      print('Playlist $playlistName not found.');
    }
    await box.close();
  }

  Future<void> _updateAlbumBgColor(String thumbnailUrl) async {
    final ABmodel = context.read<AlbumModel>();
    PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));

    setState(() {
      ABmodel.cardBackgroundColor = paletteGenerator.dominantColor!.color;
    });
  }



}
