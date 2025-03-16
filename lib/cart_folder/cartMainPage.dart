import 'package:aura_app/Home/listMode.dart';
import 'package:aura_app/Settings/settings.dart';
import 'package:aura_app/cart_folder/orderSummaryPage.dart';
import 'package:aura_app/cart_folder/paymentMethodSelectionPage.dart';
import 'package:aura_app/cart_folder/shippingAddressSelectionPage.dart';
import 'package:aura_app/wishlist/wishlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class CartMainPage extends StatefulWidget {
  @override
  _CartMainPageState createState() => _CartMainPageState();
}

class _CartMainPageState extends State<CartMainPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;

      // Fetch user's shopping cart
      var cartQuery = await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .where('customerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (cartQuery.docs.isEmpty) return; // No cart found

      String cartId = cartQuery.docs.first.id;

      // Fetch cart items
      var cartItemsSnapshot = await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .doc(cartId)
          .collection('cartItems')
          .get();

      List<Map<String, dynamic>> fetchedItems = [];

      // Loop over each cart item
      for (var doc in cartItemsSnapshot.docs) {
        String itemId = doc['productId']; // Assuming 'productId' is the document ID in the 'cartItems' collection

        print("Fetching product document for productId: $itemId");

        // Fetch product details using itemId from the 'Clothes' collection
        var productDoc = await FirebaseFirestore.instance
            .collection('clothes')
            .doc(itemId)
            .get();

        if (productDoc.exists) {
          var productData = productDoc.data() ?? {};

          // Handle null values by providing default values
          String title = productData['title'] ?? 'Unknown Product';
          String image = (productData['images'] as List<dynamic>?)?.isNotEmpty == true
              ? productData['images'][0]
              : 'https://via.placeholder.com/50';
          String color = (productData['colors'] as List<dynamic>?)?.isNotEmpty == true
              ? productData['colors'][0]
              : 'Unknown';
          String size = (productData['sizes'] as List<dynamic>?)?.isNotEmpty == true
              ? productData['sizes'][0]
              : 'Unknown';
          
          // Convert price from string to double, with a fallback of 0.0
          double price = double.tryParse(productData['price'] ?? '') ?? 0.0;

          String storeId = productData['store_id'] ?? 'Unknown Store';

          fetchedItems.add({
            'Item_id': itemId,
            'title': title,
            'images': image,
            'colors': color,
            'sizes': size,
            'price': price,
            'store_id': storeId,
          });
        } else {
          print("Product document for $itemId not found.");
        }
      }

      setState(() {
        cartItems = fetchedItems;
      });
    } catch (e) {
      print("Error fetching cart items: $e");
    }
  }

  Future<void> _updateCartItem(Map<String, dynamic> item, String field, dynamic newValue) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    var cartQuery = await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .where('customerId', isEqualTo: userId)
        .limit(1)
        .get();

    if (cartQuery.docs.isEmpty) return;

    String cartId = cartQuery.docs.first.id;

    await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .doc(cartId)
        .collection('cartItems')
        .doc(item['Item_id'])
        .update({field: newValue});

    setState(() {
      cartItems = cartItems.map((cartItem) {
        if (cartItem['Item_id'] == item['Item_id']) {
          return {
            ...cartItem,
            field: newValue,
          };
        }
        return cartItem;
      }).toList();
    });

    print("$field updated to $newValue for item ${item['Item_id']}");
  } catch (e) {
    print("Error updating cart item: $e");
  }
}


Widget _buildCartItem(Map<String, dynamic> item) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('clothes').doc(item['Item_id']).get(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();

      var productData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
      List<String> availableColors = (productData['colors'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? [];
      List<String> availableSizes = (productData['sizes'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [];

      return Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Image.network(
                    item['images'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Text("Price: ${item['price']} SAR"),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeCartItem(item['Item_id']),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Dropdown for Colors
              DropdownButtonFormField<String>(
                value: item['colors'],
                items: availableColors.map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (newColor) {
                  if (newColor != null) {
                    _updateCartItem(item, 'color', newColor);
                  }
                },
                decoration: InputDecoration(labelText: "Select Color"),
              ),

              SizedBox(height: 10),

              // Dropdown for Sizes
              DropdownButtonFormField<String>(
                value: item['sizes'],
                items: availableSizes.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (newSize) {
                  if (newSize != null) {
                    _updateCartItem(item, 'size', newSize);
                  }
                },
                decoration: InputDecoration(labelText: "Select Size"),
              ),

              SizedBox(height: 10),

              // Quantity Selector (Stepper)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Quantity:"),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          int newQuantity = (item['quantity'] ?? 1) - 1;
                          if (newQuantity >= 1) {
                            _updateCartItem(item, 'quantity', newQuantity);
                          }
                        },
                      ),
                      Text("${item['quantity'] ?? 1}"),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          int newQuantity = (item['quantity'] ?? 1) + 1;
                          _updateCartItem(item, 'quantity', newQuantity);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Future<void> removeCartItem(String itemId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;
      var cartQuery = await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .where('customerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (cartQuery.docs.isEmpty) return;

      String cartId = cartQuery.docs.first.id;

      await FirebaseFirestore.instance
          .collection('ShoppingCart')
          .doc(cartId)
          .collection('cartItems')
          .doc(itemId)
          .delete();

      setState(() {
        cartItems.removeWhere((item) => item['Item_id'] == itemId);
      });
    } catch (e) {
      print("Error removing item from cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = groupBy(cartItems, (item) => item['store_id']);

    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : ListView(
              children: groupedItems.entries.map((entry) {
                final storeName = entry.key;
                final items = entry.value;
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        Column(
                          children: items.map((item) {
                            return _buildCartItem(item);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cartItems.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ShippingAddressSelectionPage(
        onAddressSelected: (selectedAddress) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentMethodSelectionPage(
                onPaymentMethodSelected: (selectedPaymentMethod) {
                  // Proceed to order summary
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderSummaryPage(
                        selectedAddress: selectedAddress,
                        selectedPaymentMethod: selectedPaymentMethod,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ),
  );
},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      "Proceed to Checkout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Color.fromARGB(255, 96, 95, 95),
              unselectedItemColor: Colors.grey,
              currentIndex: 2,
              onTap: (index) {
                // Handle navigation here
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProductsPage()),
                  );
                } else if (index == 1) {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SearchPage()),
                  // );
                } else if (index == 2) {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => CartMainPage()),
                  // );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WishlistPage()),
                  );
                } else if (index == 4) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                }
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
