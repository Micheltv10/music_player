import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/player.dart';

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
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextField(
                        onChanged: (text){
                          setState(() {
                          textInput = text;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Path to Json on Phone?',
                        ),
                      ),
                    ),
                    TextButton(onPressed: (){readJson(textInput);}, child: Text('Add Json')),

                    
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

    Future<void> readJson(text) async {
    final String response = await rootBundle.loadString(text);
    final data = await json.decode(response);
    setState(() {
      result = data[""];
    });
  }
}
