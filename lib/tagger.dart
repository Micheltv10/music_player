import 'dart:io';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';

class AudioTagger {
  final tagger = Audiotagger();
  final defaultResult = Future.value({'length':100, 'artist':'taize'});
  bool isMp3(String filePath) {
    return filePath.endsWith('.mp3') && File(filePath).existsSync();
  }
  Future<Map<dynamic, dynamic>?> readAudioFileAsMap({required String path}) {
    try {
      return isMp3(path)? tagger.readAudioFileAsMap(path: path): defaultResult;
    } catch(e) {
      return defaultResult;
    }
  }
  Future<Map<dynamic, dynamic>?> readTagsAsMap({required String path}) {
    try {
    return isMp3(path)? tagger.readTagsAsMap(path: File(path).uri.toFilePath()): defaultResult;
    } catch(e) {
      return defaultResult;
    }
  }
  Future<Uint8List?> readArtwork({required String path}) {
    try {
    return isMp3(path)? tagger.readArtwork(path: File(path).uri.toFilePath()): Future.value(null);
    } catch(e) {
      return Future.value(null);
    }
  }
} 

