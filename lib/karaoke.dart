import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/helpers/get_directory_lyrics.dart';
import 'package:ocarina/ocarina.dart';
import 'package:path_provider/path_provider.dart';
import 'helpers/get_directory_music.dart';

class KaraokeWidget extends StatefulWidget {
  String songName;
  OcarinaPlayer player;
  KaraokeWidget({ Key? key, required this.songName, required this.player}) : super(key: key);

  @override
  _KaraokeWidgetState createState() => _KaraokeWidgetState();
}

class _KaraokeWidgetState extends State<KaraokeWidget> {
  String currentLyricLine = "Nix";
  void startTimer(Duration time) => Timer.periodic(time, updateLyricLine);

  void updateLyricLine(Timer timer) async{
    double currenttime = 0;
    await widget.player.position().then((value) => currenttime = value/1000.0);
    print(currenttime);
    getLyricLines(currenttime);
  }

  getLyricLines(double currenttime) async {
    List<String> lines = List.empty();
    await getFileLines().then((result) => lines = result);
    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];
      var times = Lyric.parse(line).startTime;
      if (currenttime <= times) {
        setState(() {
          currentLyricLine = Lyric.parse(line).lyric;
          print("Line: $currentLyricLine");
        });
        break;
      }
    }
  }

  Future<List<String>> getFileLines() async {
    final data = await rootBundle.load('assets/lyric.lrc');
    final directory = (await getTemporaryDirectory()).path;
    final file = await writeToFile(data, '$directory/lyric.lrc');
    return await file.readAsLines();
  }

  Future<File> writeToFile(ByteData data, String path) {
    return File(path).writeAsBytes(data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Time:',
            ),
            Text(
              currentLyricLine,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      );
  }
}

class Lyric {
  String lyric;
  double startTime;

  factory Lyric.parse(String line) {
    int index = line.indexOf("]");
    String timeStamp = line.substring(1, index);
    String minutes = timeStamp.substring(0, 2);
    String seconds = timeStamp.substring(3).replaceAll(":", ".");
    double time = int.parse(minutes) * 60 + double.parse(seconds);
    String text = line.substring(index + 1);
    return Lyric(text, time);
  }

  Lyric(this.lyric, this.startTime);

  @override
  String toString() {
    return "Lyric{lyric: $lyric, startTime: $startTime}";
  }
}