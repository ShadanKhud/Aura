import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> itemDetails;

  const ItemDetailsPage({super.key, required this.itemDetails});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  String? selectedSize;
  String? selectedColor;
  String sortOption = "Recommended (default)";
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }
    void checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var wishlistItem = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.itemDetails['productId'])
        .get();

    setState(() => isLiked = wishlistItem.exists);
  }

  void toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var wishlistRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.itemDetails['productId']);

    if (isLiked) {
      await wishlistRef.delete();
    } else {
      await wishlistRef.set({
        'productId': widget.itemDetails['productId'],
        'addedAt': FieldValue.serverTimestamp(),
      });
    }

    setState(() => isLiked = !isLiked);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.itemDetails;
    List reviews = item['reviews'] ?? [];

    if (sortOption == "Rating - High to low") {
      reviews.sort((a, b) => b['rating'].compareTo(a['rating']));
    } else if (sortOption == "Rating - Low to high") {
      reviews.sort((a, b) => a['rating'].compareTo(b['rating']));
    }

    double averageRating = reviews.isNotEmpty
        ? reviews.fold(0.0, (total, review) => total + double.parse(review['rating'].toString())) / reviews.length
        : 0;

    Map<int, int> ratingSummary = {1:0, 2:0, 3:0, 4:0, 5:0};
    for (var review in reviews) {
      int rating = double.parse(review['rating']).round();
      ratingSummary[rating] = (ratingSummary[rating] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => Share.share('Check out this item: https://Aura.com/item/${item['productId']}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: PageView(
                children: [for (var img in item['images']) Image.network(img)],
              ),
            ),
            const SizedBox(height: 16),
            Text(item['title'],
                style: TextStyle(fontSize: 20, fontFamily: 'Aleo')),
            const SizedBox(height: 8),
Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${item['price']} SAR",
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Aleo')),
                IconButton(
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                  onPressed: toggleWishlist,
                ),
              ],
            ),            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedColor,
                    hint: Text("Select Color"),
                    items: (item['colors'] as List<dynamic>).map<DropdownMenuItem<String>>((color) {
                      return DropdownMenuItem<String>(value: color, child: Text(color));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedColor = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSize,
                    hint: Text("Select Size"),
                    items: (item['sizes'] as List<dynamic>).map<DropdownMenuItem<String>>((size) {
                      return DropdownMenuItem<String>(value: size, child: Text(size));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedSize = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF614FE0),
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Add to Cart", style: TextStyle(color: Colors.white)),
onPressed: () async {
  if (selectedColor == null || selectedSize == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select size and color")),
    );
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid;

    var cartQuery = await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .where('customerId', isEqualTo: userId)
        .limit(1)
        .get();

    String cartId;
    if (cartQuery.docs.isEmpty) {
      var newCartRef = FirebaseFirestore.instance.collection('ShoppingCart').doc();
      await newCartRef.set({
        'customerId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      cartId = newCartRef.id;
    } else {
      cartId = cartQuery.docs.first.id;
    }

    // Store exactly the user's selected color and size clearly in Firebase
    await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .doc(cartId)
        .collection('cartItems')
        .doc(item['productId'])
        .set({
      'productId': item['productId'],
      'title': item['title'],
      'images': (item['images'] as List).isNotEmpty ? item['images'][0] : '',
      'price': double.tryParse(item['price'].toString()) ?? 0.0,
      'store_id': item['store_id'],
      'color': selectedColor, // clearly store user-selected color
      'size': selectedSize,   // clearly store user-selected size
      'quantity': 1,
      'addedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Item added to cart successfully")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You must be logged in to add items to cart")),
    );
  }
},


            ),
            const SizedBox(height: 24),
            Text("Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(item['description'] ?? 'No description.'),
            const SizedBox(height: 24),
            ExpansionTile(
              title: Text("Rating & Reviews (${reviews.length})"),
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(averageRating.toStringAsFixed(1)),
                  Icon(Icons.star, color: Colors.amber),
                ]),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: ratingSummary.entries.map((entry) => Row(
                      children: [
                        Text(entry.key.toString()),
                        SizedBox(width: 4),
                        Expanded(child: LinearProgressIndicator(value: entry.value / reviews.length, color: Colors.amber)),
                        SizedBox(width: 8),
                        Text(entry.value.toString()),
                      ],
                    )).toList(),
                  ),
                ),
                DropdownButtonFormField(
                  value: sortOption,
                  items: ["Recommended (default)", "Rating - High to low", "Rating - Low to high"]
                      .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                      .toList(),
                  onChanged: (val) => setState(() => sortOption = val!),
                ),
                ...reviews.map((r) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(r['reviewer_name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['createdAt'], style: TextStyle(color: Colors.grey, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(r['comment']),
                        ],
                      ),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(r['rating']),
                        Icon(Icons.star, color: Colors.amber),
                      ]),
                    ),
                    Divider(color: Colors.grey.shade300),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

