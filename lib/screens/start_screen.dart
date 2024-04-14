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

import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:verve/models/album.dart';
import 'package:verve/screens/my_songs.dart';
import 'package:verve/utilities/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/bottom_player.dart';
import '../models/playlist_model.dart';
import '../models/playlists.dart';
import 'album_collection.dart';
import 'new_playlist.dart';
import 'dart:async';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  List<List<dynamic>> rows = [];
  bool isPressed = false;
  bool isBlurred = false;
  double opacity = 1.0;
  double containerPosition = 0.0;
  Map<int, bool?> isPressedMap = {};
  String selectedPlaylist = "";
  final StreamController<List<PlaylistModel>> _playlistVideosController =
      StreamController<List<PlaylistModel>>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  TextEditingController _nameController = TextEditingController();
  List<Video> playlistVideos = [];
  String name = "Guest";
  bool track1 = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  void _onScrollEvent() {
    _scrollController.jumpTo(_scrollController2.offset);
    track1 = true;
  }

  @override
  void initState() {
    //getSavedPlaylists();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _scrollController2.addListener(_onScrollEvent);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _controller.dispose();
    _scrollController2.dispose();
    _playlistVideosController.close();
    super.dispose();
  }

  getSavedPlaylists() async {
    final box = await Hive.openBox('savedPlaylist');
    print("##########################");
    print("##########################");
    print("##########################");

    List<String> urls = await box.get('urls') ?? <String>[];
    List<String> names = await box.get('names') ?? <String>[];
    print("urls : $urls");
    print("names : $names");
    fetchData(urls);

    //List<String> urls = [];
    //List<String> names = [];
    //await box.put('urls', urls);
    //await box.put('names', names);
  }

  getName() async {
    final box = await Hive.openBox('User');
    var x = box.get('name').toString();
    setState(() {
      name = x;
    });
  }

  setName(String name) async {
    final model = context.read<BottomPlayerModel>();
    final box = await Hive.openBox('User');
    box.put('name', name);
    setState(() {
      model.user = name;
    });
  }

  void updateRetain(String songTitle, String artist, String thumb,
      String audPath, String tempUrl) async {
    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', audPath);
    box.put('tempUrl', tempUrl);
  }

  getRandomNumber(int min, int max) {
    Random random = Random();
    // Generate a random number within the specified range
    int randomNumber = min + random.nextInt(max - min + 1);
    return randomNumber;
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

      List<PlaylistModel> videoModels = await videoList.map((video) {
        return PlaylistModel(
          id: video.id.toString(),
          title: video.title,
          author: video.author,
          url: video.thumbnails.highResUrl,
        );
      }).toList();

      for (PlaylistModel playlistModel in videoModels) {
        // Access the url property of each PlaylistModel object
        nav.url.add(playlistModel.url);

        //print(url);
        // Do something with the url...
      }

      _playlistVideosController.add(videoModels);
      rows.add(videoModels);
      setState(() {
        model.rows = rows;
      });
      //print("Rows: $rows");
    }
    yt.close();
  }

  Future<void> makePlaylist(String playlistName) async {
    final nav = Provider.of<Playlists>(context, listen: false);
    var playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);

    try {
      final box = await Hive.openBox('playlists');
      List<dynamic> playlists = box.get('playlists', defaultValue: []);
      bool playlistExists =
          playlists.any((playlist) => playlist['name'] == playlistName);

      if (!playlistExists) {
        setState(() {
          nav.playlist.add(playlistName);
          playlistProvider.updatePlaylist(nav.playlist);
        });

        // Add the new playlist
        playlists.add({'name': playlistName, 'songs': [], 'about': ''});
        await box.put('playlists', playlists);
        await box.close();
        print('Playlist $playlistName created successfully.');
      } else {
        print('Playlist $playlistName already exists.');
      }
    } catch (e) {
      print("Error accessing Hive box: $e");
    }
  }

  Future<void> setRecomendations(
      String playlistName, int NumOfItems, String playlistId) async {
    var yt = YoutubeExplode();
    var playlist = await yt.playlists.get(playlistId);
    String about = playlist.description;
    List playlistVideos =
        await yt.playlists.getVideos(playlist.id).take(NumOfItems).toList();
    var playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    final nav = Provider.of<Playlists>(context, listen: false);
    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    // Find the playlist
    var mySongsPlaylist = storedPlaylists.firstWhere(
      (playlist) => playlist['name'] == playlistName,
      orElse: () => {
        'name': playlistName,
        'songs': [],
        'about': '',
      },
    );

    // Check if the playlist name is not already in nav.playlist
    setState(() {
      if (!nav.playlist.contains(playlistName)) {
        nav.playlist.add(playlistName);
        playlistProvider.updatePlaylist(nav.playlist);
      }
    });

    mySongsPlaylist['about'] = about;

    List<dynamic> songs = mySongsPlaylist['songs'];

    // Check if the song with the same ID is already in the playlist

    for (int i = 0; i < NumOfItems; i++) {
      var song = playlistVideos[i];

      if (!songs.any((s) => s['vId'] == song.id.toString())) {
        songs.add({
          'songTitle': song.title.toString(),
          'songAuthor': song.author.toString(),
          'tUrl': "https://img.youtube.com/vi/${song.id}/hqdefault.jpg",
          'vId': song.id.toString(),
          'thumbnail': "",
          'date': "",
        });
      }
    }

    box.put('playlists', storedPlaylists);
    //rows.add(storedPlaylists);
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

            style: TextStyle(color: Colors.white60,fontSize: 14),

            onChanged: (value) {
              url = value;
              //print("Url: $url");
            },
            decoration: InputDecoration(
              labelText: 'Youtube playlist url',
              labelStyle: TextStyle(color: Colors.white),
            ),
            //style: TextStyle(color: Colors.white60),
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

  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
    print(model.isCardVisible);
    _controller.forward();
    final nav = context.watch<PlaylistProvider>();
    //var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    //final ABmodel = context.read<AlbumModel>();

    //print("#####################: ${model.rows}");
    //var pp = Provider.of<PlaylistProvider>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.443;
    double containerHeight = containerWidth / 3.6;
    //print("Container height = $containerHeight");

    double checkNumber(int number) {
      if (number == 1) {
        //print("return 1");
        return 1;
      } else if (number == 0) {
        //print("return 0");
        return 0;
      } else if (number % 2 != 0) { // odd
        //print("return ${(number + 1) / 2}");
        return (number + 1) / 2;
      } else { // even
        //print("return ${number / 2}");
        return number / 2;
      }
    }


    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.black.withOpacity(.96)],
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
                //nav.local_playlists.length % 2 != 0 ? nav.local_playlists.length + 1 : nav.local_playlists.length
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 200 + ((containerHeight + 11) * checkNumber(nav.local_playlists.length)),
                    //nav.local_playlists.length == 0 ? 250 : ((nav.local_playlists.length%2) == 1 ? (nav.local_playlists.length/2)*(170) : (nav.local_playlists.length+1)/2) * (170),
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
                        //("Main section height: ${((containerHeight + 10) * checkNumber(nav.local_playlists.length))}");
                        return FlexibleSpaceBar(
                          background: GestureDetector(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 60,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                model.user,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0, left: 5),
                                                child: GestureDetector(
                                                    onTap: () {
                                                      _showEditDialog(
                                                          model.user);
                                                    },
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Colors.grey,
                                                      size: 17,
                                                    )),
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
                                          GestureDetector(
                                            onTap: () {
                                              _showPlaylistImporter();
                                            },
                                            child: Icon(
                                              CupertinoIcons.arrow_down_square,
                                              color: Colors.orange,
                                              size: 29,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, top: 10),
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
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    spreadRadius: .1,
                                                    blurRadius: 6.0,
                                                    offset: Offset(2, 9),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                      fontSize: 17,
                                                      color: Colors.white),
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
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    spreadRadius: .1,
                                                    blurRadius: 6.0,
                                                    offset: Offset(2, 9),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.grey[900],
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Music',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white),
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
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    spreadRadius: .1,
                                                    blurRadius: 6.0,
                                                    offset: Offset(2, 9),
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.grey[900],
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Podcasts',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white),
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
                                  padding: const EdgeInsets.only(
                                      left: 12.0, right: 12),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 4, left: 4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                PersistentNavBarNavigator.pushNewScreen(
                                                  context,
                                                  screen: MySongs(title: "My Songs"), withNavBar: true,
                                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,);
                                              },
                                              child: Container(
                                                height: containerHeight,
                                                width: containerWidth,
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        spreadRadius: .1,
                                                        blurRadius: 6.0,
                                                        offset: Offset(2, 9),
                                                      ),
                                                    ],
                                                    color: Colors.grey[850],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              Colors.grey,
                                                              Colors
                                                                  .grey.shade700
                                                            ]),
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .heart_fill,
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
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            child: Text(
                                                                "My Songs",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) {
                                                      return const NewPlaylist();
                                                    },
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      const begin =
                                                          Offset(0.0, 1.0);
                                                      const end = Offset.zero;
                                                      const curve =
                                                          Curves.easeInOut;
                                                      var curveTween =
                                                          CurveTween(
                                                              curve: curve);
                                                      var tween = Tween(
                                                              begin: begin,
                                                              end: end)
                                                          .chain(curveTween);
                                                      var offsetAnimation =
                                                          animation
                                                              .drive(tween);
                                                      return SlideTransition(
                                                        position:
                                                            offsetAnimation,
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
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        spreadRadius: .1,
                                                        blurRadius: 6.0,
                                                        offset: Offset(2, 9),
                                                      ),
                                                    ],
                                                    color: Colors.grey[850],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[400],
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 6,
                                                                bottom: 7,
                                                                right: 11,
                                                                left: 6),
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      400],
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            5),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            5),
                                                                  ),
                                                                  image: const DecorationImage(
                                                                      image: AssetImage(
                                                                          'assets/new_playlist.png'),
                                                                      fit: BoxFit
                                                                          .cover)),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 90,
                                                            child: Text(
                                                              "New Playlist",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
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

                                      Container(
                                        //color: Colors.red,
                                        height: (containerHeight + 12) * checkNumber(nav.local_playlists.length),/*10 is spacing between the playlist in a column*/
                                        //((nav.local_playlists.length == 0 ? 1 : nav.local_playlists.length)/ 2) * (125),
                                        width: MediaQuery.of(context).size.width,
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: (nav.local_playlists.length / 2).ceil(),
                                          itemBuilder: (context, index) {
                                            //print("sub section height: ${((containerHeight + 10) * checkNumber(nav.local_playlists.length))}");
                                            final int firstItemIndex =
                                                index * 2;
                                            final int secondItemIndex =
                                                index * 2 + 1;
                                            bool mys = nav.local_playlists[index] == 'My Songs';
                                            bool bs = nav.local_playlists[index] == 'songs';
                                            //print("${nav.local_playlists[index]}");
                                              return !mys && !bs ? Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    top:10,
                                                    left: 4,
                                                    right: 4),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                      GestureDetector(
                                                        onLongPress: () {
                                                          setState(() {
                                                            selectedPlaylist = nav.local_playlists[firstItemIndex];

                                                            isBlurred = !isBlurred;

                                                            isPressedMap[firstItemIndex] = !(isPressedMap[firstItemIndex] ?? false);
                                                          });
                                                        },
                                                        onTap: () async {
                                                          selectedPlaylist = nav.local_playlists[firstItemIndex];

                                                          final ABmodel = Provider.of<AlbumModel>(context, listen: false);
                                                          //await _updateAlbumBgColor("model.rows[index][1].url");
                                                          getLocalPlaylistData(index);
                                                          setState(() {
                                                            ABmodel.ab1 = 'https://d1nhio0ox7pgb.cloudfront.net/_img/g_collection_png/standard/512x512/leaf.png';
                                                            ABmodel.ab2 = 'https://d1nhio0ox7pgb.cloudfront.net/_img/g_collection_png/standard/512x512/leaf.png';
                                                            ABmodel.ab3 = 'https://d1nhio0ox7pgb.cloudfront.net/_img/g_collection_png/standard/512x512/leaf.png';
                                                            ABmodel.ab4 = 'https://d1nhio0ox7pgb.cloudfront.net/_img/g_collection_png/standard/512x512/leaf.png';
                                                            ABmodel.playlistLength = 3;
                                                          });
                                                          //print("Selected Playlist:$selectedPlaylist");

                                                          PersistentNavBarNavigator.pushNewScreen(
                                                            context,
                                                            screen: MySongs(title: selectedPlaylist), withNavBar: true,
                                                            pageTransitionAnimation: PageTransitionAnimation.cupertino,);
                                                        },
                                                        child:
                                                        AnimatedContainer(
                                                          duration: Duration(
                                                              milliseconds:
                                                              200),
                                                          height: (isPressedMap[
                                                          firstItemIndex] ??
                                                              false)
                                                              ? 40
                                                              : containerHeight,
                                                          width: (isPressedMap[
                                                          firstItemIndex] ??
                                                              false)
                                                              ? containerWidth -
                                                              20
                                                              : containerWidth,
                                                          curve: Curves
                                                              .easeInOut,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(0.3),
                                                                    spreadRadius:
                                                                    .1,
                                                                    blurRadius:
                                                                    6.0,
                                                                    offset: Offset(
                                                                        2,
                                                                        9),
                                                                  ),
                                                                ],
                                                                color: Colors
                                                                    .grey[
                                                                850],
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    5)),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  height:
                                                                  50,
                                                                  width: 50,
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius.only(
                                                                      topLeft:
                                                                      Radius.circular(5),
                                                                      bottomLeft:
                                                                      Radius.circular(5),
                                                                    ),
                                                                    gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                          Colors.grey,
                                                                          Colors.grey.shade700
                                                                        ]),
                                                                  ),
                                                                  child:
                                                                  const Center(
                                                                    child:
                                                                    Icon(
                                                                      CupertinoIcons
                                                                          .music_albums_fill,
                                                                      color:
                                                                      Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Center(
                                                                  child:
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                        100,
                                                                        child:
                                                                        Text(
                                                                          nav.local_playlists[firstItemIndex],
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
                                                      child: secondItemIndex <
                                                          nav.local_playlists
                                                              .length
                                                          ? GestureDetector(
                                                        onLongPress:
                                                            () {
                                                          setState(() {
                                                                selectedPlaylist = nav.local_playlists[secondItemIndex];

                                                                isBlurred = !isBlurred;

                                                                isPressedMap[secondItemIndex] = !(isPressedMap[secondItemIndex] ?? false);
                                                              });
                                                        },
                                                        onTap: () {
                                                          setState(
                                                                  () {
                                                                PersistentNavBarNavigator
                                                                    .pushNewScreen(
                                                                  context,
                                                                  screen: MySongs(
                                                                      title:
                                                                      nav.local_playlists[secondItemIndex]),
                                                                  withNavBar:
                                                                  true,
                                                                  pageTransitionAnimation:
                                                                  PageTransitionAnimation.cupertino,
                                                                );
                                                              });
                                                        },
                                                        child:
                                                        AnimatedContainer(
                                                          duration: Duration(
                                                              milliseconds:
                                                              200),
                                                          width: (isPressedMap[secondItemIndex] ??
                                                              false)
                                                              ? containerWidth -
                                                              20
                                                              : containerWidth,
                                                          height: (isPressedMap[secondItemIndex] ??
                                                              false)
                                                              ? 30
                                                              : containerHeight,
                                                          curve: Curves
                                                              .easeInOut,
                                                          child:
                                                          Container(
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black.withOpacity(0.3),
                                                                    spreadRadius: .1,
                                                                    blurRadius: 6.0,
                                                                    offset: Offset(2, 9),
                                                                  ),
                                                                ],
                                                                color: Colors.grey[
                                                                850],
                                                                borderRadius:
                                                                BorderRadius.circular(5)),
                                                            child:
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  height:
                                                                  50,
                                                                  width:
                                                                  50,
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(5),
                                                                      bottomLeft: Radius.circular(5),
                                                                    ),
                                                                    gradient: LinearGradient(colors: [
                                                                      Colors.grey,
                                                                      Colors.grey.shade700
                                                                    ]),
                                                                  ),
                                                                  child:
                                                                  const Center(
                                                                    child: Icon(
                                                                      CupertinoIcons.music_albums_fill,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width:
                                                                  20,
                                                                ),
                                                                Center(
                                                                  child:
                                                                  Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width: 100,
                                                                        child: Text(
                                                                          nav.local_playlists[secondItemIndex],
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
                                              ) : Container();

                                          },
                                        )
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
              body: buildRow(),
              /*ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Consumer<BottomPlayerModel>(
                    builder: (context, model, _) {
                      return Container(
                        height: model.rows.length * 280,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          controller: _scrollController2,
                          scrollDirection: Axis.vertical,
                          itemCount: model.rows.length,
                          itemBuilder: (context, rowIndex) {
                            print("model inf: ${model.rows}");
                            return buildRow(model.rows[rowIndex]);
                          },
                        ),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //Provider.of<BottomPlayerModel>(context, listen: false).addNewRow();
                    },
                    child: Text('Add New Row'),
                  ),
                ],
              ),*/
            ),
            /*
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15, bottom: 10),
                    child: Text(
                      "Top 100 in India",
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Container(
                    height: 195,
                    child: FutureBuilder<List<Map<String, Object>>>(
                      future: accessPlaylist('Top10Indian'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return  Container();
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white),
                          );
                        } else {
                          List<Map<String, Object>>? playlistDetails =
                              snapshot.data;
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: playlistDetails?.length,
                            itemBuilder: (context, index) {
                              Map<String, Object>? songDetails =
                              playlistDetails?[index];

                              return Padding(
                                padding: EdgeInsets.only(right: 0, left: 11),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await _updateAlbumBgColor('https://img.youtube.com/vi/${songDetails['vId'].toString()}/sddefault.jpg');
                                        setState(() {
                                          ABmodel.ab1 = 'https://img.youtube.com/vi/${playlistDetails?[getRandomNumber(0, playlistDetails.length)]['vId']}/sddefault.jpg';
                                          ABmodel.ab2 = 'https://img.youtube.com/vi/${playlistDetails?[getRandomNumber(0, playlistDetails.length)]['vId']}/sddefault.jpg';
                                          ABmodel.ab3 = 'https://img.youtube.com/vi/${playlistDetails?[getRandomNumber(0, playlistDetails.length)]['vId']}/sddefault.jpg';
                                          ABmodel.ab4 = 'https://img.youtube.com/vi/${playlistDetails?[getRandomNumber(0, playlistDetails.length)]['vId']}/sddefault.jpg';
                                          ABmodel.playlistName = 'Top10Indian';
                                          print("Start Screen: ${ playlistDetails!.length}");
                                          ABmodel.playlistLength = playlistDetails.length;
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
                                          screen: AlbumCollection(),
                                          withNavBar: true,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation
                                                  .cupertino,
                                        );
                                      },
                                      child: FadeTransition(
                                        opacity: _animation,
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            //color: Colors.grey.shade900,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: CachedNetworkImageProvider(
                                                songDetails!['tUrl'].toString(),

                                              ),
                                              customSize: Size(280, 280),
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
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          songDetails['songTitle'].toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Center(
                                        child: Text(
                                          songDetails['songAuthor']
                                              .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              overflow:
                                                  TextOverflow.ellipsis),
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
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "Latest Punjabi",
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          CupertinoIcons.waveform,
                          color: Colors.grey.shade700,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 195,
                    child: FutureBuilder<List<Map<String, Object>>>(
                      future: accessPlaylist('Punjabi'),
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

                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: playlistDetails?.length,
                            itemBuilder: (context, index) {
                              Map<String, Object>? songDetails =
                                  playlistDetails?[index];

                              return Padding(
                                padding: EdgeInsets.only(right: 0, left: 11),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await _updateAlbumBgColor(
                                            songDetails['tUrl'].toString());
                                        setState(() {
                                          ABmodel.ab1 =
                                              'https://img.youtube.com/vi/${playlistDetails![getRandomNumber(0, playlistDetails.length)]['vId']}/hqdefault.jpg';
                                          ABmodel.ab2 =
                                              'https://img.youtube.com/vi/${playlistDetails[4]['vId']}/hqdefault.jpg';
                                          ABmodel.ab3 =
                                              'https://img.youtube.com/vi/${playlistDetails[6]['vId']}/hqdefault.jpg';
                                          ABmodel.ab4 =
                                              'https://img.youtube.com/vi/${playlistDetails[8]['vId']}/hqdefault.jpg';
                                          ABmodel.playlistName = 'Punjabi';
                                          ABmodel.playlistLength = playlistDetails.length;
                                          ABmodel.albumName =
                                              "Latest Punjabi releases";
                                        });
                                        //updateRetain(songDetails['songTitle'].toString(), songDetails['songAuthor'].toString(), songDetails['tUrl'].toString(), songDetails['vId'].toString(), songDetails['tUrl'].toString());
                                        PersistentNavBarNavigator
                                            .pushNewScreen(
                                          context,
                                          screen: AlbumCollection(),
                                          withNavBar: true,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation
                                                  .cupertino,
                                        );
                                      },
                                      child: FadeTransition(
                                        opacity: _animation,
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: CachedNetworkImageProvider(
                                                songDetails!['tUrl'].toString(),

                                              ),
                                              customSize: Size(280, 280),
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
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          songDetails['songTitle'].toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Center(
                                        child: Text(
                                          songDetails['songAuthor']
                                              .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              overflow:
                                                  TextOverflow.ellipsis),
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
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "Trending today",
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          CupertinoIcons.graph_circle,
                          color: Colors.grey.shade700,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 195,
                    child: FutureBuilder<List<Map<String, Object>>>(
                      future: accessPlaylist('Trending'),
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
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: playlistDetails?.length,
                            itemBuilder: (context, index) {
                              Map<String, Object>? songDetails =
                                  playlistDetails?[index];

                              return Padding(
                                padding: EdgeInsets.only(right: 0, left: 11),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await _updateAlbumBgColor(
                                            songDetails['tUrl'].toString());
                                        setState(() {
                                          ABmodel.ab1 =
                                              'https://img.youtube.com/vi/${playlistDetails?[getRandomNumber(0, playlistDetails.length)]['vId']}/hqdefault.jpg';
                                          ABmodel.ab2 =
                                              'https://img.youtube.com/vi/${playlistDetails?[4]['vId']}/hqdefault.jpg';
                                          ABmodel.ab3 =
                                              'https://img.youtube.com/vi/${playlistDetails?[6]['vId']}/hqdefault.jpg';
                                          ABmodel.ab4 =
                                              'https://img.youtube.com/vi/${playlistDetails?[8]['vId']}/hqdefault.jpg';
                                          ABmodel.playlistName = 'Trending';
                                          ABmodel.albumName =
                                              "Top Trending Worldwide";
                                          ABmodel.playlistLength = playlistDetails!.length;

                                          /*ABmodel.tUrl =
                                              songDetails['tUrl'].toString();
                                          ABmodel.currentTitle =
                                              songDetails['songTitle']
                                                  .toString();
                                          ABmodel.currentAuthor =
                                              songDetails['songAuthor']
                                                  .toString();
                                          ABmodel.vId =
                                              songDetails['vId'].toString();
                                          ABmodel.about =
                                              songDetails['about'].toString();*/
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
                                          screen: AlbumCollection(),
                                          withNavBar: true,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation
                                                  .cupertino,
                                        );
                                      },
                                      child: FadeTransition(
                                        opacity: _animation,
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: CachedNetworkImageProvider(
                                                songDetails!['tUrl'].toString(),

                                              ),
                                              customSize: Size(280, 280),
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
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          songDetails['songTitle'].toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Center(
                                        child: Text(
                                          songDetails['songAuthor']
                                              .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              overflow:
                                                  TextOverflow.ellipsis),
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
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "Top Romantic Hits",
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          CupertinoIcons.graph_circle,
                          color: Colors.grey.shade700,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 195,
                    child: FutureBuilder<List<Map<String, Object>>>(
                      future: accessPlaylist('EngRom'),
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
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: playlistDetails?.length,
                            itemBuilder: (context, index) {
                              Map<String, Object>? songDetails =
                                  playlistDetails?[index];

                              return Padding(
                                padding: EdgeInsets.only(right: 0, left: 11),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await _updateAlbumBgColor(
                                            songDetails['tUrl'].toString());
                                        setState(() {
                                          ABmodel.ab1 =
                                              'https://img.youtube.com/vi/${playlistDetails?[getRandomNumber(0, playlistDetails.length)]['vId']}/hqdefault.jpg';
                                          ABmodel.ab2 =
                                              'https://img.youtube.com/vi/${playlistDetails?[4]['vId']}/hqdefault.jpg';
                                          ABmodel.ab3 =
                                              'https://img.youtube.com/vi/${playlistDetails?[6]['vId']}/hqdefault.jpg';
                                          ABmodel.ab4 =
                                              'https://img.youtube.com/vi/${playlistDetails?[8]['vId']}/hqdefault.jpg';
                                          ABmodel.playlistName = 'EngRom';
                                          ABmodel.albumName =
                                              "Romatic hits of all time";
                                          ABmodel.playlistLength = playlistDetails!.length;

                                          /*ABmodel.tUrl =
                                              songDetails['tUrl'].toString();
                                          ABmodel.currentTitle =
                                              songDetails['songTitle']
                                                  .toString();
                                          ABmodel.currentAuthor =
                                              songDetails['songAuthor']
                                                  .toString();
                                          ABmodel.vId =
                                              songDetails['vId'].toString();
                                          ABmodel.about =
                                              songDetails['about'].toString();*/
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
                                          screen: AlbumCollection(),
                                          withNavBar: true,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation
                                                  .cupertino,
                                        );
                                      },
                                      child: FadeTransition(
                                        opacity: _animation,
                                        child: Container(
                                          width: 150.0,
                                          height: 150.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: PhotoView(
                                              imageProvider: CachedNetworkImageProvider(
                                                songDetails!['tUrl'].toString(),
                                              ),
                                              customSize: Size(280, 280),
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
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          songDetails['songTitle'].toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Center(
                                        child: Text(
                                          songDetails['songAuthor']
                                              .toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              overflow:
                                                  TextOverflow.ellipsis),
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
                  SizedBox(
                    height: 90,
                  ),*/
            isBlurred ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ) : Container(),
            isBlurred ? Center(
                    child: SafeArea(
                      child: Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 280.0),
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 30, right: 30),
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
                                deletePlaylist(selectedPlaylist);
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
                  ) : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildRow() {
    final playlistProvider = context.read<PlaylistProvider>();
    return Consumer<BottomPlayerModel>(
      builder: (context, model, child) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: playlistProvider.youtube_playlists.length,
          itemBuilder: (context, index) {
            index = playlistProvider.youtube_playlists.length-index-1;
            List<String> names = playlistProvider.youtube_playlists;
            final ABmodel = context.watch<AlbumModel>();
            List<dynamic> items = model.rows[ index];
            String name = names[index];
            return GestureDetector(
              onTap: () async {
                await _updateAlbumBgColor(model.rows[index][Random.secure().nextInt(3)].url);
                setState(() {
                  ABmodel.ab1 = model.rows[index][0].url;
                  ABmodel.ab2 = model.rows[index][1].url;
                  ABmodel.ab3 = model.rows[index][2].url;
                  ABmodel.ab4 = model.rows[index][3].url;
                  ABmodel.playlistLength = model.rows[index].length;
                });

                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AlbumCollection(index), withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 10.0, left: 4, right: 4,top: 5),
                child: Container(
                  height: 260 ,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(name,style: TextStyle(
                            color: Colors.white,
                            fontSize: 22
                        ),maxLines: 1,
                        ),
                      ),
                      Consumer<PlaylistProvider>(
                        builder: (context, playlistProvider, child) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              //color: Colors.white,// Adjust the height as needed
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                itemCount: items.length,
                                itemBuilder: (context, index) {

                                  //final video = items[index];
                                  // Check if the video has the 'url' property

                                  //print("running${playlistProvider.url.length}");
                                  return Padding(
                                    padding: EdgeInsets.only(right: 0, left: 11),
                                    child: Column(
                                      children: [
                                        FadeTransition(
                                          opacity: _animation,
                                          child: Container(
                                            width: 150.0,
                                            height: 150.0,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: PhotoView(
                                                imageProvider: CachedNetworkImageProvider(
                                                  items[index].url,
                                                ),
                                                customSize: Size(280, 280),
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
                                          height: 3,
                                        ),
                                        Container(
                                          width: 150,
                                          child: Center(
                                            child: Text(
                                              items[index].title,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Center(
                                            child: Text(
                                              items[index].author,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  return SizedBox(); // Return an empty SizedBox if 'url' is not available
                                },
                              ),

                            ),
                          );},
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

  }

  Future<void> _updateAlbumBgColor(String thumbnailUrl) async {
    final ABmodel = context.read<AlbumModel>();
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));

    setState(() {
      ABmodel.cardBackgroundColor = paletteGenerator.dominantColor!.color;
    });
  }

  void _showEditDialog(String Name) {
    _nameController.text = Name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.orange.shade800,
          title: Text(
            'Edit Name',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Enter your name',
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
                setState(() {
                  setName(_nameController.text.toString());
                });
                Navigator.of(context).pop();
              },
              child: Container(
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Future<void> deletePlaylist(String playlistName) async {
    var box = await Hive.openBox('playlists');
    final nav = Provider.of<PlaylistProvider>(context, listen: false);
    List<dynamic> playlistsData = box.get('playlists', defaultValue: []) ?? [];

    List<Map<String, dynamic>> playlists =
    List<Map<String, dynamic>>.from(playlistsData.map(
          (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
    ));

    int playlistIndex =
    playlists.indexWhere((playlist) => playlist['name'] == playlistName);

    if (playlistIndex != -1) {
      playlists.removeAt(playlistIndex);
      nav.local_playlists.removeAt(playlistIndex);
      await box.put('playlists', playlists);
    } else {
      print('Playlist $playlistName not found.');
    }

    await box.close();
  }


  getLocalPlaylistData(int index) async {
    final box = await Hive.openBox('savedPlaylist');
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    List<String> local_names = await box.get('local_names') ?? <String>[];
    List<List<String>> songs = await box.get('songs') ?? <String>[];

    final model = context.read<BottomPlayerModel>();
    model.local_rows = songs[index];


  }
}
