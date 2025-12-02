
import 'package:flutter/material.dart';

// Palet Warna Utama
const primaryColor = Color(0xFF343A40); // Abu-abu gelap untuk latar belakang utama
const secondaryColor = Color(0xFF495057); // Sedikit lebih terang untuk kartu, panel
const accentColor = Color(0xFF007BFF); // Biru cerah untuk highlight, tombol, ikon
const textColor = Colors.white; // Teks putih untuk kontras
const textColorMuted = Colors.white70; // Teks yang kurang penting
const successColor = Color(0xFF28A745); // Hijau untuk status "Selesai"
const warningColor = Color(0xFFFFC107); // Kuning untuk status "Pending"
const dangerColor = Color(0xFFDC3545);  // Merah untuk status "Dibatalkan"
const infoColor = Color(0xFF17A2B8);   // Biru-cyan untuk status "Pengiriman"

// Properti Styling
const double defaultPadding = 16.0;
const double defaultBorderRadius = 12.0;

// ThemeData untuk Mode Terang (jika diperlukan, namun kita fokus ke dark)
final ThemeData lightThemeData = ThemeData(
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[100],
  cardColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black54),
    titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  colorScheme: const ColorScheme.light(
    primary: accentColor,
    secondary: secondaryColor,
    surface: Colors.white,
    background: Color(0xFFF5F5F5), // Latar belakang terang
    error: dangerColor,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    ),
  ),
);

// ThemeData utama untuk Mode Gelap
final ThemeData darkThemeData = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: primaryColor,
  cardColor: secondaryColor,
  canvasColor: secondaryColor, // Untuk background drawer/side menu
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: textColor),
    bodyMedium: TextStyle(color: textColorMuted),
    titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
    titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
    labelLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
  ),
  colorScheme: const ColorScheme.dark(
    primary: accentColor,
    secondary: accentColor, // Bisa sama atau warna lain
    surface: secondaryColor,
    background: primaryColor,
    error: dangerColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: textColor,
    onBackground: textColor,
    onError: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 1.5, vertical: defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    ),
  ),
  iconTheme: const IconThemeData(color: textColorMuted),
  dividerColor: Colors.white.withOpacity(0.1),
);

// Notifier untuk switch tema (opsional, tapi bagus untuk real-time switch)
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
