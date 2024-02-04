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


import 'dart:io';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:flutter/cupertino.dart';

import 'package:path_provider/path_provider.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/album.dart';

class DownloadVideo {
   double downloadedSize = 0.0;
  late double totalSize ;


  bool fileExists(String filePath) {
    var file = File(filePath);
    return file.existsSync();
  }

  Future<List> downloadVideo(String videoId) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDocDir.path}/$videoId.mp3';
    var youtube = YoutubeExplode();

    try {
      if(fileExists(filePath)){
        double dur = await getFileDuration(filePath);
        return [filePath,dur];

    } else if (!fileExists(filePath)) {
        var streamManifest = await youtube.videos.streamsClient.getManifest(videoId); // Get the stream manifest for the video
        var audioOnlyStreams = streamManifest.audioOnly; // Get the audio-only streams from the manifest
        var audioStream = audioOnlyStreams.where((stream) => stream.audioCodec == 'mp4a.40.2').withHighestBitrate(); // Get the highest quality audio-only stream

        //download logic
        var audioStreamBytes = await youtube.videos.streamsClient.get(audioStream).toList(); // Get the audio stream as bytes
        await File(filePath).writeAsBytes(Uint8List.fromList(audioStreamBytes.expand((e) => e).toList()));// Save the audio stream to a file
        double duration =  await getFileDuration(filePath);
        List path_dur = [filePath,duration];
        return path_dur;

      } else {
          print("error");
          return [0,0];
        }
    } catch (e, stackTrace) {
      print("Error: $e");
      print("StackTrace: $stackTrace");

      print("An error occurred while processing the request.");
      return [0,0];
    } finally {
      youtube.close();
    }
  }

  Future<double> getFileDuration(String mediaPath) async {
    final mediaInfoSession = await FFprobeKit.getMediaInformation(mediaPath);
    final mediaInfo = mediaInfoSession.getMediaInformation()!;
    // the given duration is in fractional seconds
    final duration = double.parse(mediaInfo.getDuration()!);
    //print('Duration: $duration');
    return duration;
  }

}