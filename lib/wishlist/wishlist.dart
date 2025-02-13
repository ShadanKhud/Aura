import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late Future<List<Map<String, dynamic>>> wishlistItems;

  @override
  void initState() {
    super.initState();
    wishlistItems = fetchWishlistItems(); // Fetch wishlist items from Firestore
  }

  // Fetch wishlist items from Firestore
  Future<List<Map<String, dynamic>>> fetchWishlistItems() async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('wishlist').get();
      return snapshot.docs.map((doc) {
        return {
          'image': doc['image'] ?? '',
          'name': doc['name'] ?? 'No name', // Provide default text
          'price': doc['price'] ?? 'N/A', // Provide default text
        };
      }).toList();
    } catch (e) {
      print('Error fetching wishlist items: $e');
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: wishlistItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items in wishlist.'));
          }

          var items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: item['image'] != ''
                      ? Image.network(item['image'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported,
                          size: 50), // Default icon if no image
                  title: Text(item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['price']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // Handle favorite removal or status change
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Move to cart functionality
                        },
                        child: const Text('Move to Cart'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'My Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 3, // Index for the Wishlist tab
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home page (replace with actual navigation code)
              break;
            case 1:
              // Navigate to Search page (replace with actual navigation code)
              break;
            case 2:
              // Navigate to Cart page (replace with actual navigation code)
              break;
            case 3:
              // Already on Wishlist page, no action needed
              break;
            case 4:
              // Navigate to Settings page (replace with actual navigation code)
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
