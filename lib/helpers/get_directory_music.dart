import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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

getDirectoriesMusic() async {
  
    Directory download = Directory('storage/emulated/0/Download');
    return getDirectoryFiles(download);
  
}

getDirectoryFiles(Directory directory) async {
  var files = await dirContents(directory);
  files.retainWhere((file) => file.path.endsWith('.mp3'));
  var filepaths = files.map((file) => file.toString()).toList();
  var mp3s = filepaths.map((name) => name.substring(35, name.length - 5)).toList();
  return mp3s;
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      onDone: () => completer.complete(files));
  return completer.future;
}
