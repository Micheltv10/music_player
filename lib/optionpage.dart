import 'package:flutter/material.dart';
import 'package:music_player/player.dart';



class MainOptionMenuWidget extends StatefulWidget {
  final Player player;
  const MainOptionMenuWidget({ Key? key, required this.player }) : super(key: key);

  @override
  _MainOptionMenuWidgetState createState() => _MainOptionMenuWidgetState();
}

class _MainOptionMenuWidgetState extends State<MainOptionMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.player.youtubeWidget,
          TextButton(
            onPressed: () async{
              widget.player.load(Uri.parse('https://www.youtube.com/watch?v=aAkMkVFwAoo'));
              widget.player.play();
            },
           child: const Text('Play Youtube Video'),),
           TextButton(
            onPressed: () async{
              widget.player.load(Uri.parse('https://www.youtube.com/watch?v=aAkMkVFwAoo'));
              widget.player.play();
            },
           child: const Text('Play Youtube Video'),),
        ],
      ),
    );
  }
}