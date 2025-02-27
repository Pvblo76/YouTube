import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YouTubeTheme extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  static const youtubeRed = Color(0xFFFF0000);
  static const youtubeDarkRed = Color(0xFFCC0000);

  // Color getters
  Color get titleColor => _isDarkMode ? Colors.white : Colors.black;
  Color get channelInfoColor =>
      _isDarkMode ? Colors.grey[200]! : Colors.grey[600]!;
  Color get containerBackgroundColor =>
      _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
  Color get verifiedIconColor => _isDarkMode ? Colors.white : Colors.grey[700]!;
  Color get scaffoldColor =>
      _isDarkMode ? const Color(0xFF0F0F0F) : Colors.white;

  YouTubeTheme() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get theme => _isDarkMode ? darkTheme : lightTheme;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: youtubeRed,
      secondary: youtubeDarkRed,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white, // Light mode scaffold color

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent, // Remove tint color
      iconTheme: IconThemeData(color: Colors.black87, size: 24),
    ),

    // Text Theme
    textTheme: TextTheme(
      titleLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: Colors.grey.shade100,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E5E5),
      thickness: 1,
      space: 1,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: youtubeRed,
      secondary: youtubeDarkRed,
      surface: Color(0xFF0F0F0F),
    ),
    scaffoldBackgroundColor:
        const Color(0xFF0F0F0F), // Dark mode scaffold color

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0F0F),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent, // Remove tint color
      iconTheme: IconThemeData(color: Colors.white, size: 24),
    ),

    // Text Theme
    textTheme: TextTheme(
      titleLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[200],
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey[200],
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey[200],
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: Colors.grey.shade900,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF303030),
      thickness: 1,
      space: 1,
    ),
  );
}
