import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/settings.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? name = user?.displayName ?? "Unknown";
    final String? email = user?.email ?? "Unknown";
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, $name!")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Email: $email", style: TextStyle(fontSize: 16)),
            Text("Name: $name", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),

      /// Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 96, 95, 95),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // home tab index
        onTap: (index) {
          if (index == 0) {
            return;
          } else if (index == 1) {
            //Navigator.pushReplacement(
            //context,
            //MaterialPageRoute(builder: (context) => SearchPage()),
            // );
          } else if (index == 2) {
            // Navigator.pushReplacement(
            // context,
            //MaterialPageRoute(builder: (context) => CartPage()),
            //);
          } else if (index == 3) {
            //Navigator.pushReplacement(
            //context,
            //MaterialPageRoute(builder: (context) => WishlistPage()),
            //);
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "My Cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Wishlist"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
