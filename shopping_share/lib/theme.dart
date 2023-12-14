import 'package:flutter/material.dart';

Color primaryColor = const Color(0xFF446792);
Color backgroundColor = const Color(0xFF141D26);
Color floatingButtonColor = const Color(0xFFD9D9D9);
Color checkboxColor = const Color(0xFF8CBA51);

const Color bottomBarSelectedColor = Color(0xFFE68342);

ThemeData themeData() {
  return ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: primaryColor),
    buttonTheme: ButtonThemeData(buttonColor: primaryColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
      ),
    ),
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: backgroundColor),
  );
}
