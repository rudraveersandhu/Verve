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


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import '../models/playlists.dart';
import '../utilities/playlist_provider.dart';
import 'my_songs.dart';
import 'new_playlist.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<Playlists>();
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
                        Text(
                          "Library",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return const NewPlaylist();
                                    },
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var curveTween =
                                          CurveTween(curve: curve);
                                      var tween =
                                          Tween(begin: begin, end: end)
                                              .chain(curveTween);
                                      var offsetAnimation =
                                          animation.drive(tween);
                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
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
              ),

            ],
          ),
          Container(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 355,
                  child: Consumer<PlaylistProvider>(
                    builder: (context, playlistProvider, child) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: playlistProvider.playlist.length,
                        itemBuilder: (context, index) {
                          bool isMySongs = nav.playlist[index] == "My Songs";
                          bool Trending = nav.playlist[index] == "Trending";
                          bool Punjabi = nav.playlist[index] == "Punjabi";
                          bool Top10Indian = nav.playlist[index] == "Top10Indian";
                          bool EngRom = nav.playlist[index] == "EngRom";
                          bool isBlank = nav.playlist[index] == "blank";

                          if (!isBlank) {
                            IconData iconData = isMySongs
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.music_albums_fill;

                            return Slidable(
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: ((context) {
                                      if (!isMySongs) {
                                        deletePlaylist(nav.playlist[index]);
                                        setState(() {
                                          nav.playlist
                                              .remove(nav.playlist[index]);
                                          playlistProvider
                                              .updatePlaylist(nav.playlist);
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                    'Cannot delete default playlist "My Songs".'),
                                              ],
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                            backgroundColor: Colors.red
                                                .withAlpha(
                                                1000),
                                            duration: Duration(
                                                seconds:
                                                2),
                                          ),
                                        );
                                      }
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
                                child: (!Trending && !Punjabi && !Top10Indian && !EngRom) ? ListTile(
                                  onTap: () {
                                    setState(() {
                                      PersistentNavBarNavigator.pushNewScreen(
                                        context,
                                        screen: MySongs(
                                            title: nav.playlist[index]),
                                        withNavBar: true,

                                        pageTransitionAnimation: PageTransitionAnimation
                                            .cupertino,
                                      );
                                    });
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
                                    nav.playlist[index],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                ) : Container()
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
        ],
      ),
    ));
  }

  Future<void> deletePlaylist(String playlistName) async {
    var box = await Hive.openBox('playlists');

    List<dynamic> playlistsData = box.get('playlists', defaultValue: []) ?? [];


    List<Map<String, dynamic>> playlists =
        List<Map<String, dynamic>>.from(playlistsData.map(
      (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
    )); // Convert each element to Map<String, dynamic>

    int playlistIndex = playlists.indexWhere((playlist) => playlist['name'] == playlistName); // Find the index of the playlist to be deleted

    if (playlistIndex != -1) {  // Check if the playlist with the given name exists

      playlists.removeAt(playlistIndex); // Remove the playlist from the list

      await box.put('playlists', playlists);  // Save the updated list back to the box

      print('Playlist $playlistName deleted successfully.');
    } else {
      print('Playlist $playlistName not found.');
    }

    await box.close();
  }
}
