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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:verve/models/album.dart';
import 'package:verve/screens/album_screen.dart';
import 'package:verve/screens/my_songs.dart';
import 'package:verve/utilities/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/playlists.dart';
import 'new_playlist.dart';
import 'dart:async';


class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool isPressed = false;
  bool isBlurred = false;
  double opacity = 1.0;
  double containerPosition = 0.0;
  Map<int, bool?> isPressedMap = {};
  String selectedPlaylist = "";
  final ScrollController _scrollController = ScrollController();
  TextEditingController _nameController = TextEditingController();
  List<Video> playlistVideos = [];
  String name = "Guest";

  getName() async {
    final box = await Hive.openBox('User');
    setState(() {
      name = box.get('name');
    });
  }

  setName(String name) async {
    final box = await Hive.openBox('User');
    box.put('name', name);
    getName();
  }

  void updateRetain(String songTitle, String artist, String thumb, String audPath, String tempUrl) async {
    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', audPath);
    box.put('tempUrl', tempUrl);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getName();
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<Playlists>();
    final ABmodel = context.read<AlbumModel>();
    var playlistProvider =
    Provider.of<PlaylistProvider>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.443;
    double containerHeight = containerWidth/3.9;


    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade900,
            Colors.black.withOpacity(.96)
          ],
        ),
      ),
      child: Stack(
        children: [
          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            headerSliverBuilder: (
                BuildContext context,
                bool innerBoxScrolled,
                ) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 230 + (containerHeight * ((playlistProvider.playlist.length - 4) / 2)),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  //pinned: true,
                  toolbarHeight: 65,
                  //floating: true,
                  automaticallyImplyLeading: false,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15,),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Welcome back,",
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(top:5.0,left: 5),
                                              child: GestureDetector(
                                                onTap: (){
                                                  _showEditDialog(name == "" ? "Guest": name);
                                                },
                                                  child: Icon(Icons.edit, color: Colors.grey,size: 17,)),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 29,
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.watch_later_outlined,
                                          color: Colors.white,
                                          size: 29,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:15.0,top: 10),
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 55,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  spreadRadius: .1,
                                                  blurRadius: 6.0,
                                                  offset: Offset(2, 9),
                                                ),
                                              ],
                                              borderRadius: BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.orange,
                                                  Colors.red.withOpacity(.96),
                                                ],
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'All',
                                                style: TextStyle(
                                                    fontSize: 17, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            height: 30,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  spreadRadius: .1,
                                                  blurRadius: 6.0,
                                                  offset: Offset(2, 9),
                                                ),
                                              ],
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.grey[900],
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Music',
                                                style: TextStyle(
                                                    fontSize: 17, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            height: 30,
                                            width: 105,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  spreadRadius: .1,
                                                  blurRadius: 6.0,
                                                  offset: Offset(2, 9),
                                                ),
                                              ],
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.grey[900],
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Podcasts',
                                                style: TextStyle(
                                                    fontSize: 17, color: Colors.white),
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
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0, right: 12),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4, left: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              PersistentNavBarNavigator.pushNewScreen(
                                                context,
                                                screen: MySongs(title: "My Songs"),
                                                withNavBar: true,
                                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                              );
                                            },
                                            child: Container(
                                              height: containerHeight,
                                              width: containerWidth,
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.3),
                                                      spreadRadius: .1,
                                                      blurRadius: 6.0,
                                                      offset: Offset(2, 9),
                                                    ),
                                                  ],
                                                  color: Colors.grey[850],
                                                  borderRadius: BorderRadius.circular(5)),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5),
                                                        bottomLeft: Radius.circular(5),
                                                      ),
                                                      gradient: LinearGradient(colors: [
                                                        Colors.grey,
                                                        Colors.grey.shade700
                                                      ]),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        CupertinoIcons.heart_fill,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          child: Text("My Songs",
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
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
                                                    var curveTween = CurveTween(curve: curve);
                                                    var tween = Tween(begin: begin, end: end)
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
                                            child: Container(
                                              height: containerHeight,
                                              width: containerWidth,
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.3),
                                                      spreadRadius: .1,
                                                      blurRadius: 6.0,
                                                      offset: Offset(2, 9),
                                                    ),
                                                  ],
                                                  color: Colors.grey[850],
                                                  borderRadius: BorderRadius.circular(5)),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[400],
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(5),
                                                        bottomLeft: Radius.circular(5),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 6,
                                                          bottom: 7,
                                                          right: 11,
                                                          left: 6),
                                                      child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey[400],
                                                            borderRadius:
                                                            const BorderRadius.only(
                                                              topLeft: Radius.circular(5),
                                                              bottomLeft: Radius.circular(5),
                                                            ),
                                                            image: const DecorationImage(
                                                                image: AssetImage(
                                                                    'assets/new_playlist.png'),
                                                                fit: BoxFit.cover)),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 90,
                                                          child: Text(
                                                            "New Playlist",
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                              overflow: TextOverflow.ellipsis,
                                                              color: Colors.white,
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: ((playlistProvider.playlist.length -4)  / 2) * (containerHeight),
                                      width: MediaQuery.of(context).size.width,
                                      child: Consumer<PlaylistProvider>(
                                        builder: (context, playlistProvider, child) {
                                          return ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: (playlistProvider.playlist.length / 2).ceil(),
                                            itemBuilder: (context, index) {
                                              final int firstItemIndex = index * 2;
                                              final int secondItemIndex = index * 2 + 1;

                                              bool isMySongs = nav.playlist[firstItemIndex] == "My Songs" ||
                                                  (secondItemIndex < nav.playlist.length &&
                                                      nav.playlist[secondItemIndex] == "My Songs");

                                              bool Trending = nav.playlist[firstItemIndex] == "Trending" ||
                                                  (secondItemIndex < nav.playlist.length &&
                                                      nav.playlist[secondItemIndex] == "Trending");

                                              bool Punjabi = nav.playlist[firstItemIndex] == "Punjabi" ||
                                                  (secondItemIndex < nav.playlist.length &&
                                                      nav.playlist[secondItemIndex] == "Punjabi");

                                              bool Top10Indian = nav.playlist[firstItemIndex] == "Top10Indian" ||
                                                  (secondItemIndex < nav.playlist.length &&
                                                      nav.playlist[secondItemIndex] == "Top10Indian");

                                              bool EngRom = nav.playlist[firstItemIndex] == "EngRom" ||
                                                  (secondItemIndex < nav.playlist.length &&
                                                      nav.playlist[secondItemIndex] == "EngRom");

                                              if (!isMySongs && !Trending && !Punjabi && !Top10Indian && !EngRom) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 10.0, left: 4, right: 4),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onLongPress: () {
                                                            setState(() {
                                                              selectedPlaylist = nav.playlist[firstItemIndex];
                                                              isBlurred = !isBlurred;
                                                              isPressedMap[firstItemIndex] =
                                                              !(isPressedMap[firstItemIndex] ?? false);
                                                            });
                                                          },
                                                          onTap: () {
                                                            setState(() {
                                                              PersistentNavBarNavigator.pushNewScreen(
                                                                context,
                                                                screen: MySongs(title: nav.playlist[firstItemIndex]),
                                                                withNavBar: true,
                                                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                                              );
                                                            });
                                                          },
                                                          child: AnimatedContainer(
                                                            duration: Duration(milliseconds: 200),
                                                            height: (isPressedMap[firstItemIndex] ?? false)
                                                                ? 40
                                                                : containerHeight,
                                                            width: (isPressedMap[firstItemIndex] ?? false)
                                                                ? containerWidth - 20
                                                                : containerWidth,
                                                            curve: Curves.easeInOut,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.3),
                                                                      spreadRadius: .1,
                                                                      blurRadius: 6.0,
                                                                      offset: Offset(2, 9),
                                                                    ),
                                                                  ],
                                                                  color: Colors.grey[850],
                                                                  borderRadius: BorderRadius.circular(5)),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.only(
                                                                        topLeft: Radius.circular(5),
                                                                        bottomLeft: Radius.circular(5),
                                                                      ),
                                                                      gradient: LinearGradient(
                                                                          colors: [Colors.grey, Colors.grey.shade700]),
                                                                    ),
                                                                    child: const Center(
                                                                      child: Icon(
                                                                        CupertinoIcons.music_albums_fill,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Center(
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Container(
                                                                          width: 100,
                                                                          child: Text(
                                                                            nav.playlist[firstItemIndex],
                                                                            textAlign: TextAlign.left,
                                                                            style: TextStyle(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              color: Colors.white,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            maxLines: 1,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: secondItemIndex < nav.playlist.length
                                                            ? GestureDetector(
                                                          onLongPress: () {
                                                            setState(() {
                                                              selectedPlaylist = nav.playlist[secondItemIndex];
                                                              isBlurred = !isBlurred;
                                                              isPressedMap[secondItemIndex] =
                                                              !(isPressedMap[secondItemIndex] ?? false);
                                                            });
                                                          },
                                                          onTap: () {
                                                            setState(() {
                                                              PersistentNavBarNavigator.pushNewScreen(
                                                                context,
                                                                screen: MySongs(title: nav.playlist[secondItemIndex]),
                                                                withNavBar: true,
                                                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                                              );
                                                            });
                                                          },
                                                          child: AnimatedContainer(
                                                            duration: Duration(milliseconds: 200),
                                                            width: (isPressedMap[secondItemIndex] ?? false)
                                                                ? containerWidth - 20
                                                                : containerWidth,
                                                            height: (isPressedMap[secondItemIndex] ?? false)
                                                                ? 30
                                                                : containerHeight,
                                                            curve: Curves.easeInOut,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.3),
                                                                      spreadRadius: .1,
                                                                      blurRadius: 6.0,
                                                                      offset: Offset(2, 9),
                                                                    ),
                                                                  ],
                                                                  color: Colors.grey[850],
                                                                  borderRadius: BorderRadius.circular(5)),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    height: 50,
                                                                    width: 50,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.only(
                                                                        topLeft: Radius.circular(5),
                                                                        bottomLeft: Radius.circular(5),
                                                                      ),
                                                                      gradient: LinearGradient(
                                                                          colors: [Colors.grey, Colors.grey.shade700]),
                                                                    ),
                                                                    child: const Center(
                                                                      child: Icon(
                                                                        CupertinoIcons.music_albums_fill,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Center(
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Container(
                                                                          width: 100,
                                                                          child: Text(
                                                                            nav.playlist[secondItemIndex],
                                                                            textAlign: TextAlign.left,
                                                                            style: TextStyle(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              color: Colors.white,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            maxLines: 1,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                            : Container(),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return Container(padding: EdgeInsets.zero,);
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
                        ),
                      ); // the vanishing upper part
                    },
                  ),
                ),

              ];
            },
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15,bottom: 10),
                      child: Text("Top 100 in India", style: TextStyle(color: Colors.orange.shade600, fontWeight: FontWeight.w700, fontSize: 22,),),
                    ),
                    Container(
                      height: 195,
                      child: FutureBuilder<List<Map<String, Object>>>(
                        future: accessPlaylist('Top10Indian'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}',style: TextStyle(color: Colors.white),);
                          } else {
                            List<Map<String, Object>>? playlistDetails = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: playlistDetails?.length,
                              itemBuilder: (context, index) {
                                Map<String, Object>? songDetails = playlistDetails?[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 0, left: 11),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await _updateAlbumBgColor(songDetails['tUrl'].toString());
                                          setState(() {
                                            ABmodel.tUrl = songDetails['tUrl'].toString();
                                            ABmodel.currentTitle = songDetails['songTitle'].toString();
                                            ABmodel.currentAuthor = songDetails['songAuthor'].toString();
                                            ABmodel.vId = songDetails['vId'].toString();
                                            ABmodel.about = songDetails['about'].toString();
                                          });
                                          updateRetain(songDetails['songTitle'].toString(),songDetails['songAuthor'].toString(),songDetails['tUrl'].toString(),songDetails['vId'].toString(),songDetails['tUrl'].toString());
                                          PersistentNavBarNavigator.pushNewScreen(
                                            context,
                                            screen: AlbumScreen(),
                                            withNavBar: true,
                                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                          );
                                      },
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: NetworkImage(

                                                  songDetails!['tUrl'].toString()
                                              ),
                                              customSize: Size(280, 280),
                                              enableRotation: true,
                                              backgroundDecoration: BoxDecoration(
                                                color: Theme.of(context).canvasColor,
                                              ),

                                            ),
                                          ),

                                        ),
                                      ),
                                      SizedBox(height: 3,),
                                      Container(
                                        width: 150,
                                        child: Center(
                                          child: Text(
                                            songDetails['songTitle'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,overflow: TextOverflow.ellipsis),
                                          ),

                                        ),
                                      ),

                                      Container(
                                        child: Center(
                                          child: Text(
                                            songDetails['songAuthor'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15,bottom: 10),
                      child: Row(
                        children: [
                          Text("Latest Punjabi", style: TextStyle(color: Colors.orange.shade600, fontWeight: FontWeight.w700, fontSize: 20,),),
                          SizedBox(width: 5,),
                          Icon(CupertinoIcons.waveform,color: Colors.grey.shade700,)

                        ],
                      ),
                    ),
                    Container(
                      height: 195,
                      child: FutureBuilder<List<Map<String, Object>>>(
                        future: accessPlaylist('Punjabi'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}',style: TextStyle(color: Colors.white),);
                          } else {
                            List<Map<String, Object>>? playlistDetails = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: playlistDetails?.length,
                              itemBuilder: (context, index) {
                                Map<String, Object>? songDetails = playlistDetails?[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 0, left: 11),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await _updateAlbumBgColor(songDetails['tUrl'].toString());
                                          setState(() {
                                            ABmodel.tUrl = songDetails['tUrl'].toString();
                                            ABmodel.currentTitle = songDetails['songTitle'].toString();
                                            ABmodel.currentAuthor = songDetails['songAuthor'].toString();
                                            ABmodel.vId = songDetails['vId'].toString();
                                            ABmodel.about = songDetails['about'].toString();
                                          });
                                          PersistentNavBarNavigator.pushNewScreen(
                                            context,
                                            screen: AlbumScreen(),
                                            withNavBar: true,
                                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                          );
                                        },
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: NetworkImage(
                                                  songDetails!['tUrl'].toString()
                                              ),
                                              customSize: Size(280, 280),
                                              enableRotation: true,
                                              backgroundDecoration: BoxDecoration(
                                                color: Theme.of(context).canvasColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 3,),
                                      Container(
                                        width: 150,
                                        child: Center(
                                          child: Text(
                                            songDetails['songTitle'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        child: Center(
                                          child: Text(
                                            songDetails['songAuthor'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15,bottom: 10),
                      child: Row(
                        children: [
                          Text("Trending today", style: TextStyle(color: Colors.orange.shade600, fontWeight: FontWeight.w700, fontSize: 20,),),
                          SizedBox(width: 5,),
                          Icon(CupertinoIcons.graph_circle,color: Colors.grey.shade700,)
                        ],
                      ),
                    ),
                    Container(
                      height: 195,
                      child: FutureBuilder<List<Map<String, Object>>>(
                        future: accessPlaylist('Trending'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}',style: TextStyle(color: Colors.white),);
                          } else {
                            List<Map<String, Object>>? playlistDetails = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: playlistDetails?.length,
                              itemBuilder: (context, index) {
                                Map<String, Object>? songDetails = playlistDetails?[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 0, left: 11),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await _updateAlbumBgColor(songDetails['tUrl'].toString());
                                          setState(() {
                                            ABmodel.tUrl = songDetails['tUrl'].toString();
                                            ABmodel.currentTitle = songDetails['songTitle'].toString();
                                            ABmodel.currentAuthor = songDetails['songAuthor'].toString();
                                            ABmodel.vId = songDetails['vId'].toString();
                                            ABmodel.about = songDetails['about'].toString();

                                          });
                                          PersistentNavBarNavigator.pushNewScreen(
                                            context,
                                            screen: AlbumScreen(),
                                            withNavBar: true,
                                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                          );
                                        },
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: NetworkImage(
                                                  songDetails!['tUrl'].toString()
                                              ),
                                              customSize: Size(280, 280),
                                              enableRotation: true,
                                              backgroundDecoration: BoxDecoration(
                                                color: Theme.of(context).canvasColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 3,),
                                      Container(
                                        width: 150,
                                        child: Center(
                                          child: Text(
                                            songDetails['songTitle'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        child: Center(
                                          child: Text(
                                            songDetails['songAuthor'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15,bottom: 10),
                      child: Row(
                        children: [
                          Text("Top Romantic Hits", style: TextStyle(color: Colors.orange.shade600, fontWeight: FontWeight.w700, fontSize: 20,),),
                          SizedBox(width: 5,),
                          Icon(CupertinoIcons.graph_circle,color: Colors.grey.shade700,)
                        ],
                      ),
                    ),
                    Container(
                      height: 195,
                      child: FutureBuilder<List<Map<String, Object>>>(
                        future: accessPlaylist('EngRom'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}',style: TextStyle(color: Colors.white),);
                          } else {
                            List<Map<String, Object>>? playlistDetails = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: playlistDetails?.length,
                              itemBuilder: (context, index) {
                                Map<String, Object>? songDetails = playlistDetails?[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 0, left: 11),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await _updateAlbumBgColor(songDetails['tUrl'].toString());
                                          setState(() {

                                            ABmodel.tUrl = songDetails['tUrl'].toString();
                                            ABmodel.currentTitle = songDetails['songTitle'].toString();
                                            ABmodel.currentAuthor = songDetails['songAuthor'].toString();
                                            ABmodel.vId = songDetails['vId'].toString();
                                            ABmodel.about = songDetails['about'].toString();

                                          });
                                          PersistentNavBarNavigator.pushNewScreen(
                                            context,
                                            screen: AlbumScreen(),
                                            withNavBar: true,
                                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                          );
                                        },
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: NetworkImage(
                                                  songDetails!['tUrl'].toString()
                                              ),
                                              customSize: Size(280, 280),
                                              enableRotation: true,
                                              backgroundDecoration: BoxDecoration(
                                                color: Theme.of(context).canvasColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 3,),
                                      Container(
                                        width: 150,
                                        child: Center(
                                          child: Text(
                                            songDetails['songTitle'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        child: Center(
                                          child: Text(
                                            songDetails['songAuthor'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 90,),
                  ],
                ),
              ),
            ),

          ),
          isBlurred
              ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              color: Colors.transparent,
            ),
          )
              : Container(),
          isBlurred
              ? Center(
            child: SafeArea(
              child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 280.0),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Text(
                              selectedPlaylist,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 120.0),
                        child: GestureDetector(
                          onTap: () {
                            deletePlaylist(selectedPlaylist);
                            setState(() {
                              nav.playlist.remove(selectedPlaylist);
                              playlistProvider
                                  .updatePlaylist(nav.playlist);
                              isBlurred = false;
                              for (int i = 0;
                              i < isPressedMap.length;
                              i++) {
                                isPressedMap[i] = false;
                              }
                            });
                          },
                          child: Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.red.withAlpha(1000),
                                ),
                                Text(
                                  "Delete Playlist",
                                  style: TextStyle(
                                      color: Colors.red.withAlpha(1000),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.only(left: 150.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isBlurred = false;
                              for (int i = 0;
                              i < isPressedMap.length;
                              i++) {
                                isPressedMap[i] = false;
                              }
                            });
                          },
                          child: Container(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_forever_outlined,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              )),
                        ),
                      )
                    ],
                  )),
            ),
          )
              : Container(),
        ],
      ),
    );
  }



  Future<void> _updateAlbumBgColor(String thumbnailUrl) async {

      PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));
      final ABmodel = context.read<AlbumModel>();
      setState(() {
        ABmodel.cardBackgroundColor = paletteGenerator.dominantColor!.color;
      });
  }

  Future<void> fetchData() async {
    var yt = YoutubeExplode();
    var playlist = await yt.playlists.get('PLMC9KNkIncKseYxDN2niH6glGRWKsLtde');
    playlistVideos = await yt.playlists.getVideos(playlist.id).take(1).toList();
    yt.close();
  }

  void _showEditDialog(String Name) {
    _nameController.text = Name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text('Edit Name',style: TextStyle(color: Colors.white),),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Enter your name', labelStyle: TextStyle(color: Colors.white),),
              style: TextStyle(color: Colors.white60),
          ),
          actions: [
            GestureDetector(
              onTap: (){Navigator.of(context).pop();},
              child: Container(
                child: Text('Cancel',style: TextStyle(color: Colors.white),),
              ),
            ),
            SizedBox(width: 5,),
            GestureDetector(
              onTap: (){
                setState(() {
                  setName(_nameController.text.toString());
                });
                Navigator.of(context).pop();
              },
              child: Container(
                child: Text('Save',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],

        );
      },
    );
  }

  Future<void> deletePlaylist(String playlistName) async {

    var box = await Hive.openBox('playlists');

    List<dynamic> playlistsData = box.get('playlists', defaultValue: []) ?? [];

    List<Map<String, dynamic>> playlists =
    List<Map<String, dynamic>>.from(playlistsData.map(
          (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
    ));

    int playlistIndex =
    playlists.indexWhere((playlist) => playlist['name'] == playlistName);

    if (playlistIndex != -1) {
      playlists.removeAt(playlistIndex);
      await box.put('playlists', playlists);
    } else {
      print('Playlist $playlistName not found.');
    }

    await box.close();
  }

  Future<List<Map<String, Object>>> accessPlaylist(String targetPlaylistName) async {
    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var targetPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == targetPlaylistName,
      orElse: () => <String, Object>{},
    );

      box.put('about', targetPlaylist['about']) ;

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

}
