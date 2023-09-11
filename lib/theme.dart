import 'package:flutter/material.dart';
import 'package:sensorify/constants.dart';

/// Build [ThemeData] for [Brightness.light].
ThemeData buildLightTheme() {
  return ThemeData(
    primarySwatch: Colors.pink,
    brightness: Brightness.light,
  );
}

/// Build [ThemeData] for [Brightness.dark].
ThemeData buildDarkTheme() {
  return ThemeData(
    primaryColor: primaryBackgroundColor,
    scaffoldBackgroundColor: primaryBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: appBarColor,
      foregroundColor: appBarTitleColor,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: buttonColor),
    brightness: Brightness.dark,
  );
}
