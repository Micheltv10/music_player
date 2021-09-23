import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';

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
  Timer? timer;
  bool disposed = false;

  void startTimer(Duration time) {
    Timer timer = Timer.periodic(time, updateLyricLine);
  }

  void updateLyricLine(Timer timer) async {
    double currenttime = 0;
    await widget.player
        .position()
        .then((value) => currenttime = value / 1000.0);
    getLyricLines(currenttime);
  }

  getLyricLines(double currenttime) async {
    List<String> lines = List.empty();
    await getFileLines().then((result) => lines = result);
    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];
      var times = Lyric.parse(line).startTime;
      if (currenttime <= times) {
        if (!disposed) {
          if (currentLyricLine != Lyric.parse(line).lyric) {
            setState(() {
              oldLyricLine = currentLyricLine;
              currentLyricLine = Lyric.parse(line).lyric;
            });
          }
        }
        break;
      }
    }
  }

  Future<List<String>> getFileLines() async {
    File file = File("storage/emulated/0/Download/${widget.songName}.lrc");
    if(await file.exists()) {
    return await file.readAsLines();
    }else {
      dispose();
      return ["","","",""];
    }
  }


  @override
  dispose() {
    disposed = true;
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    startTimer(const Duration(milliseconds: 300));
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            oldLyricLine,
            style: const TextStyle(fontSize: 11,),
          ),
          Text(
            currentLyricLine,
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              
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

/*

1. times of all lines
2. player time



w
next Linetime




 */
