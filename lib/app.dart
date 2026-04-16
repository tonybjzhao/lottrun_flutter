import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class LottFunApp extends StatelessWidget {
  const LottFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LottFun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A), // deep purple
          secondary: const Color(0xFFFFB300), // amber
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6A1B9A),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
