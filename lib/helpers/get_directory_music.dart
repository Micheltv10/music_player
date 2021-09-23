import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:music_player/types.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audiotagger/audiotagger.dart';

Audiotagger tagger = Audiotagger();
Locale de = Locale.fromSubtags(languageCode:  'de');
bool permissionGranted = false;
Future _getStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    permissionGranted = true;
  } else if (await Permission.storage.request().isPermanentlyDenied) {
    await openAppSettings();
  } else if (await Permission.storage.request().isDenied) {
    permissionGranted = false;
  }
}

Future<List<SongData>> getDirectoriesMusic() async {
  
    Directory download = Directory('storage/emulated/0/Download');
    return getDirectoryFiles(download);
  
}
Future<Duration> getAudioDuration(Uri uri) async {
    final String filePath = uri.toFilePath();
    final Map map = await tagger.readAudioFileAsMap(
        path: filePath
    ) ?? {};
    final length = map.containsKey('length') == true ? map['length'] as int : 0;
    return Duration(seconds: length);
}
Future<SongData> createSongDatafromFileSystemEntity(FileSystemEntity file, int index)async{
  final Duration duration = await getAudioDuration(file.uri);

  return SongData(index: index, subtitle: "", audios: [AudioData(duration: duration, kind: AudioKind.song, locale: de, name: file.toString().substring(35, file.toString().length - 5), uri: file.uri)], images: [], texts: [], title: file.toString().substring(35, file.toString().length - 5));
}

Future<List<SongData>> getDirectoryFiles(Directory directory) async {
  var files = await dirContents(directory);
  files.retainWhere((file) => file.path.endsWith('.mp3'));
  var filepaths = files.map((file) => file.toString()).toList();
  var songs = files.map((file) => createSongDatafromFileSystemEntity(file, files.indexOf(file)));
  var result = <SongData>[];
  for (final element in songs) {
    final song = await element;
    result.add(song);
  }
  


  var mp3s = filepaths.map((name) => name.substring(35, name.length - 5)).toList();
  return result;
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      onDone: () => completer.complete(files));
  return completer.future;
}
