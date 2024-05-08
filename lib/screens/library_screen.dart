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


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:verve/screens/playlist_screen.dart';
import 'package:verve/screens/premium_screen.dart';
import 'package:verve/screens/search_screen.dart';
import 'package:verve/screens/start_screen.dart';
import 'package:verve/screens/yt_playlist_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/album.dart';
import '../models/bottom_player.dart';
import '../models/playlist_model.dart';
import '../models/playlists.dart';
import '../utilities/playlist_provider.dart';
import 'album_collection.dart';
import 'my_songs.dart';
import 'new_playlist.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  List<List<dynamic>> rows = [];
  final StreamController<List<SongModel>> _playlistVideosController =
  StreamController<List<SongModel>>();

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    _playlistVideosController.close();
    super.dispose();
  }

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
                            _controller.index == 0 ? GestureDetector(
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Center(
                                          child: Text(
                                            'Created playlist successfully!',
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
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 43,
                              ),
                            ) : GestureDetector(
                              onTap: () {
                                _showPlaylistImporter();
                              },
                              child: Icon(
                                CupertinoIcons.arrow_down_square,
                                color: Colors.orange,
                                size: 35,
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
              Container(
                height: 2,
                color: Colors.grey.shade700,
              ),
              Container(
                height: MediaQuery.of(context).size.height-255,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      color: Colors.black,
                      child: PersistentTabView(
                        context,
                        controller: _controller,
                        screens: _buildScreens(),
                        items: _navBarsItems(),
                        confineInSafeArea: true,
                        handleAndroidBackButtonPress: true,
                        resizeToAvoidBottomInset: true,
                        stateManagement: true,
                        hideNavigationBarWhenKeyboardShows: true,
                        popAllScreensOnTapOfSelectedTab: true,
                        popActionScreens: PopActionScreensType.all,
                        itemAnimationProperties: ItemAnimationProperties(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.ease,
                        ),
                        screenTransitionAnimation: ScreenTransitionAnimation(
                          animateTabTransition: true,
                          curve: Curves.ease,
                          duration: Duration(milliseconds: 200),
                        ),
                        navBarStyle: NavBarStyle.style12,
                      ),
                    ),
                    Expanded(
                      child: _buildScreens()[_controller.index], // Display current screen based on index
                    ),
                  ],
                ),
              ),
            ],
          ),
          /*Container(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 355,
                  child: Consumer<PlaylistProvider>(
                    builder: (context, playlistProvider, child) {
                      final model = context.read<BottomPlayerModel>();
                      final ABmodel = context.watch<AlbumModel>();
                      print(playlistProvider.playlist.length);
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: model.rows.length+2,
                        itemBuilder: (context, index) {
                          bool isMySongs = nav.playlist[index] == "My Songs";
                          bool isBlank = nav.playlist[index] == "blank";
                          final video = model.rows[index == 0 || index == 1 ? 0 : index-2];
                          print("Model rows: ${model.rows.length}");

                          if (!isBlank) {
                            IconData iconData = isMySongs
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.music_albums_fill;
                            print("Index: $index");


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
                                child: ListTile(
                                  onTap: () async {
                                    await _updateAlbumBgColor(video[index].url);
                                    setState(() {
                                      ABmodel.ab1 = video[0].url;
                                      ABmodel.ab2 = video[1].url;
                                      ABmodel.ab3 = video[2].url;
                                      ABmodel.ab4 = video[3].url;
                                      ABmodel.playlistName = 'Top10Indian';
                                      //print("Start Screen: ${ playlistDetails!.length}");
                                      ABmodel.playlistLength = model.rows.length;
                                      ABmodel.albumName = "India's Top Trending";

                                      //ABmodel.currentTitle = songDetails['songTitle'].toString();
                                      //ABmodel.currentAuthor = songDetails['songAuthor'].toString();

                                      //ABmodel.vId = songDetails['vId'].toString();
                                      //ABmodel.about = songDetails['about'].toString();
                                      //ABmodel.tUrl = songDetails['tUrl'].toString();

                                    });

                                    /*updateRetain(
                                            songDetails['songTitle']
                                                .toString(),
                                            songDetails['songAuthor']
                                                .toString(),
                                            songDetails['tUrl'].toString(),
                                            songDetails['vId'].toString(),
                                            songDetails['tUrl'].toString());*/
                                    PersistentNavBarNavigator
                                        .pushNewScreen(
                                      context,
                                      screen: AlbumCollection(index),
                                      withNavBar: true,
                                      pageTransitionAnimation:
                                      PageTransitionAnimation
                                          .cupertino,
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
                                    nav.playlist[index],
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
          ),*/
        ],
      ),
    ),


    );
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
  //////////////////////////////////////////////////////////////////

  List<Widget> _buildScreens() {
    return [
      MyPlaylistsScreen(),
      YouTubePlaylistsScreen(),

    ];
  }

  void _showPlaylistImporter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String url = '';
        return AlertDialog(
          backgroundColor: Colors.orange.shade800,
          title: Text(
            'Import playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            onChanged: (value) {
              url = value;
              //print("Url: $url");
            },
            decoration: InputDecoration(
              labelText: 'Youtube playlist url',
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white60),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                importPlaylist(url);
                Navigator.of(context).pop();
              },
              child: Container(
                child: Text(
                  'Import',
                  style: TextStyle(color: Colors.white, fontSize: 14.8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  importPlaylist(String url) async {
    Uri uri = Uri.parse(url);
    List<String> playlistId = [];
    setState(() {
      playlistId.add(uri.queryParameters['list'].toString());
    });
    await fetchData(playlistId);
  }

  Future<void> fetchData(List<String> urls) async {

    var yt = YoutubeExplode();
    List<String> url = [];
    final nav = Provider.of<PlaylistProvider>(context, listen: false);

    //open box of saved playlist
    final box = await Hive.openBox('savedPlaylist');

    // call model to mutate value
    final model = context.read<BottomPlayerModel>();

    // get the list of saved playlist url from the box
    List<String> savedURLS = await box.get('urls') ?? <String>[];
    List<String> names = await box.get('names') ?? <String>[];

    if (urls.length == 1) {
      var playlist = await yt.playlists.get(urls[0]);
      String playlistName = playlist.title;
      savedURLS.add(urls[0]);
      names.add(playlistName);
      nav.youtube_playlists.add(playlistName);
      await box.put('urls', savedURLS);
      await box.put('names', names);

    }
    for (int i = 0; i < urls.length; i++) {

      var playlist = await yt.playlists.get(urls[i]);
      List<Video> videoList = await yt.playlists.getVideos(playlist.id).toList();

      List<SongModel> songModels = await videoList.map((video) {
        return SongModel(
          id: video.id.toString(),
          title: video.title,
          author: video.author,
          url: video.thumbnails.highResUrl,
          duration: video.duration!.inSeconds,
        );
      }).toList();

      for (SongModel songModel in songModels) {
        // Access the url property of each PlaylistModel object
        nav.url.add(songModel.url);

        print(url);
        // Do something with the url...
      }

      _playlistVideosController.add(songModels);
      rows.add(songModels);
      setState(() {
        model.rows = rows;
      });
      //print("Rows: $rows");
    }
    yt.close();
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text(
                'Imported playlist successfully!',
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
    );*/
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: GestureDetector(
          onTap: (){
            setState(() {
              _controller.index = 0;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Text("My Playlists",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
              ),
            ],
          ),
        ),
        title: ("My Playlists"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,

      ),
      PersistentBottomNavBarItem(
        icon: GestureDetector(
          onTap: (){
            setState(() {
              _controller.index = 1;
            });

          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text("YouTube Playlists",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        title: ("YouTube Playlists"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
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
