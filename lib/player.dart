// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocarina/ocarina.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as youtube;

import 'cache_manager.dart';

final _nullFuture = Future.value(null);

abstract class Player {
  Future<void> load(Uri uri);
  Future<void> play();
  Future<void> pause();
  Future<int> position();
  Future<void> seek(Duration duration);
  void dispose();
  List<VoidCallback> get callbacks;
  Widget get widget;
  bool isLoaded();
}

class LoggingPlayer implements Player {
  final Player decorated;
  LoggingPlayer(this.decorated);

  @override
  List<VoidCallback> get callbacks => decorated.callbacks;

  @override
  void dispose() => decorated.dispose();

  @override
  bool isLoaded() => decorated.isLoaded();

  @override
  Future<void> load(Uri uri) => decorated.load(uri);

  @override
  Future<void> pause() => decorated.pause();

  @override
  Future<void> play() => decorated.play();

  @override
  Future<int> position() => decorated.position();

  @override
  Future<void> seek(Duration duration) => decorated.seek(duration);

  @override
  Widget get widget => decorated.widget;

}

class Mp3Player implements Player {
  final List<VoidCallback> callbacks;
  Mp3Player(this.callbacks);
  bool loaded = false;
  OcarinaPlayer? delegate;

  @override
  void dispose() {
    delegate?.dispose();
    delegate = null;
  }

  @override
  Future<void> load(Uri uri) async {
    dispose();
    Uri cachedUri = await Cache().get(uri);
    delegate = OcarinaPlayer(filePath: cachedUri.toFilePath());
    loaded = true;
    return delegate?.load() ?? _nullFuture;
  }

  @override
  Future<void> pause() => delegate?.pause() ?? _nullFuture;

  @override
  Future<void> play() => delegate?.play() ?? _nullFuture;

  @override
  Future<int> position() => delegate?.position() ?? Future.value(0);

  @override
  Future<void> seek(Duration duration) => delegate?.seek(duration) ?? _nullFuture;

  @override
  bool isLoaded() => loaded;

  @override
  final Widget widget = SizedBox(width: 1, height: 1,);
}

class MidiPlayer implements Player {
  final List<VoidCallback> callbacks;
  final channel = MethodChannel('midi.partmaster.de/player');
  bool loaded = false;

  MidiPlayer(this.callbacks) {
    channel.setMethodCallHandler(handler);
  }
  Future<dynamic> handler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'onCompleted':
        return callbacks.forEach((callback) => callback());
      default:
        throw MissingPluginException('notImplemented');
    }
  }

  @override
  void dispose() {
    try {
      channel.invokeMethod('dispose');
    } on PlatformException catch (e) {}
  }

  @override
  Future<void> load(Uri uri) async {
    Uri cachedUri = await Cache().get(uri);
    try {
      final result = channel.invokeMethod('load', {'uri': '$cachedUri'});
      loaded = true;
      return result;
    } on PlatformException catch (e) {
      return Future.value(e);
    }
  }

  @override
  Future<void> pause() {
    try {
      return channel.invokeMethod('pause');
    } on PlatformException catch (e) {
      return Future.value(e);
    }
  }

  @override
  Future<void> play() {
    try {
      return channel.invokeMethod('play');
    } on PlatformException catch (e) {
      return Future.value(e);
    }
  }

  @override
  Future<int> position() async {
    try {
      return Future.value(await channel.invokeMethod('position'));
    } on PlatformException catch (e) {
      return Future.value(0);
    }
  }

  @override
  Future<void> seek(Duration duration) {
    // TODO: implement seek
    throw UnimplementedError();
  }

  @override
  bool isLoaded() => loaded;

  @override
  final Widget widget = SizedBox(width: 1, height: 1,);
}

class YoutubePlayer implements Player {
  @override
  final List<VoidCallback> callbacks;
  final youtube.YoutubePlayerController youtubeController;
  final Widget widget;
  bool loaded = false;

  YoutubePlayer(List<VoidCallback> callbacks)
      : this._(
          youtube.YoutubePlayerController(
            initialVideoId: 'aAkMkVFwAoo',
            flags: youtube.YoutubePlayerFlags(autoPlay: false),
          ),
          callbacks,
        );

  YoutubePlayer._(youtube.YoutubePlayerController controller, this.callbacks)
      : youtubeController = controller,
        widget = SizedBox(
          child: youtube.YoutubePlayer(
            controller: controller,
            onEnded: (metaData) {
              callbacks.forEach((onCompleted) => onCompleted());
            },
          ),
          width: 1,
          height: 1,
        ) {}
  @override
  void dispose() => youtubeController.dispose();

  @override
  Future<void> load(Uri uri) {
    final videoId = youtube.YoutubePlayer.convertUrlToId(uri.toString());
    if (videoId != null) {
      youtubeController.load(videoId);
    }
    return _nullFuture;
  }

  @override
  Future<void> pause() {
    youtubeController.pause();
    return _nullFuture;
  }

  @override
  Future<void> play() {
    youtubeController.play();
    return _nullFuture;
  }

  @override
  Future<int> position() {
    return Future.value(youtubeController.value.position.inMilliseconds);
  }

  @override
  Future<void> seek(Duration duration) {
    youtubeController.seekTo(duration);
    return _nullFuture;
  }

  @override
  bool isLoaded() => loaded;
}

class NullPlayer implements Player {
  static final instance = NullPlayer._();

  NullPlayer._();
  factory NullPlayer() => instance;

  @override
  final Widget widget = SizedBox(width: 1, height: 1,);

  @override
  List<VoidCallback> get callbacks => [];

  @override
  void dispose() {}

  @override
  Future<void> load(Uri uri) => _nullFuture;

  @override
  Future<void> pause() => _nullFuture;

  @override
  Future<void> play() => _nullFuture;

  @override
  Future<int> position() => Future.value(0);

  @override
  Future<void> seek(Duration duration) => _nullFuture;

  @override
  bool isLoaded() => false;
}

class CompoundPlayer implements Player {
  final YoutubePlayer youtubePlayer;
  final Player midiPlayer;
  final Player mp3Player;
  final List<VoidCallback> callbacks;
  Player currentPlayer = NullPlayer();

  CompoundPlayer() : this._([]);
  CompoundPlayer._(this.callbacks)
      : youtubePlayer = YoutubePlayer(callbacks),
        midiPlayer = MidiPlayer(callbacks),
        mp3Player = Mp3Player(callbacks);

  Future<void> play() => currentPlayer.play();

  Future<void> pause() => currentPlayer.pause();

  void dispose() {
    youtubePlayer.dispose();
    midiPlayer.dispose();
    mp3Player.dispose();
  }

  Future<void> seek(Duration duration) => currentPlayer.seek(duration);

  @override
  Future<void> load(Uri uri) {
    final uriString = uri.toString();
    //currentPlayer.stop();
    if (youtube.YoutubePlayer.convertUrlToId(uriString) != null) {
      currentPlayer = youtubePlayer;
    } else if (uriString.endsWith('.mid')) {
      currentPlayer = midiPlayer;
    } else {
      currentPlayer = mp3Player;
    }
    return currentPlayer.load(uri);
  }

  @override
  Future<int> position() => currentPlayer.position();

  @override
  bool isLoaded() => youtubePlayer.isLoaded() ||
        mp3Player.isLoaded() ||
        midiPlayer.isLoaded();

  @override
  Widget get widget => youtubePlayer.widget;
}
