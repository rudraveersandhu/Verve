import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../models/bottom_player.dart';
import '../screens/player.dart';
import '../services/play_audio.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {

  double _sliderValue = 0.0;

  @override
  void didUpdateWidget(covariant BottomPlayer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    //final model = context.read<BottomPlayerModel>();
    final model = context.read<BottomPlayerModel>();
    final audio = Provider.of<PlayAudio>(context);

    return Container(
      width: (MediaQuery.of(context).size.width * .985),
      color: Colors.transparent,
      child: model.isCardVisible
          ? Builder(
          builder: (context) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: model.isCardVisible ? 70 : 0,
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
                      offset: Offset(9,7)
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Consumer<BottomPlayerModel>(
                        builder: (context, value, Widget? child) {
                          return ListTile(
                            tileColor: value.cardBackgroundColor,
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 75.0, top: 0, bottom: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  spreadRadius: 4,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: GestureDetector(
                                              onTap: (){
                                                final model = context.read<BottomPlayerModel>();
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                                        Player(color: model.cardBackgroundColor),
                                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                      const begin = Offset(0.0, 1.0);
                                                      const end = Offset.zero;
                                                      const curve = Curves.decelerate;
                                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                      var offsetAnimation = animation.drive(tween);
                                                      return SlideTransition(position: offsetAnimation, child: child);
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Marquee(
                                                text: value.currentTitle,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.white,
                                                ),
                                                scrollAxis: Axis.horizontal,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                blankSpace: 20.0,
                                                velocity: 40.0,
                                                pauseAfterRound: Duration(seconds: 1),
                                                startPadding: 10.0,
                                                accelerationDuration: Duration(seconds: 2),
                                                accelerationCurve: Curves.linear,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            value.currentAuthor,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(right: 13, bottom: 13),
                              child: value.playButtonOn
                                  ? GestureDetector(
                                onTap: () {
                                  value.playButtonOn = false;
                                  audio.pauseAudio();
                                },
                                child: const Icon(
                                  Icons.pause,
                                  size: 35.0,
                                  color: Colors.white,
                                ),
                              )
                                  : GestureDetector(
                                onTap: () {
                                  value.playButtonOn = true;
                                  audio.playAudio();
                                },
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 35.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Consumer<BottomPlayerModel>(
                            builder: ( context, value, Widget? child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: PhotoView(
                                  imageProvider: CachedNetworkImageProvider(
                                    value.tUrl,
                                  ),
                                  customSize: Size(90, 90),
                                  enableRotation: true,
                                  gaplessPlayback: true,
                                  backgroundDecoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                  ),
                                ),
                              );
                            }
                        ),
                      ),

                    ),
                    Positioned(
                      top: 69,
                      bottom: MediaQuery.of(context).padding.bottom,
                      left:  -15,
                      right: -15,
                      child: GestureDetector(
                        child: StreamBuilder<int>(
                            stream: audio.positionStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Slider(value: 0.0, onChanged: (double value) {  },thumbColor: Colors.transparent,); // Display a loading indicator
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData && snapshot.data!.toDouble() <= model.currentDuration.toDouble()){
                                _sliderValue = snapshot.data!.toDouble();
                              } else if(_sliderValue == model.currentDuration.toDouble()){
                                  audio.stopAudio();
                                  _sliderValue = 0.0;
                                  model.playButtonOn = false;
                                  print("Audio tracker = ${audio.tracker} | THIS INSTANCE IS FROM BOTTOM PLAYER");
                                  if(audio.tracker == 'single'){
                                    print('Resetting player position to initial');
                                    audio.seekAudio(0);
                                  } else if (audio.tracker == 'playlist'){
                                    audio.loadNextFromPlaylist(audio.strack, audio.playlist, audio.mode );
                                  }
                              }
                              return SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: .1,
                                  activeTrackColor: Colors.white,
                                  thumbShape: SliderComponentShape.noThumb,
                                  //inactiveTrackColor: model.cardBackgroundColor.withRed(model.cardBackgroundColor.red +20).withBlue(model.cardBackgroundColor.blue +20).withGreen(model.cardBackgroundColor.blue + 20),
                                ),
                                child: Slider(
                                  inactiveColor: model.cardBackgroundColor.withRed(model.cardBackgroundColor.red +20).withBlue(model.cardBackgroundColor.blue +20).withGreen(model.cardBackgroundColor.blue + 20),
                                  value: _sliderValue <= model.currentDuration.toDouble() ? _sliderValue : 0,
                                  min: 0,
                                  max: model.currentDuration.toDouble(),
                                  onChanged: (value)  {
                                    print("XXXXXXXXXXX");
                                    if(value < model.currentDuration.toDouble()){
                                      setState(() {
                                        _sliderValue = value;
                                        audio.seekAudio(value.toInt());
                                      });
                                    }
                                  },
                                ),
                              );
                            }
                        ),
                      )
                      ,
                    )
                  ],
                ),
              ),
            );
          }
      )
          : Container(
        color: Colors.transparent,
      ),
    );
  }
}
