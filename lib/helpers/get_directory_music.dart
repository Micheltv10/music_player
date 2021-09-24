import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:music_player/tagger.dart';
import 'package:music_player/types.dart';
// import 'package:permission_handler/permission_handler.dart';

class LocalSongProvider extends SongProvider {
  LocalSongProvider(AudioTagger tagger) : super(getDirectoriesMusic(tagger));

}

Locale de = const Locale.fromSubtags(languageCode: 'de');
bool permissionGranted = false;
/*
Future _getStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    permissionGranted = true;
  } else if (await Permission.storage.request().isPermanentlyDenied) {
    await openAppSettings();
  } else if (await Permission.storage.request().isDenied) {
    permissionGranted = false;
  }
}
*/
Future<List<SongData>> getDirectoriesMusic(AudioTagger tagger) async {
  Directory download = Directory('storage/emulated/0/Download');
  return getDirectoryFiles(download, tagger);
}

Future<Duration> getAudioDuration(Uri uri, AudioTagger tagger) async {
  final String filePath = uri.toFilePath();
  final Map map = await tagger.readAudioFileAsMap(path: filePath) ?? {};
  final length = map.containsKey('length') == true ? map['length'] as int : 100;
  return Duration(seconds: length);
}

Future<SongData> createSongDatafromFileSystemEntity(
    FileSystemEntity file, int index, AudioTagger tagger) async {
  return SongData(
      index: index,
      subtitle: "",
      audios: [
        AudioData(
            durationProvider: (_) => getAudioDuration(file.uri, tagger),
            kind: AudioKind.song,
            locale: de,
            name: file.toString().substring(35, file.toString().length - 5),
            uri: file.absolute.uri),
        AudioData(
            durationProvider: (_) => getAudioDuration(file.uri, tagger),
            kind: AudioKind.firstVoice,
            locale: de,
            name: "Centarei_ao_s_1",
            uri: Uri.parse("/storage/emulated/0/Download/cantarei_ao_s_1.mid")),
      ],
      images: [ImageData(kind: ImageKind.notes, name: "Centarei_ao_senhor", uri: Uri.parse("/storage/emulated/0/Download/centarei_ao_senhor.gif"))],
      texts: [],
      title: file.toString().substring(35, file.toString().length - 5));
}

Future<List<SongData>> getDirectoryFiles(
    Directory directory, AudioTagger tagger) async {
  var files = await dirContents(directory);
  files.retainWhere((file) => file.path.endsWith('.mp3'));
  var songs = files.map((file) =>
      createSongDatafromFileSystemEntity(file, files.indexOf(file), tagger));
  var result = <SongData>[];
  for (final element in songs) {
    final song = await element;
    result.add(song);
  }
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
