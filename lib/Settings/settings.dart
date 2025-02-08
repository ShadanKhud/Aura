import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Home/homeList.dart';
import 'package:aura_app/Settings/editInformation.dart';
import 'package:aura_app/Sign_up_in/login.dart';
import 'package:aura_app/Settings/changePassword/oldPassword.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? name = user?.displayName ?? "Unknown";
    final String? email = user?.email ?? "Unknown";
    return Scaffold(
      backgroundColor: const Color(
          0xFF614FE0), // Background color to contrast with the rounded section
      appBar: AppBar(
        backgroundColor: const Color(0xFF614FE0),
        elevation: 0,
        title: Text(""),
      ),
      body: Column(
        children: [
          /// Profile Header Section
          Container(
            color: const Color(0xFF614FE0),
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? "Unknown",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email ?? "Unknown",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _signOut(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(50, 50),
                    backgroundColor: Color.fromARGB(203, 252, 82, 82),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Sign out",
                      style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(220, 255, 255, 255))),
                ),
              ],
            ),
          ),

          /// Expanded List with Rounded Top
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Main list background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                children: [
                  _buildListTile(Icons.person, "Account Information",
                      color: const Color.fromARGB(255, 111, 111, 112),
                      textColor: const Color.fromARGB(255, 111, 111, 112),
                      onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditAccountPage()),
                    );
                  }),
                  _buildListTile(
                    Icons.lock,
                    "Change Password",
                    color: const Color.fromARGB(255, 111, 111, 112),
                    textColor: const Color.fromARGB(255, 111, 111, 112),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OldPasswordPage()),
                      );
                    },
                  ),
                  _buildListTile(Icons.location_on, "My Shipping Addresses",
                      color: const Color.fromARGB(255, 111, 111, 112),
                      textColor: const Color.fromARGB(255, 111, 111, 112)),
                  _buildListTile(Icons.credit_card, "My Credit Cards",
                      color: const Color.fromARGB(255, 111, 111, 112),
                      textColor: Color.fromARGB(255, 111, 111, 112)),
                  _buildListTile(Icons.group, "Manage Members",
                      color: const Color.fromARGB(255, 111, 111, 112),
                      textColor: Color.fromARGB(255, 111, 111, 112)),
                  _buildListTile(Icons.delete, "Delete Account",
                      color: const Color.fromARGB(255, 252, 82, 82),
                      textColor: const Color.fromARGB(255, 252, 82, 82)),
                  _buildListTile(Icons.support, "Contact Support",
                      color: const Color.fromARGB(255, 111, 111, 112),
                      textColor: Color.fromARGB(255, 111, 111, 112)),
                ],
              ),
            ),
          ),
        ],
      ),

      /// Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 96, 95, 95),
        unselectedItemColor: Colors.grey,
        currentIndex: 4, // Settings tab index
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
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
            return;
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

  /// Helper function for list items
  Widget _buildListTile(IconData icon, String title,
      {Color color = Colors.black,
      Color textColor = Colors.black,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
        size: 28,
      ),
      title: Text(title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
            letterSpacing: 0.5,
            height: 1.5,
          )),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase sign-out

      // Navigate to the login page & remove all previous pages from history
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen()), // Ensure you have this screen
        (route) => false, // Removes all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: ${e.toString()}")),
      );
    }
  }
}
