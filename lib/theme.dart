import 'package:flutter/material.dart';
class MyTheme with ChangeNotifier {
  static bool _isDark = true;
  static Color color = Colors.green;
  static Color colorDeep = Colors.lightGreen;
  static Color colorAccent = Colors.greenAccent;

  ThemeMode currentTheme(){
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }
  Color currentColor(){
    return color;
  }
  Color currentDeepColor(){
    return colorDeep;
  }
  Color currentAccentColor(){
    return colorAccent;
  }
  void switchTheme(){
    _isDark = !_isDark;
    notifyListeners();
  }
  void switchColor(Color newColor){
    color = newColor;
    notifyListeners();
  }
  void switchDeepColor(Color newColor){
    colorDeep = newColor;
    notifyListeners();
  }
  void switchAccentColor(Color newColor){
    colorAccent = newColor;
    notifyListeners();
  }

}