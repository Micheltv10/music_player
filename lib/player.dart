import 'package:flutter/material.dart';
import 'package:ocarina/ocarina.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

enum YoutubePlayerState { off, pending, on, }
class Player {

  OcarinaPlayer? currentPlayer;
  OcarinaPlayer? pendingPlayer;
  YoutubePlayerState youtubePlayerState = YoutubePlayerState.off;
  final YoutubePlayerController youtubeController;
  final Widget youtubeWidget;

  Player() : this._(YoutubePlayerController(initialVideoId: 'aAkMkVFwAoo'));
  Player._(YoutubePlayerController controller) : youtubeController = controller, youtubeWidget = SizedBox(child: YoutubePlayer(controller: controller), width: 1, height: 1,);

  Future<void> loadUri(Uri uri) {
    youtubePlayerState = YoutubePlayerState.off;
      if(pendingPlayer != null) {
        pendingPlayer?.dispose();
        pendingPlayer = null;
      }
    if(uri.isScheme("file")) {
    pendingPlayer = OcarinaPlayer(filePath: uri.toFilePath());
    return pendingPlayer?.load() ?? Future.value(null);
    }
    
    final videoId = YoutubePlayer.convertUrlToId(uri.toString());
    if(videoId!=null) {
      print('YoutubePlayerState.uri videoId= $videoId');
      youtubeController.load(videoId);
      youtubePlayerState = YoutubePlayerState.pending;
    }
    return Future.value(null);
  }

  Future<void> load(String filePath) {
    youtubePlayerState = YoutubePlayerState.off;
    pendingPlayer = OcarinaPlayer(filePath: filePath);
    return pendingPlayer?.load() ?? Future.value(null);
  }
  Future<void> play() {
    if (pendingPlayer != null) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();      
      }
      currentPlayer = pendingPlayer;
      pendingPlayer = null;
    }
    if(youtubePlayerState != YoutubePlayerState.off) {
      if(currentPlayer != null) {
        currentPlayer?.dispose();
        currentPlayer = null;
      }
      youtubePlayerState = YoutubePlayerState.on;
      youtubeController.play();
      return Future.value(null);
    }
    return currentPlayer?.play()  ?? Future.value(null);
  }
  Future<void> pause(){
    if(youtubePlayerState == YoutubePlayerState.on) {
      youtubeController.pause();
      return Future.value(null);
    }
    return currentPlayer?.pause() ?? Future.value(null);
  }
  void dispose() {
    youtubeController.dispose();
    currentPlayer?.dispose();
    currentPlayer = null;
    pendingPlayer?.dispose();
    pendingPlayer = null;
  }
  Future<int> position() {
    if(youtubePlayerState == YoutubePlayerState.on) {
      return Future.value(youtubeController.value.position.inMilliseconds);
    }
    return currentPlayer?.position() ?? Future.value(0);
  }
  bool isLoaded() {
    return currentPlayer?.isLoaded() ?? false;
  }
  Future<void> seek(Duration duration) {
    if(youtubePlayerState == YoutubePlayerState.on) {
      youtubeController.seekTo(duration);
      return Future.value(null);
    }
    return currentPlayer?.seek(duration) ?? Future.value(null);
  }
}