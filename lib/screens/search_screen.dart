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
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:verve/audio_player_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../main.dart';
import '../models/playlists.dart';
import '../models/bottom_player.dart';
import '../services/download_video.dart';
import '../services/play_audio.dart';
import '../utilities/playlist_provider.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin{
  //PersistentTabController _bpcontroller = PersistentTabController(initialIndex: 0);

  int currentlyPlayingIndex = -1;
  Map<String, bool> playmap = {
    "showCard": true,
    "songPlay": false,
  };
  int currentlydownloadingIndex = -1;
  String currentThumb = '';
  String currentTitle = '';
  String currentAuthor = '';
  List<Video> _searchResults = [];
  bool hasUserSearched = false;
  final FocusNode _focusNode = FocusNode();
  bool playButtonOn = true;
  String vId = '';
  String vUrl = '';
  TextEditingController _textEditingController = TextEditingController();
  late List<bool> isPlayingList ;
  late List<bool> isInPlaylist ;
  bool isPlaylistSelectorVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void dispose() {
    _textEditingController.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> fetchData(List<Video> searchResults) async {
    List<Future<bool>> futures = [];

    for (int i = 0; i < searchResults.length; i++) {
      futures.add(checkInPlaylist('My Songs', searchResults[i].id.toString()));
    }

    List<bool> results = await Future.wait(futures);

    setState(() {
      isInPlaylist = results;
    });
  }

  _searchYoutubeVideos(String query) async {
    var yt = YoutubeExplode();
    try {
      var searchList = await yt.search(query);

      setState(()  {
        fetchData(searchList);
        _searchResults = searchList;
        isPlayingList = List.generate(_searchResults.length, (index) => false);
      });
      //isInPlaylist = List.generate(_searchResults.length, (index) => checkInPlaylist('My Songs', _searchResults[index].id.toString()));

    } catch (e) {
      print('Error fetching YouTube videos: $e');
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 0.0,end: 1.0).animate(_controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
    //final model = context.read<BottomPlayerModel>();
    //final audio = Provider.of<PlayAudio>(context);
    _controller.forward();
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Stack(
        children: [
          Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade900,
                Colors.black.withOpacity(.96)
              ], // Add your gradient colors
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
              ),
              child: Stack(
                children: [
                  SafeArea(
                    top: true,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Search",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
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
                                  //SizedBox(width: 10),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Material(
                            child: TextField(
                              controller: _textEditingController,
                              focusNode: _focusNode,
                              onTap: () {},
                              onChanged: (value) {

                                setState(()   {
                                  if (value == '') {
                                    hasUserSearched = false;
                                  } else {
                                    hasUserSearched = true;
                                     _searchYoutubeVideos(value);
                                  }
                                });

                              },
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'What do you feel like listening to?',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 15, top: 0),
                                  child: Icon(Icons.search),
                                ),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _textEditingController.clear();
                                        hasUserSearched = false;
                                      });
                                    },
                                    child: hasUserSearched
                                        ? Icon(Icons.delete_outline)
                                        : Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                          )),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Divider(
                          color: Colors.grey.shade700,
                          height: 0,
                          indent: 0,
                        ),
                        GestureDetector(
                          onLongPress: () {
                            _focusNode.unfocus();
                          },
                          child: SizedBox(
                            height: 626, // height above bottom nav bar
                            child: hasUserSearched
                                ? ListView.builder(
                                    //shrinkWrap: true,
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      var vId = _searchResults[index].id;
                                      var thumbnailUrl = _searchResults[index].thumbnails.highResUrl ;
                                      var tempUrl = _searchResults[index].thumbnails.lowResUrl ;
                                      //fetchData(_searchResults);
                                      //isInPlaylist = List.generate(_searchResults.length, (index) => checkInPlaylist('My Songs', _searchResults[index].id.toString()));
                                      //isInPlaylist = checkInPlaylist('My Songs', vId.toString()) as List<bool>;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: GestureDetector(
                                          onTap: () async {
                                            String? color = await updateCardColor(tempUrl);
                                            final List path_dur = await DownloadVideo().downloadVideo(vId.toString());  // Download the audio file, return a list with file location and duration
                                            setState(() {
                                              model.isCardVisible = true;
                                              model.currentTitle = _searchResults[index].title;
                                              model.currentAuthor = _searchResults[index].author;
                                              model.currentDuration = path_dur[1].toInt();
                                              model.tUrl = thumbnailUrl;
                                              model.vId = _searchResults[index].id.toString();
                                              model.tUrl = thumbnailUrl;
                                              model.filePath = path_dur[0];
                                            });
                                            await _updateCardColor(
                                                thumbnailUrl,
                                                _searchResults[index].title,
                                                _searchResults[index].author,
                                                path_dur[1].toInt());
                                            updateRetain(
                                                _searchResults[index].title,
                                                _searchResults[index].author,
                                                thumbnailUrl,
                                                path_dur,
                                                tempUrl,
                                                path_dur[1].toInt(),
                                                _searchResults[index].id.toString()
                                            );
                                            MediaItem item = MediaItem(
                                                id: path_dur[0].toString(),
                                                album: _searchResults[index].author,
                                                title: _searchResults[index].title,
                                                artist: _searchResults[index].author,
                                                duration: Duration(seconds: path_dur[1].toInt()),
                                                artUri: Uri.parse(thumbnailUrl),
                                                genre: color,
                                                playable: true,
                                                extras: playmap = {
                                                  "showCard": true,
                                                  "songPlay": true,
                                                }
                                            );



                                            await AudioPlayerHandler().initializeAudioPlayer(path_dur[0].toString());
                                            audioHandler.updateMediaItem(item);
                                            audioHandler.play();

                                          },
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 95,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 10.0),
                                                  child: FadeTransition(
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
                                                            offset: Offset(2,
                                                                3), // changes the shadow position
                                                          ),
                                                        ],
                                                        color: Colors.orange,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5.0),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5),
                                                        child: PhotoView(
                                                          imageProvider:
                                                              NetworkImage(tempUrl),
                                                          customSize: Size(110, 110),
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
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 20,
                                                      top: 15,
                                                      //bottom: 15,
                                                  ),
                                                  child: Container(
                                                    width: 200,
                                                    padding: EdgeInsets.zero,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _searchResults[index]
                                                              .title,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            //fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                        Text(
                                                          _searchResults[index].author,
                                                          maxLines: 1,
                                                          style: const TextStyle(color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                //SizedBox(width: 5,),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 20.0),
                                                  child: Container(
                                                    width: 90,
                                                    child: Stack(
                                                      children: [
                                                      Positioned(
                                                        right: 15,
                                                        top: 30,
                                                        child: GestureDetector(
                                                          // Like actions
                                                          onTap: () async {
                                                            isPlayingList[index] = !isPlayingList[index];
                                                            if (currentlydownloadingIndex != index) {
                                                              if (currentlydownloadingIndex != -1) {
                                                                isPlayingList[currentlydownloadingIndex] = false;
                                                              }
                                                              currentlydownloadingIndex = index;
                                                            }
                                                            List path_dur = await DownloadVideo().downloadVideo(vId.toString());
                                                            await addToPlaylist(
                                                                'vjv_dsc_Sdc_SDc_Dvds_Vd',
                                                                _searchResults[index].title,
                                                                _searchResults[index].author,
                                                                thumbnailUrl,
                                                                path_dur[0],
                                                                vId.toString() ,
                                                                tempUrl,
                                                                path_dur[1].toInt());


                                                            setState(() {
                                                              //print("Running fetch data final part");
                                                              fetchData(_searchResults);
                                                            });
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    Text('Added to "My Songs" successfully !', style: TextStyle(fontSize: 12)),
                                                                    SizedBox(width: 10),
                                                                    ElevatedButton(
                                                                      onPressed: () async {
                                                                        await removeFromPlaylist(
                                                                            "vjv_dsc_Sdc_SDc_Dvds_Vd",
                                                                            _searchResults[index].title,
                                                                            _searchResults[index].author,
                                                                            thumbnailUrl,
                                                                            path_dur[0],
                                                                            thumbnailUrl,
                                                                            vId.toString(),
                                                                            path_dur[1].toInt()
                                                                        );
                                                                        setState(() {
                                                                          showPlaylistSelector();

                                                                        });
                                                                      },
                                                                      child: Container(
                                                                        width: 50,
                                                                        child: Text('Change', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                behavior: SnackBarBehavior.floating,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                ),
                                                                backgroundColor: Colors.orange.withAlpha(900),
                                                                duration: Duration(seconds: 1),
                                                              ),
                                                            );
                                                          },
                                                          /*child: isInPlaylist[index]
                                                              ? Icon(CupertinoIcons.heart_fill, color: Colors.deepOrange, /*key: Key('${index}heart_filled')*/)
                                                              : Icon(CupertinoIcons.heart, color: Colors.white, /*key: Key('heart')*/),*/

                                                        ),
                                                      ),
                                                    ],),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
          isPlaylistSelectorVisible ? PlaylistSelector() : Container(),]
      ),
    );
  }

  removeFromPlaylist(
      String playlistId,
      String songTitle,
      String artist,
      String thumb,
      String audPath,
      String tempUrl,
      String vId ,
      int dur) async {

    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);
    bool playlistExists = storedPlaylists.any((playlist) => playlist['id'] == playlistId);

    if(playlistExists){
      var mySongsPlaylist = storedPlaylists.firstWhere(
            (playlist) => playlist['id'] == playlistId,
        orElse: () => {
          'name': '',
          'songs': []
        },
      );

      List<dynamic> songs = mySongsPlaylist['songs'];

      bool isSongAlreadyPresent = songs.any((song) =>
      song['songTitle'] == songTitle && song['songAuthor'] == artist);

      if (isSongAlreadyPresent) {
        print('Song is already present in $playlistId playlist.');
      } else {
        songs.remove({
          'songTitle': songTitle,
          'songAuthor': artist,
          'tUrl': tempUrl,
          'vId': vId,
          'audPath': audPath,
          'thumbnail': thumb,
          'duration': dur,
        });

        box.put('playlists', storedPlaylists);
        await box.close();

        /* setState(() {
        if (!nav.playlist.contains(playlistName)) {
          nav.playlist.add(playlistName);
          playlistProvider.updateLocalPlaylist(nav.playlist);
        }
      });*/
      }
      print('Song added to "My Songs" playlist successfully.');
    }else{
      print("PLaylist DOesnt exist");
    }
  }

  Future<void> addToPlaylist(
      String playlistId,
      String songTitle,
      String artist,
      String thumb,
      String audPath,
      String vId ,
      String tempUrl,
      int dur) async {

    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);
    //bool playlistExists = storedPlaylists.any((playlist) => playlist['id'] == playlistId);
    bool playlistExists = storedPlaylists.any((playlist){
      print(playlist['id']);
      if(playlist['id'] == playlistId){
        return true;
      }else{
        return false;
      }
    });

    if(playlistExists){
      var mySongsPlaylist = storedPlaylists.firstWhere(
            (playlist) => playlist['id'] == playlistId,
        orElse: () => {
          'name': '',
          'songs': []
        },
      );

      List<dynamic> songs = mySongsPlaylist['songs'];

      bool isSongAlreadyPresent = songs.any((song) =>
      song['songTitle'] == songTitle && song['songAuthor'] == artist);

      if (isSongAlreadyPresent) {
        print('Song is already present in $playlistId playlist.');
      } else {
        songs.add({
          'songTitle': songTitle,
          'songAuthor': artist,
          'tUrl': tempUrl,
          'vId': vId,
          'audPath': audPath,
          'thumbnail': thumb,
          'duration': dur,
        });

        box.put('playlists', storedPlaylists);
        await box.close();

        /* setState(() {
        if (!nav.playlist.contains(playlistName)) {
          nav.playlist.add(playlistName);
          playlistProvider.updateLocalPlaylist(nav.playlist);
        }
      });*/

    }
      print('Song added to "My Songs" playlist successfully.');
    }else{

      print("pLaylist doesnt exist");
    }
  }

  void updateRetain(String songTitle, String artist, String thumb,
      List path_dur, String tempUrl, int duration, String id) async {
    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', path_dur[0]);
    box.put('tempUrl', tempUrl);
    box.put('duration', duration);
    box.put('id', id);
  }



  Future<void> _updateCardColor(String thumbnailUrl,String title, String author, int dur ) async {
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(thumbnailUrl));
    final model = context.read<BottomPlayerModel>();
    final box = await Hive.openBox('retain');

    setState(() {
      model.cardBackgroundColor = paletteGenerator.dominantColor!.color;
      box.put('color', paletteGenerator.dominantColor!.color.toString());
      model.currentTitle = title;
      model.currentAuthor = author;
      model.tUrl = thumbnailUrl;
      model.playButtonOn = true;
      model.isCardVisible = true;
      model.currentDuration = dur;
      //box.put('color', paletteGenerator.dominantColor!.color.toString());

    });
  }

  void showPlaylistSelector() {
    setState(() {
      isPlaylistSelectorVisible = true;
    });
  }

  Widget PlaylistSelector() {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: InkWell(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withAlpha(480), Colors.black],
                        stops: [0.2, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: Text(
                                  "Choose Playlist",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: buildList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildList() {
    final nav = Provider.of<Playlists>(context, listen: false);
    final model = context.read<BottomPlayerModel>();
    return Container(
      color: Colors.black.withAlpha(300),
      height: 200,
      child: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0,left: 5),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: playlistProvider.youtube_playlists.length,
              itemBuilder: (context, index) {
                bool isMySongs = nav.playlist[index] == "My Songs";
                bool isBlank = nav.playlist[index] == "blank";


                if (!isBlank) {
                  List<Color> gradientColors = [Colors.grey, Colors.grey.shade700];

                  IconData iconData = isMySongs
                      ? Icons.thumb_up
                      : Icons.sports_gymnastics;
                  return (!isBlank) ? ListTile(
                    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                    onTap: () {
                      addToPlaylist(
                          nav.playlist[index],
                          model.currentTitle,
                          model.currentAuthor,
                          model.tUrl,
                          model.filePath,
                          model.tUrl,
                          model.vId,
                          model.currentDuration
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Added successfully !'),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      showPlaylistSelector();
                                    });
                                  },
                                  child: Container(
                                    //color: Colors.red,
                                    width: 50,
                                    child: Text('Change',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 13),),
                                  )),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: model.cardBackgroundColor.withAlpha(
                              1000), // Customize the background color
                          duration: Duration(
                              seconds:
                              1),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      nav.playlist[index],
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Playlist',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ) : Container();
                } else {
                  return Container();
                }
              },
            ),
          );
        },
      ),
    );
  }

  isInMySongs(String pname ,String id){
    return checkInPlaylist(pname,id);
  }

  Future<bool> checkInPlaylist(String targetPlaylistName, String id) async {
    final box = await Hive.openBox('playlists');
    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var targetPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == targetPlaylistName,
      orElse: () => <String, Object>{},
    );

    if (targetPlaylist != null) {
      List<dynamic> songs = targetPlaylist['songs'];

      for (var song in songs) {
        String vId = song['vId'];
        //print("dekh bhai : $vId : ${song['vId']}");

        if (vId == id) {
          //print('ID found in the playlist: $id');
          return true;
        }
      }
      //print('ID not found in the playlist: $id');
      return false;
    } else {
      //print('Playlist not found: $targetPlaylistName');
      return false;
    }
  }

  Future<String?> updateCardColor(url) async {
    final box = await Hive.openBox('retain');
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(url));
    String color = paletteGenerator.dominantColor!.color.toString();
    box.put('color', paletteGenerator.dominantColor!.color.toString());
    return color;

  }
}
