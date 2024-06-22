import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class CustomNavBar extends StatelessWidget {
  final NavBarConfig navBarConfig;
  final NavBarDecoration navBarDecoration;

  CustomNavBar({
    required this.navBarConfig,
    this.navBarDecoration = const NavBarDecoration(color: Colors.black),
  });

  Widget _buildItem(ItemConfig item, bool isSelected) {
    var activeColorPrimary = CupertinoColors.activeOrange;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: IconTheme(
            data: IconThemeData(
                size: item.iconSize,
                color: isSelected ? CupertinoColors.activeOrange : CupertinoColors.inactiveGray),
            child: isSelected ? item.icon : item.inactiveIcon,
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedNavBar(
      decoration: this.navBarDecoration,
      filter: this.navBarConfig.selectedItem.filter,
      opacity: this.navBarConfig.selectedItem.opacity,
      height: this.navBarConfig.navBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: this.navBarConfig.items.map((item) {
          int index = this.navBarConfig.items.indexOf(item);
          return Expanded(
            child: InkWell(
              onTap: () {
                this.navBarConfig.onItemSelected(index); // This is the most important part. Without this, nothing would happen if you tap on an item.
              },
              child: _buildItem(
                item,
                this.navBarConfig.selectedIndex == index,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}