import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the SplashScreen class

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the "Debug" banner
      home: SplashScreen(), // Call the SplashScreen class here
    );
  }
}