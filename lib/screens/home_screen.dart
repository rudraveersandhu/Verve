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
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'package:verve/customWidgets/bottom_player.dart';
import 'package:verve/screens/premium_screen.dart';
import 'package:verve/screens/search_screen.dart';
import 'package:verve/screens/start_screen.dart';
import 'package:provider/provider.dart';
import '../customWidgets/custom_nav_bar.dart';
import '../models/bottom_player.dart';
import 'library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ChangeNotifier, TickerProviderStateMixin {
  PersistentTabController bpcontroller = PersistentTabController(initialIndex: 0);
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
    bpcontroller.dispose();
    _acontroller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    _acontroller.forward();
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: PersistentTabView(
                controller: bpcontroller,
                backgroundColor: Colors.black,


                //backgroundColor: Colors.black,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                stateManagement: true,
                popAllScreensOnTapOfSelectedTab: true,
                popActionScreens: PopActionScreensType.all,

                screenTransitionAnimation: ScreenTransitionAnimation(
                  curve: Curves.ease,
                  duration: Duration(milliseconds: 200),
                ),
                  /*navBarBuilder: (navBarConfig) =>
                      Style10BottomNavBar(
                          navBarConfig: navBarConfig,
                        itemAnimationProperties: ItemAnimation(),
                      ),*/
                navBarBuilder: (navBarConfig) => CustomNavBar(
                  navBarConfig: navBarConfig,
                ),
                tabs: [
                PersistentTabConfig(

                  screen: StartScreen(),
                  item: ItemConfig(
                    icon: Icon(CupertinoIcons.house_fill,
                        size: 24),
                    title: "Home",
                      activeForegroundColor: CupertinoColors.activeOrange,
                      inactiveForegroundColor: Colors.grey,
                    inactiveBackgroundColor: Colors.black,
                    activeColorSecondary: Colors.orange

                  ),
                ),
                PersistentTabConfig(
                  screen: SearchScreen(),
                  item: ItemConfig(
                    icon: Icon(CupertinoIcons.search,
                        size: 24),
                    title: "Search",
                      activeForegroundColor: CupertinoColors.activeOrange,
                      inactiveForegroundColor: Colors.grey
                  ),
                ),
                PersistentTabConfig(
                  screen: LibraryScreen(),
                  item: ItemConfig(
                    icon: Icon(CupertinoIcons.music_albums,
                        size: 24),
                    title: "Library",
                      activeForegroundColor: CupertinoColors.activeOrange,
                      inactiveForegroundColor: Colors.grey
                  ),
                ),
                PersistentTabConfig(
                  screen: SettingScreen(),
                  item: ItemConfig(
                    icon: Icon(CupertinoIcons.settings,
                        size: 24),
                    title: "Settings",
                      activeForegroundColor: CupertinoColors.activeOrange,
                      inactiveForegroundColor: Colors.grey
                  ),
                ),
              ],
              ),
              decoration: BoxDecoration(color: Colors.black),
            ),
            /*Expanded(
              child: [bpcontroller.index], // Display current screen based on index
            ),*/
          ],
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight - 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 3, right: 0),
                child: FadeTransition(
                    opacity: _animation,
                    child: Consumer<BottomPlayerModel>(
                      builder: (context, model, _) {
                        return BottomPlayer();
                      },
                    ),
              ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
