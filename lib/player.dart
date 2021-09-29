// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocarina/ocarina.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'cache_manager.dart';

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

  Future<void> load(Uri uri) async {
    
    print('Playerabcde load($uri)');
    Uri cachedUri = await Cache().get(uri);
    youtubePlayerState = YoutubePlayerState.off;
    if (pendingPlayer != null) {
      pendingPlayer?.dispose();
      pendingPlayer = null;
    }
    if (cachedUri.path.endsWith('.mid') || cachedUri.path.endsWith('.midi')) {
      return _midiLoad(cachedUri);
    }
    if (cachedUri.isScheme("file")) {
      pendingPlayer = OcarinaPlayer(filePath: cachedUri.toFilePath());
      print('player${pendingPlayer!.hashCode}.load(${cachedUri.toFilePath()})}');
      return pendingPlayer?.load() ?? Future.value(null);
    }
    final videoId = YoutubePlayer.convertUrlToId(uri.toString());
    if (videoId != null) {
      print('loadUri: Youtube Playerabcde State.uri videoId= $videoId loading...');
      youtubeController.load(videoId);
      final duration = youtubeController.metadata.duration;
      youtubePlayerState = YoutubePlayerState.pending;
      print(
          'loadUri: Youtube Playerabcde State.uri videoId= $videoId loaded duration=$duration');
    }
    return Future.value(null);
  }

  Future<void> _midiLoad(Uri uri) async {
    var uriString = uri.toString();
    print("use uri $uriString");
    try {
      youtubeController.pause();
      final String result =
          await midiPlayerChannel.invokeMethod('load', {'uri': uriString});
      midiLoaded = true;
      print("midi Playerabcde Channel.load returns: '$result'.");
    } on PlatformException catch (e) {
      print("midi Playerabcde Channel.load failed: '${e.message}'.");
    }
  }

  Future<void> _midiPlay() async {
    try {
      youtubeController.pause();
      final String result = await midiPlayerChannel.invokeMethod('play');
      print("midi Playerabcde Channel.play returns: '$result'.");
      midiLoaded = true;
    } on PlatformException catch (e) {
      print("midi Playerabcde Channel.play failed: '${e.message}'.");
    }
  }

  Future<void> _midiPause() async {
    try {
      final String result = await midiPlayerChannel.invokeMethod('pause');
      print("midi Playerabcde Channel.pause returns: '$result'.");
    } on PlatformException catch (e) {
      print("midi Playerabcde Channel.pause failed: '${e.message}'.");
    }
  }

  void _midiDispose() async {
    midiLoaded = false;
    try {
      final String result = await midiPlayerChannel.invokeMethod('dispose');
      print("midi Playerabcde Channel.dispose returns: '$result'.");
    } on PlatformException catch (e) {
      print("midi Playerabcde Channel.dispose failed: '${e.message}'.");
    }
  }

  Future<int> _midiPosition() async {
    try {
      final int result = await midiPlayerChannel.invokeMethod('position');
      return result;
    } on PlatformException catch (e) {
      print("midi Playerabcde Channel.position failed: '${e.message}'.");
      return 0;
    }
  }

  Future<void> play() {
    print('midi Playerabcde play');
    if (midiLoaded) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        currentPlayer = null;
        print("midi Playerabcde disposed and set to null");
      }
      return _midiPlay();
    }
    if (pendingPlayer != null) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        print("Playerabcde .play disposed currentplayer");
      }
      currentPlayer = pendingPlayer;
      print("Playerabcde .play set new currentplayer");
      pendingPlayer = null;
    }
    if (youtubePlayerState != YoutubePlayerState.off) {
      if (currentPlayer != null) {
        currentPlayer?.dispose();
        currentPlayer = null;
      }
      print('play: youtube Playerabcde State play...');
      youtubePlayerState = YoutubePlayerState.on;
      youtubeController.play();
      print("");
      print("");
      print("Playerabcde Youtubeplayer played");
      print("");
      final duration = youtubeController.metadata.duration;
      print('play: Youtube Playerabcde State playing loaded duration=$duration');
      print('play: youtube Playerabcde State playing');
      return Future.value(null);
    }
    print('Playerabcde ${currentPlayer?.hashCode}.play');
    return currentPlayer?.play() ?? Future.value(null);
  }

  Future<void> pause() {
    print("Playerabcde paused");
    if (midiLoaded) {
      print("midi Playerabcde paused");
      _midiPause();
    }
    if (youtubePlayerState == YoutubePlayerState.on) {
      youtubeController.pause();
      print("Youtube Playerabcde paused");
      return Future.value(null);
    }
    print("current Playerabcde paused");
    return currentPlayer?.pause() ?? Future.value(null);
  }

  void dispose() {
    print("disposed midi Playerabcde");
    midiLoaded = false;
    _midiDispose();
    youtubeController.pause();
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
