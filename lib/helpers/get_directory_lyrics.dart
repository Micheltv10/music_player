import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'get_directory_music.dart';

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

getDirectoriesLyrics() async {
  await _getStoragePermission();
  if (permissionGranted) {
    Directory download = Directory('storage/emulated/0/Download');
    return _getDirectoryFiles(download);
  }
}

_getDirectoryFiles(Directory directory) async {
  var files = await dirContents(directory);
  files.retainWhere((file) => file.path.endsWith('.json'));
  var filepaths = files.map((file) => file.toString()).toList();
  var lyrics = filepaths.map((name) => name.substring(35, name.length - 6)).toList();
  return lyrics;
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      onDone: () => completer.complete(files));
  return completer.future;
}
