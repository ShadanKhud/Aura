import 'package:flutter/material.dart';
import 'package:aura_app/Sign_up_in/members/addMembers.dart'; // Import the addMembers page

class members2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // White background
        foregroundColor: Colors.black, // Black text/icons
        elevation: 0, // No shadow
        title: const Text(
          'Manage Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: false, // Align title to the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            // Title
            const Text(
              'Members',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle
            const Text(
              "Shop based on everyone's preferences.\n"
              "Add up to 9 members and find clothes for them based on their style easily.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40), // Space before button

            // Add New Member Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF614FE0), // Purple color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  // Navigate to addMembers page when button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => addMembers()),
                  );
                },
                child: const Text(
                  'Add New Member',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
