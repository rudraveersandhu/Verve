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

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../models/bottom_player.dart';
import '../models/playlists.dart';
import '../utilities/playlist_provider.dart';

class NewPlaylist extends StatefulWidget {
  const NewPlaylist({super.key});

  @override
  State<NewPlaylist> createState() => _NewPlaylistState();
}

class _NewPlaylistState extends State<NewPlaylist> {
  String userInput = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String generateRandomId() {
    const String charset =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#\$%^&*()-_+=<>?/.,';

    Random random = Random();
    String id = '';
    for (int i = 0; i < 15; i++) {
      int randomIndex = random.nextInt(charset.length);
      id += charset[randomIndex];
    }
    return id;
  }

  Future<void> makePlaylist( String playlistName  ) async {
    final nav = Provider.of<Playlists>(context, listen: false);
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final model  = context.read<BottomPlayerModel>();
    try{
      final box = await Hive.openBox('playlists');
      List<dynamic> playlists = box.get('playlists', defaultValue: []);
      bool playlistExists = playlists.any((playlist) => playlist['name'] == playlistName);
      List<String> local_names = await box.get('local_names') ?? <String>[];

      if (!playlistExists) {

        setState((){
          local_names.add(playlistName);
          nav.playlist.add(playlistName);
          playlistProvider.updateLocalPlaylist(nav.playlist);
        });

        String id = generateRandomId();

        playlists.add({
          'name': playlistName,
          'id' : id,
          'author': model.user,
          'description' : '',
          'NumOfSongs': 0,
          'songs': [],

        });

        await box.put('local_names', local_names);
        await box.put('playlists', playlists);
        await box.close();
      } else {
        print('Playlist $playlistName already exists.');
      }
    } catch (e) {
      print("Error accessing Hive box: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

    print("Start: ${playlistProvider.local_playlists.length}");
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 33,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black,
              Colors.grey.shade700,
            ],
            stops: [0.1, 1.0],
          ),
        ),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Center(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Lets name your playlist",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40),
              child: TextField(
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                cursorColor: Colors.orange.shade700,
                onChanged: (value) {
                  setState(() {
                    userInput = value;
                  });
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 45.0,
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(
                  hintText: 'My playlist ',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(top:40.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: ()  async {
                    if(userInput.isNotEmpty){
                      await makePlaylist(userInput);
                      print('New playlist $userInput made sucessfully');
                      setState(() {
                        Navigator.pop(context);
                      });
                    }else{
                      SnackBar(content: Text('Playlist needs to have a name.'));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0), // Curved edges
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 18.0,right: 18,top: 19,bottom: 19),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black, // Text color
                        fontWeight: FontWeight.bold, // More font weight
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}