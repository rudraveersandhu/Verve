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
import 'package:verve/models/album.dart';
import '../models/bottom_player.dart';
import '../services/download_video.dart';
import '../services/play_audio.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final ABmodel = context.watch<AlbumModel>();

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ABmodel.cardBackgroundColor.withAlpha(500), Colors.black.withOpacity(.96)],
          stops: [0.3,.65]
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
                    expandedHeight: 260 ,
                    backgroundColor: ABmodel.cardBackgroundColor.withAlpha(500),
                    elevation: 0,
                    pinned: true,
                    toolbarHeight: 40,
                    //floating: true,
                    automaticallyImplyLeading: true,
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
                                Center(
                                  child: Container(
                                    width: 200.0,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.6),
                                          spreadRadius: 10,
                                          blurRadius: 35,
                                          offset: Offset(15, 15),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: PhotoView(
                                        imageProvider: NetworkImage(
                                            ABmodel.tUrl
                                        ),
                                        customSize: Size(380, 380),
                                        enableRotation: true,
                                        backgroundDecoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 13),
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
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0,bottom: 35),
                              child: Container(width: MediaQuery.of(context).size.width- 120,
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.waveform_path,color: Colors.grey.shade500,),
                                      SizedBox(width: 7,),
                                      Text("Listen on verve",maxLines: 3,style: TextStyle(color: Colors.grey.shade500,fontSize: 12,fontWeight: FontWeight.w500),),

                                    ],
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(Icons.play_circle_filled_rounded,color: Colors.white,size: 77,),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            final model = context.read<BottomPlayerModel>();
                            final audio = Provider.of<PlayAudio>(context, listen: false);
                            String audpath = await DownloadVideo().downloadVideo(ABmodel.vId);
                            await _updateCardColor(ABmodel.tUrl);
                            updateRetain(ABmodel.currentTitle, ABmodel.currentAuthor, ABmodel.tUrl, audpath, ABmodel.tUrl);
                            audio.initializeAudioPlayer(audpath);
                            audio.playAudio();
                            setState(() {
                              model.isCardVisible = true;
                              model.tUrl = ABmodel.tUrl;
                              model.currentTitle = ABmodel.currentTitle;
                              model.currentAuthor = ABmodel.currentAuthor;
                              model.filePath = audpath;
                              model.isCardVisible = true;
                              model.playButtonOn = true;
                            });
                          },
                          child: Container(height: 70,width: MediaQuery.of(context).size.width-5, color: Colors.transparent,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:15.0),
                                child: Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.8),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: Offset(2, 3),
                                      ),
                                    ],
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: PhotoView(
                                      imageProvider: NetworkImage(
                                          ABmodel.tUrl
                                      ),
                                      customSize: Size(120, 120),
                                      enableRotation: true,
                                      backgroundDecoration: BoxDecoration(
                                        color: Theme.of(context).canvasColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top:12.0,left: 12,right: 12),
                                    child: Container(
                                      width: 220,
                                      child: Text(ABmodel.currentTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top:5.0),
                                    child: Container(
                                      width: 220,
                                      child: Text('${ABmodel.currentAuthor}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 15,),
                              Icon(Icons.play_arrow,color: Colors.white,size: 33,)
                            ],
                          ),),
                        )
                      ],
                    )
                  ),
                ),
              )
          )

        ],
      ),
    );
  }

  void updateRetain(String songTitle, String artist, String thumb,
      String audPath, String tempUrl) async {
    final model = context.read<BottomPlayerModel>();
    setState(() {
      model.isCardVisible = true;
    });

    final box = await Hive.openBox('retain');
    box.put('song', songTitle);
    box.put('author', artist);
    box.put('tUrl', thumb);
    box.put('audPath', audPath);
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
