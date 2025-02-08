import 'package:flutter/material.dart';
import 'package:aura_app/Sign_up_in/PlaceholderPage.dart'; // Import the PlaceholderPage
import 'package:aura_app/Sign_up_in/members/members2.dart'; // Import the members2 page

class members1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Set AppBar background color to white
        foregroundColor: Colors.black, // Change the text color of the AppBar
        elevation: 0, // Remove shadow/elevation from the AppBar
        automaticallyImplyLeading: false, // Remove the back arrow
        flexibleSpace: Align(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/AuraLogo.png', // Replace with your image asset path
            height: 40, // Adjust the size of the image in the AppBar
            fit: BoxFit.contain, // Ensure the image maintains its aspect ratio
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            // Title
            const Text(
              'Are you shopping for\n yourself only or others?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'In Aura App, we have a "Manage Members"\n'
              'feature, this feature allows you to shop for\n'
              'different people in the best way possible\n'
              'by displaying suitable items for them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40), // Increased space before buttons

            // Reversed the button order
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF614FE0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Navigate to members2 when shopping for other people
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => members2()),
                  );
                },
                child: const Text(
                  'I Shop for Other People',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                      color: Color(0xFF614FE0), width: 2), // Purple border
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Navigate to PlaceholderPage when shopping for yourself
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlaceholderPage()),
                  );
                },
                child: const Text(
                  'I\'m Shopping for Myself',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF614FE0), // Purple text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
