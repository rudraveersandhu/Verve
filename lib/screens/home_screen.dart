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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:verve/customWidgets/bottom_player.dart';
import 'package:verve/screens/player.dart';
import 'package:verve/screens/premium_screen.dart';
import 'package:verve/screens/search_screen.dart';
import 'package:verve/screens/start_screen.dart';
import 'package:provider/provider.dart';
import '../models/bottom_player.dart';
import '../services/play_audio.dart';
import 'library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ChangeNotifier, TickerProviderStateMixin {
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  Duration position = Duration.zero;

  late AnimationController _acontroller;
  late Animation<double> _animation;


  @override
  void initState() {
    _acontroller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 0.0,end: 1.0).animate(_acontroller);
    super.initState();

  }

  @override
  void dispose() {
    _controller.dispose();
    _acontroller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
    final audio = Provider.of<PlayAudio>(context);
    _acontroller.forward();

    return Stack(
      children: [
        PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Colors.black,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true,
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style12,
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 3, right: 0),
                child: Container(
                  width: (MediaQuery.of(context).size.width * .985),
                  color: Colors.transparent,
                  child: model.isCardVisible
                      ? GestureDetector(
                    onTap: () {
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
                    child:  Builder(
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
                          child: FadeTransition(
                              opacity: _animation,
                              child: BottomPlayer()),
                        );
                      }
                    )
                  )
                      : Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }


  List<Widget> _buildScreens() {


    return [
      StartScreen(),
      SearchScreen(),
      LibraryScreen(),
      SettingScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.house_fill, size: 24),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.search, size: 24),
        title: ("Search"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.music_albums, size: 24),
        title: ("Library"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings, size: 24),
        title: ("Settings"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }
}
