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


import 'package:flutter/foundation.dart';

class PlaylistProvider extends ChangeNotifier {
  List<String> _local_playlists = [];
  List<String> _youtube_playlists = [];
  List<String> _url = [];


  List<String> get local_playlists => _local_playlists;
  List<String> get youtube_playlists => _youtube_playlists;
  List<String> get url => _url;

  void updateUrl(List<String> url) {
    _url = url;
    notifyListeners();
  }

  void updateLocalPlaylist(List<String> newPlaylist) {
    _local_playlists = newPlaylist;
    notifyListeners();
  }

  void updateYoutubePlaylist(List<String> newPlaylist) {
    _youtube_playlists = newPlaylist;
    notifyListeners();
  }

  void updatePlaylistURLS(List<String> newPlaylistURLS){
    _youtube_playlists = newPlaylistURLS;
    print("playlist urls provider: $_youtube_playlists");
    notifyListeners();
  }
}
