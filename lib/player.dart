// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:ocarina/ocarina.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

enum YoutubePlayerState {
  off,
  pending,
  on,
}

class Player {
  OcarinaPlayer? currentPlayer;
  OcarinaPlayer? pendingPlayer;
  YoutubePlayerState youtubePlayerState = YoutubePlayerState.off;
  final YoutubePlayerController youtubeController;
  final Widget youtubeWidget;
  final List<VoidCallback> callbacks;

  static void onYoutubeCompleted(YoutubeMetaData metaData) {
    final duration = metaData.duration;
    final author = metaData.author;
    final title = metaData.title;
    final videoId = metaData.videoId;
    print(
        'onYoutubeCompleted duration=$duration, author=$author, title=$title, videoId=$videoId');
  }

  void onCompleted() {
    _onCompleted(callbacks);
  }

  static void _onCompleted(List<VoidCallback> callbacks) {
    callbacks.forEach(
      (onCompleted) => onCompleted(),
    );
  }

  Player()
      : this._(
          YoutubePlayerController(
            initialVideoId: 'aAkMkVFwAoo',
            flags: YoutubePlayerFlags(autoPlay: false),
          ),
          [],
        );

  Player._(YoutubePlayerController controller,
      List<VoidCallback> callbacks)
      : callbacks = callbacks,
        youtubeController = controller,
        youtubeWidget = SizedBox(
          child: YoutubePlayer(
            controller: controller,
            onEnded: (metaData) {
              print('YoutubePlayer.onEnded($metaData)');
              onYoutubeCompleted(metaData);
              _onCompleted(callbacks);
            },
          ),
          width: 1,
          height: 1,
        ) {
          midiPlayerChannel.setMethodCallHandler(midiPlayerHandler);
        }
  final midiPlayerChannel = MethodChannel('midi.partmaster.de/player');
  Future<dynamic> midiPlayerHandler(MethodCall methodCall) async {
    print('');
    print('Player.midiPlayerHandler(${methodCall.method})');
    print('');
    switch (methodCall.method) {
      case 'onCompleted':
        onCompleted();
        return null;
      default:
        throw MissingPluginException('notImplemented');
    }
  }
  bool midiLoaded = false;

  Future<void> load(Uri uri) {
    print('load($uri)');
    youtubePlayerState = YoutubePlayerState.off;
    if (pendingPlayer != null) {
      pendingPlayer?.dispose();
      pendingPlayer = null;
    }
    if (uri.path.endsWith('.mid') || uri.path.endsWith('.midi')) {
      return _midiLoad(uri);
    }
    if (uri.isScheme("file")) {
      pendingPlayer = OcarinaPlayer(filePath: uri.toFilePath());
      print('player${pendingPlayer!.hashCode}.load(${uri.toFilePath()})}');
      return pendingPlayer?.load() ?? Future.value(null);
    }

    final videoId = YoutubePlayer.convertUrlToId(uri.toString());
    if (videoId != null) {
      print('loadUri: YoutubePlayerState.uri videoId= $videoId loading...');
      youtubeController.load(videoId);
      final duration = youtubeController.metadata.duration;
      youtubePlayerState = YoutubePlayerState.pending;
      print(
          'loadUri: YoutubePlayerState.uri videoId= $videoId loaded duration=$duration');
    }
    return Future.value(null);
  }

  Future<void> _midiLoad(Uri uri) async {
    try {
      final String result =
          await midiPlayerChannel.invokeMethod('load', {'uri': uri.toString()});
      midiLoaded = true;
      print("midiPlayerChannel.load returns: '$result'.");
    } on PlatformException catch (e) {
      print("midiPlayerChannel.load failed: '${e.message}'.");
    }
  }

  Future<void> _midiPlay() async {
    try {
      final String result = await midiPlayerChannel.invokeMethod('play');
      print("midiPlayerChannel.play returns: '$result'.");
      midiLoaded = true;
    } on PlatformException catch (e) {
      print("midiPlayerChannel.play failed: '${e.message}'.");
    }
  }

  Future<void> _midiPause() async {
    try {
      final String result = await midiPlayerChannel.invokeMethod('pause');
      print("midiPlayerChannel.pause returns: '$result'.");
    } on PlatformException catch (e) {
      print("midiPlayerChannel.pause failed: '${e.message}'.");
    }
  }

  void _midiDispose() async {
    midiLoaded = false;
    try {
      final String result = await midiPlayerChannel.invokeMethod('dispose');
      print("midiPlayerChannel.dispose returns: '$result'.");
    } on PlatformException catch (e) {
      print("midiPlayerChannel.dispose failed: '${e.message}'.");
    }
  }

  Future<int> _midiPosition() async {
    try {
      final int result = await midiPlayerChannel.invokeMethod('position');
      print("midiPlayerChannel.position returns: '$result'.");
      return result;
    } on PlatformException catch (e) {
      print("midiPlayerChannel.position failed: '${e.message}'.");
      return 0;
    }
  }

  Future<void> play() {
    print('play');
    if (midiLoaded) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        currentPlayer = null;
      }
      return _midiPlay();
    }
    if (pendingPlayer != null) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        print("Player.play disposed currentplayer");
      }
      currentPlayer = pendingPlayer;
      print("Player.play set new currentplayer");
      pendingPlayer = null;
    }
    if (youtubePlayerState != YoutubePlayerState.off) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        currentPlayer = null;
      }
      print('play: youtubePlayerState play...');
      youtubePlayerState = YoutubePlayerState.on;
      youtubeController.play();
      final duration = youtubeController.metadata.duration;
      print('play: YoutubePlayerState playing loaded duration=$duration');
      print('play: youtubePlayerState playing');
      return Future.value(null);
    }
    print('player${currentPlayer?.hashCode}.play');
    return currentPlayer?.play() ?? Future.value(null);
  }

  Future<void> pause() {
    if (midiLoaded) {
      _midiPause();
    }
    if (youtubePlayerState == YoutubePlayerState.on) {
      youtubeController.pause();
      return Future.value(null);
    }
    return currentPlayer?.pause() ?? Future.value(null);
  }

  void dispose() {
    midiLoaded = false;
    _midiDispose();
    // youtubeController.dispose();
    currentPlayer?.dispose();
    currentPlayer = null;
    pendingPlayer?.dispose();
    pendingPlayer = null;
  }

  Future<int> position() {
    if (midiLoaded) {
      return _midiPosition();
    }
    if (youtubePlayerState == YoutubePlayerState.on) {
      return Future.value(youtubeController.value.position.inMilliseconds);
    }
    return currentPlayer?.position() ?? Future.value(0);
  }

  bool isLoaded() {
    bool result = midiLoaded ||
        youtubePlayerState != YoutubePlayerState.off ||
        (currentPlayer?.isLoaded() ?? false);
    return result;
  }

  Future<void> seek(Duration duration) {
    if (youtubePlayerState == YoutubePlayerState.on) {
      youtubeController.seekTo(duration);
      return Future.value(null);
    }
    return currentPlayer?.seek(duration) ?? Future.value(null);
  }
}
