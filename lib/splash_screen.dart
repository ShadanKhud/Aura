import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/AuraLogo.png',
              width: 150, // Adjust the width
              height: 150, // Adjust the height
            ),
            SizedBox(height: 8), // Space between logo and tagline
            // Tagline
            Text(
              "YOUR AI SHOPPING ASSISTANT",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54, // Slightly gray text
              ),
            ),
            SizedBox(height: 40), // Space before the progress indicator
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
