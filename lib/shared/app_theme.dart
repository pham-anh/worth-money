import 'dart:core';
import 'package:flutter/material.dart';

class MyAppTheme {
  static const int _myPrimaryValue = 0xFF03396c;
  static MaterialColor myPrimarySwatch = const MaterialColor(
    _myPrimaryValue,
    <int, Color>{
      50: Color(0xffD9D9D9),
      100: Color(0xFFb3cde0),
      200: Color(0xFF6497b1),
      300: Color(0xFF005b96),
      500: Color(_myPrimaryValue),
      600: Color(_myPrimaryValue),
      700: Color(_myPrimaryValue),
      800: Color(_myPrimaryValue),
      900: Color(0xFF011f4b),
    },
  );

  static Color colorError = Colors.pink.shade800;
  static Color colorBgError = Colors.pink.shade50;
}

// static const _standard = 0xFF36AE7C;
// ++  static const _toneLight = 0xFFF9D923;
// ++  static const _toneNeutral = 0xFFEFD345;
// ++  static const _toneDark = 0xFF187498;
