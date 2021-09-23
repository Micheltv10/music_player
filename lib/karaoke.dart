import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:music_player/player.dart';

class KaraokeWidget extends StatefulWidget {
  final String songName;
  final Player player;
  const KaraokeWidget({Key? key, required this.songName, required this.player})
      : super(key: key);

  @override
  _KaraokeWidgetState createState() => _KaraokeWidgetState();
}

class _KaraokeWidgetState extends State<KaraokeWidget> {
  String oldLyricLine = "";
  String currentLyricLine = "";
  String nextLyricLine = "";
  int lyricsIdx = 0;
  List lyrics = [];
  Timer? timer;
  bool disposed = false;

  void startTimer(Duration time) async {
    await getLyricLines();
    Timer timer = Timer.periodic(time, updateLyricLine);
  }

  void updateLyricLine(Timer timer) async {
    double currentTime = 0;
    await widget.player
        .position()
        .then((value) => currentTime = value / 1000.0);
    for (int i = 0; i < lyrics.length; i++) {
      if (!disposed) {
        Lyric lyric = lyrics[i];
        if (i < lyrics.length) {
          Lyric nextLyric = lyrics[i + 1];
          if (lyric.startTime < currentTime &&
              nextLyric.startTime > currentTime) {
            setState(() {
              oldLyricLine = currentLyricLine;
              currentLyricLine = lyric.lyric;
              nextLyricLine = nextLyric.lyric;
            });
            break;
          }
        } else {
          setState(() {
            oldLyricLine = currentLyricLine;
            currentLyricLine = lyric.lyric;
            nextLyricLine = "End";
          });
        }
      }
    }
  }

  getLyricLines() async {
    List<String> lines = List.empty();
    lyrics = List.empty(growable: true);
    await getFileLines().then((result) => lines = result);
    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];
      var startTime = Lyric.parse(line).startTime;
      var lyric = Lyric.parse(line).lyric;
      if (!disposed) {
        lyrics.add(Lyric(lyric, startTime));
      }
    }
  }

  Future<List<String>> getFileLines() async {
    File file = File("storage/emulated/0/Download/${widget.songName}.lrc");
    if (await file.exists()) {
      return await file.readAsLines();
    } else {
      dispose();
      return ["", "", "", ""];
    }
  }

  @override
  initState() {
    super.initState();
    startTimer(const Duration(milliseconds: 300));
  }

  @override
  dispose() {
    disposed = true;
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("KaraokeWidgetState.build builded");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            currentLyricLine,
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            nextLyricLine,
            style: const TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
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
