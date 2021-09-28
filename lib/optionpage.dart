import 'package:flutter/material.dart';
import 'package:music_player/player.dart';

import 'config.dart';



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
          Column(
            children: [
              TextButton.icon(onPressed: (){currentTheme.switchTheme();}, icon: const Icon(Icons.brightness_high), label: Text('Switch Theme'))
            ],
          )
        ],
      ),
    );
  }
}