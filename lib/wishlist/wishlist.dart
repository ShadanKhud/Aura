import 'dart:convert';
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
      if (user == null) return [];

      String userId = user.uid;
      var wishlistSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .collection('wishlist')
          .get();

      if (wishlistSnapshot.docs.isEmpty) return [];

      List<Map<String, dynamic>> wishlistData = [];

      for (var doc in wishlistSnapshot.docs) {
        String? productId = doc['productId'];

        if (productId == null || productId.isEmpty) continue;

        var productDoc = await FirebaseFirestore.instance
            .collection('products_asos')
            .doc(productId)
            .get();

        if (productDoc.exists && productDoc.data() != null) {
          var productData = productDoc.data()!;

          // Handle image URLs properly
          String imagesString = productData['images'] ?? '[]';
          imagesString =
              imagesString.replaceAll("'", '"'); // Ensure correct JSON format
          List<String> imageUrls = List<String>.from(jsonDecode(imagesString));

          // Handle price and remove "now" if present
          String price = productData['price'] ?? 'N/A';
          price = price.replaceAll("Now", "").trim();

          wishlistData.add({
            'docId': doc.id,
            'productId': productId,
            'name': productData['name'] ?? 'No name',
            'price': price,
            'image': imageUrls.isNotEmpty ? imageUrls[0] : '',
          });
        }
      }

      return wishlistData;
    } catch (e) {
      print('Error fetching wishlist items: $e');
      return [];
    }
  }

  Future<void> removeFromWishlist(String docId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('wishlist')
          .doc(docId)
          .delete();

      setState(() {
        wishlistItems = fetchWishlistItems();
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
                Text(
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
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
                    padding: EdgeInsets.all(10),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return GestureDetector(
                        onTap: () {
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
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                                        return Center(
                                            child: CircularProgressIndicator());
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                            child: Icon(Icons.broken_image,
                                                size: 50));
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              truncateTitle(item['name']),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.favorite,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  removeFromWishlist(
                                                      item['docId']),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "\$${item['price']}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            OutlinedButton(
                                              onPressed: () {
                                                // Move to cart functionality
                                                // Call the function to move the item to the cart, for example:
                                                // moveToCart(item['productId']);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors
                                                    .black, // Text color (black)
                                                side: const BorderSide(
                                                  color: Colors
                                                      .grey, // Border color (black)
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Corner radius
                                                ),
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 8.0,
                                                    horizontal:
                                                        12.0), // Adjust padding for smaller size
                                              ),
                                              child: const Text(
                                                "Move to Cart",
                                                style: TextStyle(
                                                  fontSize:
                                                      16, // Smaller font size (optional, adjust as needed)
                                                ),
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
    );
  }
}
