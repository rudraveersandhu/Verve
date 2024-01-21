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

import 'package:flutter/material.dart';

class BottomPlayerModel extends ChangeNotifier {
  bool isCardVisible = false;
  String tUrl = '';
  String currentTitle = '';
  String currentAuthor = '';
  String filePath = '';
  Color cardBackgroundColor = Colors.black12;
  bool playButtonOn = false;

  void updateData({
    required bool isCardVisible,
    required String tUrl,
    required String currentTitle,
    required String currentAuthor,
    required String filePath,
    required Color cardBackgroundColor,
    required bool playButtonOn,

  }) {
    this.isCardVisible = isCardVisible;
    this.tUrl = tUrl;
    this.currentTitle = currentTitle;
    this.currentAuthor = currentAuthor;
    this.filePath = filePath;
    this.cardBackgroundColor = cardBackgroundColor;
    this.playButtonOn =playButtonOn;
    notifyListeners();
  }
}