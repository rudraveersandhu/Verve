import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:verve/screens/start_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/album.dart';
import '../models/bottom_player.dart';
import '../models/playlist_model.dart';
import '../models/playlists.dart';
import '../utilities/playlist_provider.dart';
import 'album_collection.dart';

class YouTubePlaylistsScreen extends StatefulWidget {
  YouTubePlaylistsScreen({super.key});

  @override
  State<YouTubePlaylistsScreen> createState() => _YouTubePlaylistsScreenState();
}

class _YouTubePlaylistsScreenState extends State<YouTubePlaylistsScreen> with ChangeNotifier {
  List<List<dynamic>> rows = [];
  int check = 0;

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

  importPlaylist(String url) async {
    Uri uri = Uri.parse(url);
    List<String> playlistId = [];
    setState(() {
      playlistId.add(uri.queryParameters['list'].toString());
    });
    await fetchData(playlistId);
  }



  @override
  Widget build(BuildContext context) {
    final model = context.read<PlaylistProvider>();
    model.youtube_playlists.length > 0 ? check = 1 : check = 0;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
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
                child: check == 1 ? buildTiles()
                    : Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                            _showPlaylistImporter();
                          },
                          child: Icon(
                            CupertinoIcons.arrow_down_square,
                            color: Colors.orange.shade600.withOpacity(0.8),
                            size: 69,
                          ),
                        ),
                        Text("Click me",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 20,
                              fontWeight: FontWeight.w300
                          ),),
                        Text("Import a youtube playlist ",
                          style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.w300
                        ),),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTiles() {
    check = 1;
    final ABmodel = context.watch<AlbumModel>();
    //final nav = Provider.of<PlaylistProvider>(context, listen: false);
    final model = context.read<BottomPlayerModel>();
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: playlistProvider.youtube_playlists.length,
            itemBuilder: (context, index) {
              index = playlistProvider.youtube_playlists.length-index-1;
              List<String> names = playlistProvider.youtube_playlists;
              try {
                final video = model.rows[index];
                return Container(
                    child: Padding(
                  padding: EdgeInsets.only(right: 0, left: 11),
                  child: GestureDetector(
                    onTap: () async {
                      await _updateAlbumBgColor(video[0].url);
                      setState(() {
                        ABmodel.playlistLength = video.length;
                        ABmodel.ab1 = video[0].url;
                        ABmodel.ab2 = video[1].url;
                        ABmodel.ab3 = video[2].url;
                        ABmodel.ab4 = video[3].url;
                        ABmodel.playlistLength = model.rows[index].length;
                      });

                      /*updateRetain(
                                    songDetails['songTitle']
                                        .toString(),
                                    songDetails['songAuthor']
                                        .toString(),
                                    songDetails['tUrl'].toString(),
                                    songDetails['vId'].toString(),
                                    songDetails['tUrl'].toString());*/
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: AlbumCollection(index),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: ((context) async {
                              deleteYTplaylist(index);
                              /*
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: StartScreen(),
                                withNavBar: true, // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              );
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
                          );*/
                            }),
                            backgroundColor: Colors.black.withRed(400),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            CupertinoIcons.music_albums_fill,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          names[index],
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
                  ),
                ));
              } catch (e) {
                print(e);
              }
            });
      },
    );

    //print(items);
  }

  Future<void> fetchData(List<String> urls) async {
    var yt = YoutubeExplode();
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
      //int? vidCount = playlist.videoCount;
      String playlistName = playlist.title;
      //String about = playlist.description;
      //List playlistVideos = await yt.playlists.getVideos(playlist.id).toList();
      // New url added to saved url list
      savedURLS.add(urls[0]);
      names.add(playlistName);
      nav.youtube_playlists.add(playlistName);
      await box.put('urls', savedURLS);
      await box.put('names', names);

      print("playlist added to hive sucessfully!");
      print("Updated PLaylist list: $savedURLS");
    }
    //await box.put('names', names);

    for (int i = 0; i < urls.length; i++) {
      var playlist = await yt.playlists.get(urls[i]);
      List<Video> videoList =
          await yt.playlists.getVideos(playlist.id).toList();

      List<SongModel> songModels = await videoList.map((video) {
        return SongModel(
          id: video.id.toString(),
          title: video.title,
          author: video.author,
          url: video.thumbnails.highResUrl,
          duration: video.duration!.inSeconds,
        );
      }).toList();

      //_playlistVideosController.add(videoModels);
      rows.add(songModels);

    }

    //final nav = Provider.of<Playlists>(context, listen: false);
    //var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);



    setState(() {
      model.rows.add(rows);

      //nav.playlist.add(playlistName);
      //playlistProvider.updatePlaylistURLS(nav.playlist);
    });

    yt.close();
  }

  deleteYTplaylist(int index) async {
    final model = context.read<BottomPlayerModel>();
    final nav = Provider.of<PlaylistProvider>(context, listen: false);
    final box = await Hive.openBox('savedPlaylist');
    List<String> savedURLS = await box.get('urls') ?? <String>[];
    List<String> names = await box.get('names') ?? <String>[];

    setState(() {
      model.rows.removeAt(index);
      names.removeAt(index);
      savedURLS.removeAt(index);
      nav.youtube_playlists.removeAt(index);
      notifyListeners();
    });
    await box.put('urls', savedURLS);
    await box.put('names', names);
    fetchData(savedURLS);

  }

  Future<void> deletePlaylist(String playlistName) async {
    var box = await Hive.openBox('playlists');

    List<dynamic> playlistsData = box.get('playlists', defaultValue: []) ?? [];

    List<Map<String, dynamic>> playlists =
        List<Map<String, dynamic>>.from(playlistsData.map(
      (item) => Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
    )); // Convert each element to Map<String, dynamic>

    int playlistIndex = playlists.indexWhere((playlist) =>
        playlist['name'] ==
        playlistName); // Find the index of the playlist to be deleted

    if (playlistIndex != -1) {
      // Check if the playlist with the given name exists

      playlists.removeAt(playlistIndex); // Remove the playlist from the list

      await box.put(
          'playlists', playlists); // Save the updated list back to the box

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
