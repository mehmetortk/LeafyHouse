import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark;
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  ThemeData get lightTheme => ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.green),
    textTheme: ThemeData.light().textTheme,
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
      backgroundColor: Colors.white,
      titleTextStyle: ThemeData.light()
          .textTheme
          .headlineSmall
          ?.copyWith(color: Colors.black),
    ),
    cardColor: Colors.white,
    shadowColor: Colors.grey,
  );

  ThemeData get darkTheme => ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: Colors.orange,
    scaffoldBackgroundColor: Colors.black,
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
      backgroundColor: Colors.black,
      titleTextStyle: ThemeData.dark()
          .textTheme
          .headlineSmall
          ?.copyWith(color: Colors.white),
    ),
    cardColor: Colors.grey[850],
    shadowColor: Colors.black54,
  );

  ThemeData get currentTheme => state ? darkTheme : lightTheme;
}