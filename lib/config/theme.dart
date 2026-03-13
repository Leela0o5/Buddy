import 'package:flutter/material.dart';

// ADHD-Friendly Color Palette
class ADHDColorPalette {
  // Primary colors - calming blues and greens
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryGreen = Color(0xFF2ECC71);
  
  // Accent colors - warm, encouraging
  static const Color accentOrange = Color(0xFFE88D4C);
  static const Color accentYellow = Color(0xFFFDB913);
  
  // Semantic colors
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningOrange = Color(0xFFE67E22);
  static const Color errorRed = Color(0xFFE74C3C);
  
  // Neutral tones
  static const Color darkGrey = Color(0xFF2C3E50);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFFBDC3C7);
}

// Light Theme
ThemeData createLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: ADHDColorPalette.primaryBlue,
      onPrimary: Colors.white,
      secondary: ADHDColorPalette.primaryGreen,
      onSecondary: Colors.white,
      tertiary: ADHDColorPalette.accentOrange,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: ADHDColorPalette.darkGrey,
      error: ADHDColorPalette.errorRed,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    
    // AppBar styling
    appBarTheme: AppBarTheme(
      backgroundColor: ADHDColorPalette.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Button styling - large, accessible
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: ADHDColorPalette.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Card styling
    cardTheme: CardTheme(
      color: ADHDColorPalette.lightGrey,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ADHDColorPalette.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ADHDColorPalette.mediumGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ADHDColorPalette.mediumGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ADHDColorPalette.primaryBlue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      hintStyle: const TextStyle(color: ADHDColorPalette.mediumGrey),
    ),
    
    // Text styling
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: ADHDColorPalette.darkGrey,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: ADHDColorPalette.darkGrey,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ADHDColorPalette.darkGrey,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ADHDColorPalette.darkGrey,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ADHDColorPalette.darkGrey,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ADHDColorPalette.darkGrey,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: ADHDColorPalette.darkGrey,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: ADHDColorPalette.darkGrey,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: ADHDColorPalette.mediumGrey,
      ),
    ),
  );
}

/// Dark Theme 
ThemeData createDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: ADHDColorPalette.primaryBlue,
      onPrimary: Colors.white,
      secondary: ADHDColorPalette.primaryGreen,
      onSecondary: Colors.white,
      tertiary: ADHDColorPalette.accentOrange,
      onTertiary: Colors.white,
      surface: const Color(0xFF1A1A1A),
      onSurface: const Color(0xFFE0E0E0),
      error: ADHDColorPalette.errorRed,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    // AppBar styling
    appBarTheme: AppBarTheme(
      backgroundColor: ADHDColorPalette.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Button styling
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: ADHDColorPalette.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Card styling
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ADHDColorPalette.mediumGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ADHDColorPalette.mediumGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ADHDColorPalette.primaryBlue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      hintStyle: const TextStyle(color: ADHDColorPalette.mediumGrey),
    ),
    
    // Text styling
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0E0E0),
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE0E0E0),
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE0E0E0),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE0E0E0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFFD0D0D0),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: ADHDColorPalette.mediumGrey,
      ),
    ),
  );
}