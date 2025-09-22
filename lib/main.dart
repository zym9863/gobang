import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '五子棋',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513), // 深褐色
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF8B4513), // 深褐色
          secondary: const Color(0xFFD2B48C), // 淡棕色
          surface: const Color(0xFFFAF8F1), // 宣纸白
          onSurface: const Color(0xFF2C2C2C), // 深灰文字
          surfaceContainerHighest: const Color(0xFFE8E5DA), // 背景色
        ),
        useMaterial3: true,
        // 增强按钮样式
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // 增强应用栏样式
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B4513),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black26,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // 增强文字样式
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF2C2C2C),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ),
      home: const GameScreen(),
    );
  }
}
