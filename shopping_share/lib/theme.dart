import 'package:flutter/material.dart';

Color primaryColor = const Color(0xFF141D26);
Color backgroundColor = primaryColor;

const Color bottomBarSelectedColor = Color(0xFFE68342);

ThemeData themeData() {
  return ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: backgroundColor),
    buttonTheme: ButtonThemeData(buttonColor: backgroundColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
      ),
    ),
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: backgroundColor),
  );
}
