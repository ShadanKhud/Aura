import 'package:flutter/material.dart';
import 'package:aura_app/Settings/settings.dart';
import 'package:aura_app/Home/homeList.dart';
import 'package:aura_app/Home/listMode.dart';

class PlaceholderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete'),
      ),
      body: Center(
        child: const Text('Placeholder page - !'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        // Settings tab index
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProductsPage()),
            );
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
