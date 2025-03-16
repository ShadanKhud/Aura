import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // For sharing feature

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> itemDetails;

  const ItemDetailsPage({Key? key, required this.itemDetails})
      : super(key: key);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  String? selectedSize;
  String? selectedColor;
  String sortOption = "Recommended (default)";

  @override
  Widget build(BuildContext context) {
    final item = widget.itemDetails;
    print("Product ID: ${widget.itemDetails['productId']}");


    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? 'Item Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share('Check out this item: ${item['title']}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: (item['images'] as List).length,
                  itemBuilder: (context, index) {
                    return Image.network(item['images'][index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Title and Price
              Text(
                item['title'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${item['price']} SAR",
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 16),
              // Colors and Sizes
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedColor,
                      hint: Text("Select Color"),
                      items: (item['colors'] as List<dynamic>)
                          .map<DropdownMenuItem<String>>((color) {
                        return DropdownMenuItem<String>(
                          value: color as String,
                          child: Text(color),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedColor = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSize,
                      hint: Text("Select Size"),
                      items: (item['sizes'] as List<dynamic>)
                          .map<DropdownMenuItem<String>>((size) {
                        return DropdownMenuItem<String>(
                          value: size as String,
                          child: Text(size),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSize = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add to Cart Button
              ElevatedButton(
onPressed: () async {
  if (selectedColor == null || selectedSize == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please select size and color"),
      ),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid;

    // Step 1: Check if ShoppingCart exists
    var cartQuery = await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .where('customerId', isEqualTo: userId)
        .limit(1)
        .get();

    String cartId;
    if (cartQuery.docs.isEmpty) {
      // Create new cart
      var newCartRef = FirebaseFirestore.instance.collection('ShoppingCart').doc();
      await newCartRef.set({
        'customerId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      cartId = newCartRef.id;
    } else {
      // Use existing cart
      cartId = cartQuery.docs.first.id;
    }

    // Step 2: Save cart item (minimal data + customization)
    await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .doc(cartId)
        .collection('cartItems')
        .doc(item['productId']) // Using the product doc ID from Firestore as doc ID
        .set({
      'productId': item['productId'], // product ID from the clothes collection
      'title': item['title'],
      'image': (item['images'] as List).isNotEmpty ? item['images'][0] : '',
      'price': item['price'],
      'store_id': item['store_id'],
      'color': selectedColor,
      'size': selectedSize,
      'quantity': 1,
      'addedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Item added to cart successfully"),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You must be logged in to add items to cart"),
      ),
    );
  }
},




                child: Text("Add to Cart"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                "Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                item['description'] ?? 'No description available.',
              ),
              const SizedBox(height: 16),
              // Ratings and Reviews
              ExpansionTile(
                title: Text("Ratings & Reviews"),
                children: [
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Summary"),
                        Text("${item['reviews'].length} Reviews"),
                      ],
                    ),
                  ),
                  ListTile(
                    title: DropdownButtonFormField<String>(
                      value: sortOption,
                      items: [
                        "Recommended (default)",
                        "Rating - High to low",
                        "Rating - Low to high",
                      ].map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          sortOption = value!;
                        });
                      },
                    ),
                  ),
                  ...item['reviews'].map<Widget>((review) {
                    return ListTile(
                      title: Text(review['reviewer_name']),
                      subtitle: Text(review['comment']),
                      trailing: Text("${review['rating']} ★"),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
