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

import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verve/models/album.dart';
import 'package:verve/screens/splash_screen.dart';
import 'package:verve/services/play_audio.dart';
import 'package:verve/utilities/playlist_provider.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'audio_player_handler.dart';
import 'models/playlists.dart';
import 'models/bottom_player.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.verve.player.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter('Verve/Database');
  } else if (Platform.isIOS) {
    await Hive.initFlutter('Verve/Database');
  } else {
    await Hive.initFlutter();
  }


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioPlayerHandler>(
          create: (context) => AudioPlayerHandler(),
        ),
        ChangeNotifierProvider<BottomPlayerModel>(
          create: (context) => BottomPlayerModel(),
        ),

        ChangeNotifierProvider<Playlists>(
          create: (context) => Playlists(),
        ),
        ChangeNotifierProvider<AlbumModel>(
          create: (context) => AlbumModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => PlaylistProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verve',
      debugShowCheckedModeBanner: false,
      /*theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.transparent),
        useMaterial3: true,
      ),*/
      home: const SplashScreen(),
    );
  }
 }

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}