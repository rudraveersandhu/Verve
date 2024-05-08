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
  int currentDuration = 0;
  double durationPosition = 0.0;
  String filePath = '';
  String vId = '';
  String user = '';
  Color cardBackgroundColor = Colors.black12;
  bool playButtonOn = false;
  List<List<dynamic>> rows = [];
  List<String> local_rows = [];
  List<String> names = [];

  void updateData({
    required bool isCardVisible,
    required String tUrl,
    required String currentTitle,
    required String currentAuthor,
    required int currentDuration,
    required double durationPosition,
    required String filePath,
    required String vId,
    required String user,
    required Color cardBackgroundColor,
    required bool playButtonOn,
    required List<List<dynamic>> rows,
    required List<String> local_rows,
    required List<String> names,

  }) {
    this.isCardVisible = isCardVisible;
    this.tUrl = tUrl;
    this.currentTitle = currentTitle;
    this.currentAuthor = currentAuthor;
    this.currentDuration = currentDuration;
    this.durationPosition = durationPosition;
    this.filePath = filePath;
    this.vId = vId;
    this.user = user;
    this.cardBackgroundColor = cardBackgroundColor;
    this.playButtonOn =playButtonOn;
    this.rows = rows;
    this.local_rows = local_rows;
    this.names = names;
    notifyListeners();
  }
}
