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
import 'package:verve/screens/home_screen.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/playlists.dart';
import '../models/bottom_player.dart';
import '../services/play_audio.dart';
import '../utilities/playlist_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late var playlists;

  Future<void> openBox() async {
    await Hive.openBox('retain');
  }

  @override
  void initState(){

    makePlaylist('My Songs');
    makePlaylist('blank');

    makePlaylist('Trending');
    makePlaylist('Punjabi');
    makePlaylist('Top10Indian');
    makePlaylist('EngRom');

    setRecomendations('Top10Indian', 58, 'PLFFyMei_d85U1Rm4g12FgpLw484_LP1Jy');
    setRecomendations('Trending', 200, 'PLMC9KNkIncKseYxDN2niH6glGRWKsLtde');
    setRecomendations('Punjabi', 166, 'PLFFyMei_d85XIZGAtpgX6SKyEqOmyGlSq');
    setRecomendations('EngRom', 189, 'PLgzTt0k8mXzE6H9DDgiY7Pd8pKZteis48');

    readLastSong();

    getName();

    Future.delayed(
        const Duration(seconds: 3)).then((value) => Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomeScreen()
    )));

    super.initState();

  }

  getName() async {
    final model = context.read<BottomPlayerModel>();
    final box = await Hive.openBox('User');
    var x =  await box.get('name').toString();

    if(x == 'null' || x == ''){
      x = 'Guest';
    }

    setState(() {
      model.user = x;
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPlaylists();
  }

  Future<void> setRecomendations(String playlistName, int NumOfItems, String playlistId) async {
    var yt = YoutubeExplode();
    var playlist = await yt.playlists.get(playlistId);
    String about = playlist.description;
    List playlistVideos = await yt.playlists.getVideos(playlist.id).take(
        NumOfItems).toList();
    var playlistProvider =
    Provider.of<PlaylistProvider>(context, listen: false);
    final nav = Provider.of<Playlists>(context, listen: false);
    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    // Find the playlist
    var mySongsPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == playlistName,
      orElse: () =>
      {
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
  }


  getPlaylists() async {
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final nav = Provider.of<Playlists>(context, listen: false);

    try {
      final box = await Hive.openBox('playlists');
      List<dynamic> playlists = box.get('playlists', defaultValue: []);
      List<String> playlistNames = playlists.map((playlist) => playlist['name'].toString()).toList();

      setState(() {
        nav.playlist = playlistNames;
        playlistProvider.updatePlaylist(nav.playlist);
      });


      return playlistNames;
    } catch (e) {
      print("Error accessing Hive box: $e");
      return [];
    }
  }

  Future<void> makePlaylist(String playlistName) async {
    final nav = Provider.of<Playlists>(context, listen: false);
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

    try {
      final box = await Hive.openBox('playlists');
      List<dynamic> playlists = box.get('playlists', defaultValue: []);
      bool playlistExists = playlists.any((playlist) => playlist['name'] == playlistName);

      if (!playlistExists) {
        setState(() {
          nav.playlist.add(playlistName);
          playlistProvider.updatePlaylist(nav.playlist);
        });

        // Add the new playlist
        playlists.add({
          'name': playlistName,
          'songs': [],
          'about' : ''
        });
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

  /*makePlaylistFile() async {
    //final box = await Hive.openBox('playlists');
    //box.delete('playlists',);
    box.put('playlists', [
      {
        'name': 'My Songs',
        'songs': [
          //{'songTitle': 'CALIFORNIA LOVE (Official Video) Cheema Y | Gur Sidhu | New Punjabi Song 2023', 'songAuthor': 'Brown Town Music', 'tUrl': 'https://img.youtube.com/vi/rSxTumD4kew/hqdefault.jpg', 'vId': 'rSxTumD4kew'},
          //{'songTitle': 'Song 2', 'songAuthor': 'Author 2', 'tUrl': 'URL 2', 'vId': 'VideoID 2'},
        ],
      },
    ]);
    //printPlaylist();
  }*/

  /*printPlaylist() async {

    final box = await Hive.openBox('playlists');
    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);


    for (var playlist in storedPlaylists) {

      String playlistName = playlist['name'];
      //print('Playlist Name: $playlistName');


      List<dynamic> songs = playlist['songs'];
      for (var song in songs) {

        String songTitle = song['songTitle'];
        String songAuthor = song['songAuthor'];
        String tUrl = song['tUrl'];
        String vId = song['vId'];

        //print('Song Title: $songTitle, Author: $songAuthor, URL: $tUrl, Video ID: $vId');
      }
    }

  }*/

  Color convertStringToColor(String colorString) {
    String hexString = colorString.replaceAll("Color(", "").replaceAll(")", "").replaceAll("0x", "");
    int hexValue = int.parse(hexString, radix: 16);
    Color color = Color(hexValue);
    return color;
  }

  Future<void> updateCardColorFromHive() async {
    final model = context.read<BottomPlayerModel>();
    final box = await Hive.openBox('retain');
    setState(() {
      model.cardBackgroundColor = convertStringToColor(box.get('color'));
    });
  }

  void readLastSong() async {

    final model = context.read<BottomPlayerModel>();

    final box = await Hive.openBox('retain');

    if(box.get('song') == null){

      print('null hai bhai');

    } else {
      updateCardColorFromHive();
      setState(() {
        model.currentTitle = box.get('song');
        model.currentAuthor = box.get('author');
        model.tUrl = box.get('tUrl');
        model.filePath = box.get('audPath');
        model.playButtonOn = false;
        model.isCardVisible = true;
      });
      setAudio();
    }
    }

  Future<void> setAudio() async {
    final box = await Hive.openBox('retain');
    String audpath = box.get('audPath').toString();
    final audio = Provider.of<PlayAudio>(context, listen: false);
    await audio.initializeAudioPlayer(audpath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: Container(
            height: 300,
            width: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/verve_logo.png'),
                  scale:2.5 )
            ),
          ),
        ),
      ),
    );
  }
}
