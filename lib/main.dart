import 'package:flutter/material.dart';
//import 'package:mycards/auth/auth_screens/phone_signup_view.dart';
import 'package:flutter/services.dart';
import 'package:mycards/data/template_data.dart';
import 'package:mycards/screens/bottom_navbar_screens/home_screen.dart';
import 'package:mycards/screens/flip_screens/card_page_view.dart';
//import 'package:mycards/screens/home_screen.dart';
import 'package:mycards/screens/screen_controller.dart';

void main() {
  runApp(const MyApp());
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Set the color of the status bar
      statusBarIconBrightness:
          Brightness.dark, // Set the icon brightness (light or dark)
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use a custom font family
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.black87,
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          displaySmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: ScreenController(),
    );
  }
}
