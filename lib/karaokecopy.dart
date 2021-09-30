import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/helpers/get_directory_lyrics.dart';
import 'package:ocarina/ocarina.dart';
import 'package:path_provider/path_provider.dart';
import 'helpers/get_directory_music.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Music Player',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const MyHomePage(title: 'Home'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _timer = "";
  final player = OcarinaPlayer(
      filePath: 'storage/emulated/0/Download/Never_Gonna.mp3',
      volume: 0.3,
    );

  void startTimer(Duration time) => Timer.periodic(time, updateLyricLine);

  void updateLyricLine(Timer timer) async{
    double currenttime = 0;
    await player.position().then((value) => currenttime = value/1000.0);
    print(currenttime);
    getLyricLines(currenttime);
  }

  playRickTest() async {
    await player.load();
    startTimer(Duration(seconds: 1));
    await player.play();
  }

  getLyricLines(double currenttime) async {
    List<String> lines = List.empty();
    await getFileLines().then((result) => lines = result);
    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];
      var times = Lyric.parse(line).startTime;
      if (currenttime <= times) {
        setState(() {
          _timer = Lyric.parse(line).lyric;
          print("Line: $_timer");
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Time:',
            ),
            Text(
              '$_timer',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: IconButton(
          onPressed: () async {
            List<String> musicfiles = await getDirectoriesMusic();
            List<String> lyricsfiles = await getDirectoriesLyrics();
            print(musicfiles + lyricsfiles);
            playRickTest();
          },
          icon: Icon(Icons.arrow_downward)),
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
