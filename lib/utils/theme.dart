import 'package:flutter/material.dart';

// -----------------------Rachel------------------------- 
final ThemeData handymenTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,                                  // default background color
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),   // large display text
    titleLarge: TextStyle(fontSize: 30.0, fontStyle: FontStyle.normal),     // title display text
    bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),              // body/paragraph text
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: const MaterialColor(0xFFEC1A1A, {
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFF44336),
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFC62828),
      900: Color(0xFFB71C1C),
    }),
  ).copyWith(secondary: Colors.white),
);
// -----------------------Rachel-------------------------