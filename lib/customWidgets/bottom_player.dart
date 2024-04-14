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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../audio_player_handler.dart';
import '../main.dart';
import '../models/bottom_player.dart';
import '../screens/player.dart';
import '../services/download_video.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}



class _BottomPlayerState extends State<BottomPlayer> {
  double _sliderValue = 0.0;
  Color col = Colors.black45;


  @override
  void didUpdateWidget(covariant BottomPlayer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
    return StreamBuilder(
            stream: _mediaStateStream,
            builder: (context,snapshot) {
              if (snapshot.connectionState ==
              ConnectionState.waiting) {
              return Container();
              } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}',style: TextStyle(color: Colors.white),);
              }
              else if (snapshot.hasData && snapshot.data!.mediaItem != null) {
                _sliderValue = snapshot.data!.position.inSeconds.toDouble();
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: model.isCardVisible ? 70 : 0,
                  width: (MediaQuery.of(context).size.width * .985),
                  decoration: BoxDecoration(
                    color: convertStringToColor(snapshot.data!.mediaItem!.genre!),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 15.0,
                          spreadRadius: 2.8,
                          offset: Offset(9, 7)),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ListTile(
                            tileColor: convertStringToColor(snapshot.data!.mediaItem!.genre!),
                            contentPadding: EdgeInsets.zero,
                            title: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context,
                                        animation,
                                        secondaryAnimation) =>
                                        Player(color: model.cardBackgroundColor),
                                    transitionsBuilder:
                                        (context,
                                        animation,
                                        secondaryAnimation,
                                        child) {
                                      const begin =
                                      Offset(0.0, 1.0);
                                      const end =
                                          Offset.zero;
                                      const curve =
                                          Curves.decelerate;
                                      var tween = Tween(
                                          begin: begin,
                                          end: end)
                                          .chain(CurveTween(
                                          curve:
                                          curve));
                                      var offsetAnimation =
                                      animation
                                          .drive(tween);
                                      return SlideTransition(
                                          position:
                                          offsetAnimation,
                                          child: child);
                                    },
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 75.0, top: 0, bottom: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    spreadRadius: 4,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Marquee(
                                                text: snapshot
                                                    .data!
                                                    .mediaItem!
                                                    .title,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color:
                                                  Colors.white,
                                                ),
                                                scrollAxis:
                                                Axis.horizontal,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                blankSpace: 20.0,
                                                velocity: 40.0,
                                                pauseAfterRound:
                                                Duration(
                                                    seconds: 1),
                                                startPadding: 10.0,
                                                accelerationDuration:
                                                Duration(
                                                    seconds: 2),
                                                accelerationCurve:
                                                Curves.linear,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child:  Text(
                                                snapshot
                                                    .data!
                                                    .mediaItem!
                                                    .artist!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 14,
                                                ),
                                              )

                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            trailing: Padding(
                              padding: const EdgeInsets.only(
                                  right: 13, bottom: 13),
                              child: model.playButtonOn
                                  ? GestureDetector(
                                onTap: () {
                                  model.playButtonOn = false;
                                  model.durationPosition = _sliderValue;
                                  //snapshot.data!.mediaItem!.extras!.update('songPlay', (value) => false);
                                  audioHandler.pause();
                                },
                                child: const Icon(
                                  Icons.pause,
                                  size: 35.0,
                                  color: Colors.white,
                                ),
                              )
                                  : GestureDetector(
                                onTap: () {
                                  //playButtonOn = true;
                                  model.playButtonOn = true;
                                  //snapshot.data!.mediaItem!.extras!.update('songPlay', (value) => true);
                                  audioHandler.play();
                                },
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 35.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ),
                        Positioned(
                          top: 7,
                          bottom: 7,
                          left: 13,
                          child: Container(
                            width: 58.0,
                            height: 58.0,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  spreadRadius: 2,
                                  blurRadius: 9,
                                  offset: Offset(2, 3),
                                ),
                              ],
                              //color: Colors.orange,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: PhotoView(
                                imageProvider: CachedNetworkImageProvider(
                                  snapshot.data!.mediaItem!.artUri
                                      .toString(),
                                ),
                                customSize: Size(90, 90),
                                enableRotation: true,
                                gaplessPlayback: true,
                                backgroundDecoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 69,
                          bottom: MediaQuery.of(context).padding.bottom,
                          left: -15,
                          right: -15,
                          child: GestureDetector(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: .1,
                                activeTrackColor: Colors.white,
                                thumbShape: SliderComponentShape.noThumb,
                                //inactiveTrackColor: model.cardBackgroundColor.withRed(model.cardBackgroundColor.red +20).withBlue(model.cardBackgroundColor.blue +20).withGreen(model.cardBackgroundColor.blue + 20),
                              ),
                              child: Slider(
                                inactiveColor: model.cardBackgroundColor
                                    .withRed(
                                    model.cardBackgroundColor.red + 20)
                                    .withBlue(
                                    model.cardBackgroundColor.blue + 20)
                                    .withGreen(
                                    model.cardBackgroundColor.blue +
                                        20),
                                value: _sliderValue <=
                                    snapshot
                                        .data!.mediaItem!.duration!.inSeconds.toDouble()
                                    ? _sliderValue
                                    : 0,
                                min: 0,
                                max: snapshot
                                    .data!.mediaItem!.duration!.inSeconds.toDouble(),
                                onChanged: (value) {
                                  print("XXXXXXXXXXX");
                                  if (value <
                                      snapshot
                                          .data!.mediaItem!.duration!.inSeconds.toDouble()) {
                                    setState(() {
                                      _sliderValue = value;
                                      audioHandler.seek(
                                          Duration(seconds: value.toInt()));
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
              else if (model.isCardVisible && !snapshot.hasData){
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: model.isCardVisible ? 70 : 0,
                  width: (MediaQuery.of(context).size.width * .985),
                  decoration: BoxDecoration(
                    color: model.cardBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 15.0,
                          spreadRadius: 2.8,
                          offset: Offset(9, 7)),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Stack(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ListTile(
                              tileColor: model.cardBackgroundColor,
                              contentPadding: EdgeInsets.zero,
                              title: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context,
                                          animation,
                                          secondaryAnimation) =>
                                          Player(color: model.cardBackgroundColor),
                                      transitionsBuilder:
                                          (context,
                                          animation,
                                          secondaryAnimation,
                                          child) {
                                        const begin =
                                        Offset(0.0, 1.0);
                                        const end =
                                            Offset.zero;
                                        const curve =
                                            Curves.decelerate;
                                        var tween = Tween(
                                            begin: begin,
                                            end: end)
                                            .chain(CurveTween(
                                            curve:
                                            curve));
                                        var offsetAnimation =
                                        animation
                                            .drive(tween);
                                        return SlideTransition(
                                            position:
                                            offsetAnimation,
                                            child: child);
                                      },
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 75.0, top: 0, bottom: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      spreadRadius: 4,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Marquee(
                                                  text: model.currentTitle,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color:
                                                    Colors.white,
                                                  ),
                                                  scrollAxis:
                                                  Axis.horizontal,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  blankSpace: 20.0,
                                                  velocity: 40.0,
                                                  pauseAfterRound:
                                                  Duration(
                                                      seconds: 1),
                                                  startPadding: 10.0,
                                                  accelerationDuration:
                                                  Duration(
                                                      seconds: 2),
                                                  accelerationCurve:
                                                  Curves.linear,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child:  Text(
                                                  model.currentAuthor,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 14,
                                                  ),
                                                )

                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              trailing: Padding(
                                padding: const EdgeInsets.only(
                                    right: 13, bottom: 13),
                                child: model.playButtonOn
                                    ? GestureDetector(
                                  onTap: () {
                                    model.playButtonOn = false;
                                    model.durationPosition = _sliderValue;
                                    //snapshot.data!.mediaItem!.extras!.update('songPlay', (value) => false);
                                    audioHandler.pause();
                                  },
                                  child: const Icon(
                                    Icons.pause,
                                    size: 35.0,
                                    color: Colors.white,
                                  ),
                                )
                                    : GestureDetector(
                                  onTap: () async {

                                    audioHandler.play();
                                    //playButtonOn = true;
                                    model.playButtonOn = true;
                                    //snapshot.data!.mediaItem!.extras!.update('songPlay', (value) => true);
                                    audioHandler.play();
                                  },
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 35.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                        ),
                        Positioned(
                          top: 7,
                          bottom: 7,
                          left: 13,
                          child: Container(
                            width: 58.0,
                            height: 58.0,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  spreadRadius: 2,
                                  blurRadius: 9,
                                  offset: Offset(2, 3),
                                ),
                              ],
                              //color: Colors.orange,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: PhotoView(
                                imageProvider: CachedNetworkImageProvider(
                                  model.tUrl,
                                ),
                                customSize: Size(90, 90),
                                enableRotation: true,
                                gaplessPlayback: true,
                                backgroundDecoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 69,
                          bottom: MediaQuery.of(context).padding.bottom,
                          left: -15,
                          right: -15,
                          child: GestureDetector(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: .1,
                                activeTrackColor: Colors.white,
                                thumbShape: SliderComponentShape.noThumb,
                                //inactiveTrackColor: model.cardBackgroundColor.withRed(model.cardBackgroundColor.red +20).withBlue(model.cardBackgroundColor.blue +20).withGreen(model.cardBackgroundColor.blue + 20),
                              ),
                              child: Slider(
                                inactiveColor: model.cardBackgroundColor
                                    .withRed(
                                    model.cardBackgroundColor.red + 20)
                                    .withBlue(
                                    model.cardBackgroundColor.blue + 20)
                                    .withGreen(
                                    model.cardBackgroundColor.blue +
                                        20),
                                value: 0,
                                min: 0,
                                max: model.currentDuration.toDouble(),
                                onChanged: (value) {
                                  if (value <
                                      snapshot
                                          .data!.mediaItem!.duration!.inSeconds.toDouble()) {
                                    setState(() {
                                      _sliderValue = value;
                                      audioHandler.seek(
                                          Duration(seconds: value.toInt()));
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );

              }
              else {
                //audio.stopAudio();
                _sliderValue = 0.0;
                model.playButtonOn = false;
                return Container();
              }

            },
          );
  }

  Color convertStringToColor(String colorString) {
    String hexString = colorString.replaceAll("Color(", "").replaceAll(")", "").replaceAll("0x", "");
    int hexValue = int.parse(hexString, radix: 16);
    Color color = Color(hexValue);
    return color;
  }

  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));
}
