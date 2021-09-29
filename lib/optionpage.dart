import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/add_song_page.dart';
import 'package:music_player/player.dart';
import 'package:music_player/song_provider.dart';
import 'package:music_player/tagger.dart';

import 'config.dart';

class MainOptionMenuWidget extends StatefulWidget {
  final Player player;
  const MainOptionMenuWidget({Key? key, required this.player})
      : super(key: key);

  @override
  _MainOptionMenuWidgetState createState() => _MainOptionMenuWidgetState();
}

class _MainOptionMenuWidgetState extends State<MainOptionMenuWidget> {
  String textInput = "s";
  dynamic result = "";

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
              TextButton.icon(
                  onPressed: () {
                    currentTheme.switchTheme();
                  },
                  icon: const Icon(Icons.brightness_high),
                  label: Text('Switch Theme')),
              ColoredBox(
                color: Colors.blue,
                child: Column(
                  children: [
                    
                    TextButton(onPressed: (){
                      Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddSongWidget()),
              );
                    }, child: Text('Add Json', style: TextStyle(color: Colors.white),)),

                    
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  
  
}
