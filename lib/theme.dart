import 'package:flutter/material.dart';

// Notifier to toggle between background colors
final ValueNotifier<Color> backgroundColorNotifier = ValueNotifier(const Color(0xFF1A1A1A));

class AppThemes {
  // The dark theme will be the base for the entire app.
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFD4AF37), // Gold accent
    scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Initial dark background
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD4AF37),
      secondary: Color(0xFFD4AF37),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      background: Color(0xFF1A1A1A),
      surface: Color(0xFF2A2A2A),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    fontFamily: 'Poppins',
  );
}
