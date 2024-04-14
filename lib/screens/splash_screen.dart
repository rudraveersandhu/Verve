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

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:verve/screens/home_screen.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../audio_player_handler.dart';
import '../main.dart';
import '../models/playlist_model.dart';
import '../models/playlists.dart';
import '../models/bottom_player.dart';
import '../services/download_video.dart';
import '../services/play_audio.dart';
import '../utilities/playlist_provider.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late var playlists;
  List<List<dynamic>> rows = [];

  Future<void> openBox() async {
    await Hive.openBox('retain');
  }

  @override
  initState() {
    fetchData();
    makePlaylist('My Songs');
    makePlaylist('blank');
    fetchLocalPlaylists();

    readLastSong();
    getName();

    Future.delayed(
        const Duration(seconds: 3)).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => HomeScreen()
    )));

    super.initState();

  }

  Future<void> fetchLocalPlaylists() async {
    final box = await Hive.openBox('savedPlaylist');
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    //final nav = Provider.of<PlaylistProvider>(context, listen: false);

    // get the list of local playlists and their names
    List<String> local_names = await box.get('local_names') ?? <String>[];
    print("local saved playlist length: ${local_names.length}");
    for(int i = 0; i < local_names.length; i++){
      playlistProvider.local_playlists.add(local_names[i].toString());
    }


    /*List<String> songs = await box.get('songs') ?? <String>[];



    await box.put('local_names', local_names);
    await box.put('songs', songs);


*/
  }

  Future<void> fetchData() async {
    var yt = YoutubeExplode();
    final playlists = Provider.of<Playlists>(context, listen: false);
    final nav = Provider.of<PlaylistProvider>(context, listen: false);
    //open box of saved playlist
    final box = await Hive.openBox('savedPlaylist');

    // call model to mutate value
    final model = context.read<BottomPlayerModel>();

    // get the list of saved playlist url from the box
    List<String> savedURLS = await box.get('urls') ?? <String>[];
    List<String> names = await box.get('names') ?? <String>[];



    for (int i = 0; i < savedURLS.length; i++) {
      var playlist = await yt.playlists.get(savedURLS[i]);
      List<Video> videoList = await yt.playlists.getVideos(playlist.id).toList();
      String playlistName = playlist.title;
      List<PlaylistModel> videoModels = videoList.map((video) {
        return PlaylistModel(
          id: video.id.toString(),
          title: video.title,
          author: video.author,
          url: video.thumbnails.mediumResUrl,
        );
      }).toList();

      rows.add(videoModels);
      nav.youtube_playlists.add(playlistName);
    }



    if (mounted) {
      setState(() {
        model.rows = rows;
        //print(rows[0][0].id);
      });
    }

    /*setState(() {
      model.rows = rows;

      //nav.playlist.add(playlistName);
      //playlistProvider.updatePlaylistURLS(nav.playlist);
    });*/

    yt.close();
  }

  getHivePlaylist() async {
    final box = await Hive.openBox('savedPlaylist');
    List<String> urls = await box.get('urls') ?? <String>[];
    List<String> names = await box.get('names') ?? <String>[];

    print("initiating hive playlist fetcher");
    print("urls: $urls");
    //fetchData(urls);

    //print("url list length: ${urls.length}");
    //List<List<dynamic>> rows = [];
    //final model = context.read<BottomPlayerModel>();
    //final nav = Provider.of<Playlists>(context, listen: false);
    //var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

    //var yt = YoutubeExplode();

    //for(int i = 0; i < urls.length; i++) {
    //  await setRecomendations(urls[i]);
    //}

    /*for(int i = 0; i < urls.length; i++) {
      print("iteration: $i");
      //print("url are: ${urls}");
      var playlist = await yt.playlists.get(urls[i]);
      //print("got  playlist: $playlist");

        print(playlist.videoCount?.toInt());
        var videoList = await yt.playlists.getVideos(playlist.id).take(
            (playlist.videoCount!.toInt() - 1)).toList();
        //print("OOOOOOOOOOO: $videoList");
        List<PlaylistModel> videoModels = videoList.map((video) {
          //print("xoxoco");
          return PlaylistModel(
            id: video.id.toString(),
            title: video.title,
            author: video.author,
            url: video.thumbnails.mediumResUrl,
          );
        }).toList();
        //print("video models : $videoModels");
        //_playlistVideosController.add(videoModels);
        rows.add(videoModels);
        //print("rows: $rows");
        //print(rows);
      // Rest of your code...
      //print("rows of $i iteration : $rows");
    }*/



    /*if (mounted) {
      setState(() {
        model.rows = rows;
        //print("HAHAHHAHAH: $rows");
        print("HAHAHHAHAH: ${model.rows}");
        // Update your state
      });
    }*/


    //yt.close();
      //print("CCCCCCCC: ${playlist.videoCount?.toInt()}");
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

  Future<void> setRecomendations(String playlistId) async {

    var yt = YoutubeExplode();
    var playlist = await yt.playlists.get(playlistId);
    int? vidCount = playlist.videoCount;
    String playlistName = playlist.title;
    String about = playlist.description;
    List playlistVideos = await yt.playlists.getVideos(playlist.id).toList();

    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

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
        'about': about,
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
    mySongsPlaylist['name'] = playlistName;

    List<dynamic> songs = mySongsPlaylist['songs'];

    // Check if the song with the same ID is already in the playlist

      for (int i = 0; i < vidCount!; i++) {
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
      print("playlist: $storedPlaylists");
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
    /*try {
      final box = await Hive.openBox('savedPlaylist');
      List<String> names = await box.get('local_names') ?? <String>[];
      List<String> songs = await box.get('songs') ?? <String>[];

      bool playlistExists = names.any((playlist) => playlist == playlistName);
      print(playlistExists);

      if (!playlistExists) {
        setState(() {
          names.add(playlistName);
          nav.playlist.add(playlistName);
          playlistProvider.updatePlaylist(nav.playlist);
        });
      } else {
        print('Playlist $playlistName already exists.');
      }
    } catch (e) {
      print("Error accessing Hive box: $e");
    }*/
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
      model.isCardVisible = false;

    } else {
      updateCardColorFromHive();
      String title = await box.get('song');
      String author = await box.get('author');
      String tUrl = await box.get('tUrl');
      String filePath = await box.get('audPath');
      String id = await box.get('id');
      model.isCardVisible = true;

      print("#########################################");
      print(title);
      print(author);
      print(tUrl);
      print(filePath);
      //print();
      //print();
      print("#########################################");

      setState(() {
        model.vId = id;
        model.currentTitle = title;
        model.currentAuthor = author;
        model.tUrl = tUrl;
        model.filePath = filePath;
        model.playButtonOn = false;
        model.isCardVisible = true;

      });
      setAudio();
    }
    }

  Map<String, bool> playmap = {
    "showCard": false,
    "songPlay": false,
  };

  Future<void> setAudio() async {
    final model = context.read<BottomPlayerModel>();
    final List path_dur = await DownloadVideo().downloadVideo(model.vId);
    MediaItem item = MediaItem(
        id: path_dur[0].toString(),
        album: model.currentAuthor,
        title: model.currentTitle,
        artist: model.currentAuthor,
        duration: Duration(seconds: path_dur[1].toInt()),
        artUri: Uri.parse(model.tUrl),
        genre: model.cardBackgroundColor.toString(),
        playable: true,
        extras: playmap = {
          "showCard": true,
          "songPlay": true,
        }
    );

    await AudioPlayerHandler().initializeAudioPlayer(path_dur[0].toString());
    audioHandler.updateMediaItem(item);
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
