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
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/playlists.dart';
import '../models/bottom_player.dart';
import '../services/download_video.dart';
import '../services/play_audio.dart';
import '../utilities/playlist_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int currentlyPlayingIndex = -1;
  String currentThumb = '';
  String currentTitle = '';
  String currentAuthor = '';
  bool isCardVisible = true;
  List<Video> _searchResults = [];
  bool hasUserSearched = false;
  final FocusNode _focusNode = FocusNode();
  bool playButtonOn = true;
  String vId = '';
  String vUrl = '';
  TextEditingController _textEditingController = TextEditingController();
  late List<bool> isPlayingList ;


  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _searchYoutubeVideos(String query) async {
    var yt = YoutubeExplode();
    try {
      var searchList = await yt.search(query);
      setState(() {
        _searchResults = searchList;
        isPlayingList = List.generate(_searchResults.length, (index) => false);

      });
    } catch (e) {
      //print('Error fetching YouTube videos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
    final audio = Provider.of<PlayAudio>(context);
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Container(
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
                        child: TextField(
                          controller: _textEditingController,
                          focusNode: _focusNode,
                          onTap: () {},
                          onChanged: (value) {
                            setState(() {
                              if (value == '') {
                                hasUserSearched = false;
                              } else {
                                hasUserSearched = true;
                              }
                            });
                            _searchYoutubeVideos(value);
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
                                  shrinkWrap: true,
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {

                                    var vid = _searchResults[index] ;
                                    var thumbnailUrl = _searchResults[index].thumbnails.highResUrl ;
                                    var tempUrl = _searchResults[index].thumbnails.lowResUrl ;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      child: GestureDetector(
                                        // Stream Logic
                                        onTap: () async { //Stream logic
                                          await _updateCardColor(tempUrl);
                                          vId = vid.id.toString();
                                          List path_dur = await DownloadVideo().downloadVideo(vId, 'download');
                                          audio.initializeAudioPlayer(path_dur[0],'download');
                                          audio.playAudio();

                                          currentTitle = _searchResults[index].title;
                                          currentAuthor = _searchResults[index].author;
                                          updateRetain(currentTitle, currentAuthor, thumbnailUrl, path_dur[0], tempUrl);

                                          if (!isPlayingList[index]) { // Start playing the song
                                            model.playButtonOn = true;
                                            audio.initializeAudioPlayer(path_dur[0],'download');
                                            audio.playAudio();
                                          } else {  // Pause the song
                                            audio.pauseAudio();
                                            model.playButtonOn = false;
                                            print('Pausing song at index $index');
                                          }

                                          setState(() {
                                            //ABmodel.currentDuration = path_dur[1];
                                            isPlayingList[index] = !isPlayingList[index]; // Toggle the play/pause state for the clicked item

                                            if (currentlyPlayingIndex != index) {
                                              if (currentlyPlayingIndex != -1) { // If a new item is clicked, this stops the currently playing item
                                                isPlayingList[currentlyPlayingIndex] = false;
                                              }
                                              currentlyPlayingIndex = index; // Updating the currently playing index
                                            }

                                            model.isCardVisible = true;
                                            model.tUrl = thumbnailUrl;
                                            model.currentTitle = currentTitle;
                                            model.currentAuthor = currentAuthor;
                                            model.filePath = path_dur[0];
                                            model.isCardVisible = true;
                                            //model.playButtonOn = isPlayingList[index];
                                          });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 95,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
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
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        // Download actions
                                                        onTap: () async {
                                                          // Download actions
                                                          await _updateCardColor(tempUrl);
                                                          vId =
                                                              vid.id.toString();
                                                          List path_dur = await DownloadVideo().downloadVideo(vId, 'download');
                                                          currentTitle = _searchResults[index].title;
                                                          currentAuthor = _searchResults[index].author;
                                                          updateRetain(currentTitle, currentAuthor, thumbnailUrl, path_dur[0], tempUrl);

                                                          audio.initializeAudioPlayer(path_dur[0],'downloaded');
                                                          audio.playAudio();

                                                          setState(() {
                                                            model.isCardVisible =
                                                                true;
                                                            model.tUrl =
                                                                thumbnailUrl;
                                                            model.currentTitle =
                                                                currentTitle;
                                                            model.currentAuthor =
                                                                currentAuthor;
                                                            model.filePath =
                                                            path_dur[0];
                                                            model.isCardVisible =
                                                                true;
                                                            model.playButtonOn =
                                                                true;
                                                          });
                                                        },
                                                        child: Icon(
                                                          CupertinoIcons.heart,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      SizedBox(width: 40),
                                                      GestureDetector(
                                                        // Stream Logic
                                                        onTap: () async { //Stream logic
                                                          await _updateCardColor(tempUrl);
                                                          vId = vid.id.toString();
                                                          List path_dur = await DownloadVideo().downloadVideo(vId, 'download');
                                                          audio.initializeAudioPlayer(path_dur[0],'download');
                                                          audio.playAudio();

                                                          currentTitle = _searchResults[index].title;
                                                          currentAuthor = _searchResults[index].author;
                                                          updateRetain(currentTitle, currentAuthor, thumbnailUrl, path_dur[0], tempUrl);

                                                          if (!isPlayingList[index]) { // Start playing the song
                                                            model.playButtonOn = true;
                                                            audio.playAudio();
                                                          } else {  // Pause the song
                                                            audio.pauseAudio();
                                                            model.playButtonOn = false;
                                                            print('Pausing song at index $index');
                                                          }

                                                          setState(() {
                                                            isPlayingList[index] = !isPlayingList[index]; // Toggle the play/pause state for the clicked item

                                                            if (currentlyPlayingIndex != index) {
                                                              if (currentlyPlayingIndex != -1) { // If a new item is clicked, this stops the currently playing item
                                                                isPlayingList[currentlyPlayingIndex] = false;
                                                              }
                                                              currentlyPlayingIndex = index; // Updating the currently playing index
                                                            }

                                                            model.isCardVisible = true;
                                                            model.tUrl = thumbnailUrl;
                                                            model.currentTitle = currentTitle;
                                                            model.currentAuthor = currentAuthor;
                                                            model.filePath = path_dur[0];
                                                            model.isCardVisible = true;
                                                            //model.playButtonOn = isPlayingList[index];
                                                          });
                                                          },
                                                        child: Icon(
                                                          isPlayingList[index] && model.playButtonOn ? CupertinoIcons.pause : CupertinoIcons.play_arrow_solid,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
    );
  }

  Future<void> updateMySongs(String songTitle, String artist, String thumb,
      String audPath, String tempUrl) async {
    var playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    final nav = Provider.of<Playlists>(context, listen: false);
    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var mySongsPlaylist = storedPlaylists.firstWhere(
      (playlist) => playlist['name'] == 'My Songs',
      orElse: () => {'name': 'My Songs', 'songs': []},
    );

    setState(() {
      if (!nav.playlist.contains('My Songs')) {
        nav.playlist.add('My Songs');
        print(nav.playlist);
        playlistProvider.updatePlaylist(nav.playlist);
      }
      print(nav.playlist);
    });

    List<dynamic> songs = mySongsPlaylist['songs'];

    bool isSongAlreadyPresent = songs.any((song) =>
        song['songTitle'] == songTitle && song['songAuthor'] == artist);

    if (isSongAlreadyPresent) {
      print('Song is already present in "My Songs" playlist.');
    } else {
      songs.add({
        'songTitle': songTitle,
        'songAuthor': artist,
        'tUrl': tempUrl,
        'vId': audPath,
        'thumbnail': thumb,
      });

      box.put('playlists', storedPlaylists);

      print('Song added to "My Songs" playlist successfully.');
    }
  }

  void updateRetain(String songTitle, String artist, String thumb,
      List path_dur, String tempUrl) async {
    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', path_dur[0]);
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
