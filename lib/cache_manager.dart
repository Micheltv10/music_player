import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Cache {
  static final instance = Cache._();

  Cache._();

  factory Cache() {
    return instance;
  }
  Future<String> get cachePath async {
    final cacheDirectory = await path.getApplicationDocumentsDirectory();
    return cacheDirectory.path;
  }

  Future<Uri> get(Uri uri) async {
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      print('Cache.get($uri): pathSegments.isEmpty');
      return uri;
    }
    final videoId = YoutubePlayer.convertUrlToId(uri.toString());
    if (videoId != null) {
      print('Cache.get($uri): videoId=$videoId');
      return uri;
    }
    final name = uri.pathSegments.last;
    final path = await cachePath;
    final file = File('$path/$name');
    final exists = file.existsSync();
    if (exists) {
      print('Cache.get($uri): $file exists');
      return file.absolute.uri;
    }
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    await response.pipe(file.openWrite());
    final length = await file.length();
    print('Cache.get($uri): downloaded $length bytes');
    return file.absolute.uri;
  }
}
