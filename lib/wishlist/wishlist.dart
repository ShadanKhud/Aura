import 'dart:convert';
import 'package:aura_app/cart_folder/cartMainPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Home/listMode.dart';
import 'package:aura_app/Settings/settings.dart';
import 'package:aura_app/itemDetails/ItemDetailsPage.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late Future<List<Map<String, dynamic>>> wishlistItems;

  @override
  void initState() {
    super.initState();
    wishlistItems = fetchWishlistItems();
  }

  Future<List<Map<String, dynamic>>> fetchWishlistItems() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null)
        return []; // Return an empty list if no user is logged in

      String userId = user.uid;

      var wishlistSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .collection('wishlist')
          .get();

      if (wishlistSnapshot.docs.isEmpty)
        return []; // Return empty list if no items

      List<Map<String, dynamic>> wishlistData = [];

      for (var doc in wishlistSnapshot.docs) {
        var data = doc.data();
        String? productId = data['productId'];

        if (productId == null || productId.isEmpty) {
          print('Skipping item with no productId');
          continue;
        }

        print('Product ID: $productId'); // Debugging print to check productId

        var productDoc = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(productId)
            .get();

        if (productDoc.exists && productDoc.data() != null) {
          var productData = productDoc.data()!;
          print(
              'Product data: $productData'); // Debugging to verify the product data

          // Safely check for null and cast to List<String> if available
          List<String> imageUrls = (productData['images'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          String price = productData['price'] ?? 'N/A';
          price = price.replaceAll("Now", "").trim();

          wishlistData.add({
            'docId': doc.id,
            'productId': productId,
            'name': productData['title'] ?? 'No name',
            'price': price,
            'image':
                imageUrls.isNotEmpty ? imageUrls[0] : '', // Use first image
          });
        } else {
          print('No product found for productId: $productId');
        }
      }

      return wishlistData;
    } catch (e) {
      print('Error fetching wishlist items: $e');
      return []; // Always return an empty list on error
    }
  }

  Future<void> removeFromWishlist(String docId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // If no user is logged in, don't proceed

      await FirebaseFirestore.instance
          .collection('customers') // Use the 'customers' collection
         .doc(user.uid) // Document for the logged-in user
         .collection('wishlist') // The 'wishlist' sub-collection
          .doc(docId) // Document ID of the item to remove
          .delete();

      setState(() {
        wishlistItems =
            fetchWishlistItems(); // Refresh the wishlist after removal
      });
    } catch (e) {
      print("Error removing item: $e");
   }
  }

  String truncateTitle(String title) {
    return title.length > 20 ? "${title.substring(0, 20)}..." : title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF614FE0),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF614FE0),
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Wishlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                // FutureBuilder to display fetched data
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
                    padding: const EdgeInsets.all(10),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return GestureDetector(
                        onTap: () {
                          print(
                              'Navigating to details page for: ${item['name']}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailsPage(
                                itemDetails: item,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          elevation: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item['image'].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item['image'],
                                        height: 120,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 50));
                                        },
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                truncateTitle(item['name']),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.favorite,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  removeFromWishlist(
                                                      item['docId']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${item['price']} SAR",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            OutlinedButton(
                                              onPressed: () async {
                                              await moveToCart(item);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                side: const BorderSide(
                                                    color: Colors.grey),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 12.0),
                                              ),
                                              child: const Text(
                                                "Move to Cart",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 96, 95, 95),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ProductsPage()));
          } else if (index == 2) {
             Navigator.pushReplacement(
             context,
            MaterialPageRoute(builder: (context) => CartMainPage()),
            );
          }else if (index == 4) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SettingsPage()));
          }
        },
        items: const [
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

Future<void> moveToCart(Map<String, dynamic> item) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;

    // Step 1: Check if the user already has a cart
    var cartQuery = await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .where('customerId', isEqualTo: userId)
        .limit(1)
        .get();

    String cartId;

    if (cartQuery.docs.isEmpty) {
      // Step 2: Create a new cart if it doesn't exist
      var newCartRef =
          FirebaseFirestore.instance.collection('ShoppingCart').doc();
      await newCartRef.set({'customerId': userId});
      cartId = newCartRef.id;
    } else {
      // Step 3: Use existing cart ID
      cartId = cartQuery.docs.first.id;
    }

    // Step 4: Add item to the cartItems subcollection with references only
    await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .doc(cartId)
        .collection('cartItems')
        .doc(item['productId']) // Use productId as document ID to prevent duplicates
        .set({
      'productId': item['productId'], // Save productId from clothes collection
      'title': item['title'],         // Save product title (if available in the item map)
      'image': item['image'],         // Save product image (if available in the item map)
      'price': item['price'],         // Save product price (if available in the item map)
      
      'addedAt': FieldValue.serverTimestamp(),
    });

    // Step 5: Optionally remove item from wishlist if you have a wishlist collection
    // If wishlist collection exists:
    // await removeFromWishlist(item['docId']);

    print("Item moved to ShoppingCart successfully!");
  } catch (e) {
    print("Error moving item to ShoppingCart: $e");
  }
}



}
