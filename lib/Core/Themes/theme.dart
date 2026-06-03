import 'package:blog_app/Core/Themes/app_pallate.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border([Color color = AppPallate.borderColor]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color, width: 3),
  );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallate.backgroundColor,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 50,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      titleSmall: TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: AppPallate.coralColor),
      bodySmall: TextStyle(fontSize: 12, color: AppPallate.coralColor),
      labelSmall: TextStyle(fontSize: 14, color: Colors.white),
      labelLarge: TextStyle(fontSize: 14, color: AppPallate.greyColor),
      labelMedium: TextStyle(fontSize: 18, color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(20),
      filled: true,
      fillColor: Colors.white10,
      border: _border(),
      errorBorder: _border(AppPallate.errorColor),
      enabledBorder: _border(),
      focusedBorder: _border(AppPallate.gradient1),
      hintStyle: const TextStyle(color: AppPallate.greyColor),
    ),
    appBarTheme: const AppBarTheme(
      toolbarHeight: 75,
      backgroundColor: AppPallate.backgroundColor,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    cardTheme: CardThemeData(
      color: const Color.fromRGBO(34, 34, 44, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
