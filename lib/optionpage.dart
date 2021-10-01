import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:music_player/player.dart';
import 'package:music_player/theme.dart';
import 'config.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MainOptionMenuWidget extends StatefulWidget {
  final Player player;
  const MainOptionMenuWidget({Key? key, required this.player})
      : super(key: key);

  @override
  _MainOptionMenuWidgetState createState() => _MainOptionMenuWidgetState();
}

class _MainOptionMenuWidgetState extends State<MainOptionMenuWidget> {
  Color pickerColor = MyTheme().currentColor();
  Color pickerDeepColor = MyTheme().currentDeepColor();
  Color pickerAccentColor = MyTheme().currentAccentColor();
 

  void changeDeepColor(Color color) {
    setState(() {
      pickerDeepColor = color;
    });
    MyTheme().switchDeepColor(color);
  }
  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
    MyTheme().switchColor(color);
  }
  void changeAccentColor(Color color) {
    setState(() {
      pickerAccentColor = color;
    });
    MyTheme().switchAccentColor(color);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: queryData.size.height * 0.9,
            child: ListView(
              children: [
                TextButton.icon(
                    onPressed: () {
                      currentTheme.switchTheme();
                    },
                    icon: const Icon(Icons.brightness_high),
                    label: Text('Switch Theme')),
                Center(child: Text('Switch Colors', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),)),
                Container(
                  decoration: BoxDecoration(color: pickerColor, borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ColorPicker(
                      showLabel: false,
                      pickerAreaBorderRadius: BorderRadius.all(Radius.circular(10)),
                      pickerAreaHeightPercent: 0.7,
                      pickerColor: pickerColor,
                      onColorChanged: changeColor,
                      colorPickerWidth: 200,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: pickerDeepColor, borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ColorPicker(
                      showLabel: false,
                      pickerAreaBorderRadius: BorderRadius.all(Radius.circular(10)),
                      pickerAreaHeightPercent: 0.7,
                      pickerColor: pickerDeepColor,
                      onColorChanged: changeDeepColor,
                      colorPickerWidth: 200,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: pickerAccentColor, borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ColorPicker(
                      showLabel: false,
                      pickerAreaBorderRadius: BorderRadius.all(Radius.circular(10)),
                      pickerAreaHeightPercent: 0.7,
                      pickerColor: pickerAccentColor,
                      onColorChanged: changeAccentColor,
                      colorPickerWidth: 200,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
