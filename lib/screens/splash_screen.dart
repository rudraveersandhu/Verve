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
import '../services/youtube_service.dart';
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
    getName();
    makePlaylist('My Songs','vjv_dsc_Sdc_SDc_Dvds_Vd');
    makePlaylist('blank','oiugh_isdfvj_kjhs_vcj_sd');
    fetchYTPLData();
    fetchLPData();
    readLastSong();

    Future.delayed(
        const Duration(seconds: 3)).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => HomeScreen()
    )));

    super.initState();

  }

  /*Future<void> fetchYTPlaylists() async {
    final box = await Hive.openBox('playlists');
    List<dynamic> storedPlaylists = await box.get('playlists', defaultValue: []);
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    //final nav = Provider.of<PlaylistProvider>(context, listen: false);

    // get the list of local playlists and their names
    List<String> playlist_names = await box.get('names') ?? <String>[];
    List<String> playlist_urls = await box.get('urls') ?? <String>[];

    for(int i = 0; i < playlist_names.length; i++){
      playlistProvider.local_playlists.add(playlist_names[i].toString());

    }

    for(int i = 0; i < playlist_urls.length; i++){
      await makePlaylist(playlist_names[i], playlist_urls[i]);
    }

    var targetPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['id'] == playlist_urls[0],
      orElse: () => <String, Object>{},
    );

    print("Splash Screen: Target playlist: ${storedPlaylists}");
    print("Splash Screen: Playlist urls: ${playlist_urls}");

    //List<String> songs = await box.get('songs') ?? <String>[];
    //await box.put('local_names', local_names);
    //await box.put('songs', songs);

  }*/

  Future<void> fetchYTPLData() async {
    YouTubeService youtubeService = YouTubeService(context);
    var yt = YoutubeExplode();
    final playlists = Provider.of<Playlists>(context, listen: false);
    final nav = Provider.of<PlaylistProvider>(context, listen: false);
    //open box of saved playlist
    final box = await Hive.openBox('playlists');

    // call model to mutate value
    final model = context.read<BottomPlayerModel>();

    // get the list of saved playlist url from the box
    List<String> savedURLS = await box.get('urls') ?? <String>[];
    List<String> names = await box.get('names') ?? <String>[];

    nav.updateUrl(savedURLS);
    model.names = names;

    for (int i = 0; i < savedURLS.length; i++) {

      var playlist = await yt.playlists.get(savedURLS[i]);
      List<Video> videoList = await yt.playlists.getVideos(playlist.id).toList();

      String playlistName = playlist.title;
      List<SongModel> songModels = await videoList.map((video) {
        return SongModel(
          id: video.id.toString(),
          title: video.title,
          author: video.author,
          url: video.thumbnails.highResUrl,
          duration: video.duration!.inSeconds,
        );
      }).toList();

      rows.add(songModels);
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

  Future<void> fetchLPData() async {
    final nav = Provider.of<Playlists>(context, listen: false);
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    print("oooooooooo");
    final box = await Hive.openBox('playlists');
    print("kkkkkkkkkk");
    List<dynamic> storedPlaylists = box.get('local_playlists', defaultValue: []);
    //bool playlistExists = storedPlaylists.any((playlist) => playlist['name'] == playlistName);
    List<String> local_names = await box.get('local_names') ?? <String>[];
    print("length of names: ${local_names.length}");
    for(int i = 0; i < local_names.length; i++){
      nav.playlist.add(local_names[i]);
      /*List<dynamic> songs = mySongsPlaylist['songs'];
      var song = songs[i];
      List<SongModel> songModels = await songs.map((video) {return SongModel(id: video.id.toString(),title: song['songTitle'],author: song['songAuthor'],url: song['tUrl'],duration: song['duration'],);}).toList();temprow.add(songModels);*/
      setState(() {
        playlistProvider.updateLocalPlaylist(nav.playlist);
      });
      await box.put('local_names', local_names);
      await box.put('playlists', storedPlaylists);
      // access each value of song by using song['value name'] then add it to the
    }
  }

  /*getHivePlaylist() async {
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
  }*/

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
    //getPlaylists();
  }

  Future<void> makePlaylist(String playlistName, String playlistId) async {
    final model  = context.read<BottomPlayerModel>();
    final nav    = Provider.of<Playlists>(context, listen: false);
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

    try {
      final box = await Hive.openBox('playlists');
      List<dynamic> playlists = box.get('playlists', defaultValue: []);
      bool playlistExists = playlists.any((playlist) => playlist['id'] == playlistId);

      if (!playlistExists) {
        setState(() {

          if(playlistId.substring(0, 2) == 'PL'){
            nav.playlist.add(playlistId);
            playlistProvider.updateYoutubePlaylist(nav.playlist);
          }else{
            nav.playlist.add(playlistName);
            playlistProvider.updateLocalPlaylist(nav.playlist);
          }

        });

        // Add the new playlist
        playlists.add({
          'name': playlistName,
          'id'  : playlistId,
          'author': model.user,
          'description': 'playlistDescription',
          'NumOfSongs': 0,
          'songs': []
        });
        await box.put('playlists', playlists);
        print('Playlist $playlistName created successfully.');
      } else {
        print('Playlist $playlistName already exists.');
      }
    } catch (e) {
      print("Error accessing Hive box: $e");
    }
  }

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
