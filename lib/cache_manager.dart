import 'dart:async';
import 'dart:convert';
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

  // https://www.taize.fr/IMG/mid/dieunp_e.mid

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
      final length = await file.length();
      print('Cache.get($uri): $file exists, length=$length');
      if(length > 300) {
      return file.absolute.uri;
      }
    }

    HttpClient client = new HttpClient();
    final request = await client.getUrl(uri);
    request.headers.add("accept", 'audio/midi,text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9');
    request.headers.add('accept-encoding', 'gzip, deflate, br');
    request.headers.add('accept-language', 'de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7');
    request.headers.add('sec-ch-ua', '"Google Chrome";v="93", " Not;A Brand";v="99", "Chromium";v="93"');
    request.headers.add('sec-ch-ua-mobile', '?0');
    request.headers.add('sec-ch-ua-platform', 'macOS');
    request.headers.add('sec-fetch-mode', 'navigate');
    request.headers.add('sec-fetch-dest', 'document');
    request.headers.add('sec-fetch-site', 'none');
    request.headers.add('sec-fetch-user', '?1');
    request.headers.add('upgrade-insecure-requests', '1');
    request.headers.add('user-agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36');

    final response = await request.close();
    print('Cache.get($uri): status=${response.statusCode} headers=${response.headers}');
    if(response.statusCode != 200) {
      final contentType = response.headers.contentType;
      final encoding = Encoding.getByName(contentType?.charset);
      if(encoding !=null) {
          response.transform(encoding.decoder).listen((contents) => print(contents));
      }
      return uri;
    }
    final _ = await response.pipe(file.openWrite());
    final length = await file.length();
    print('Cache.get($uri): downloaded $length bytes');
    return file.absolute.uri;
  }
}
