import 'package:flutter/material.dart';
import 'Sign_up_in/login.dart'; // Import the LoginScreen class

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to LoginScreen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/AuraLogo.png',
              width: 280, // Adjust the width
              height: 280, // Adjust the height
            ),
            SizedBox(height: 20), // Space between logo and tagline
            // Tagline
            Text(
              "YOUR AI SHOPPING ASSISTANT",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54, // Slightly gray text
              ),
            ),
            SizedBox(height: 20), // Space before the progress indicator
            // Loading Indicator
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

