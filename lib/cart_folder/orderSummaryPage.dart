import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'OrderConfirmationPage.dart'; // Make sure this page exists!

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> selectedAddress;
  final Map<String, dynamic> selectedPaymentMethod;

  OrderSummaryPage({
    required this.selectedAddress,
    required this.selectedPaymentMethod,
  });

Future<void> createOrder(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  try {
    // Step 1: Find the ShoppingCart document for this user
    QuerySnapshot cartDocSnapshot = await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .where('customerId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (cartDocSnapshot.docs.isEmpty) {
      throw Exception("No shopping cart found for this user.");
    }

    final cartDocId = cartDocSnapshot.docs.first.id;

    // Step 2: Get cartItems subcollection inside that cart document
    QuerySnapshot cartItemsSnapshot = await FirebaseFirestore.instance
        .collection('ShoppingCart')
        .doc(cartDocId)
        .collection('cartItems')
        .get();

    if (cartItemsSnapshot.docs.isEmpty) {
      throw Exception("Cart is empty.");
    }

    // Step 3: Map the cart items properly
    List<Map<String, dynamic>> shoppingCart = cartItemsSnapshot.docs.map((doc) {
      return {
        'productId': doc['productId'],
        'store_id': doc['store_id'],
        'size': doc['size'],
        'color': doc['color'],
        'quantity': doc['quantity'],
        'price': doc['price'],
        'image': doc['image'],
        'title': doc['title'],
        'addedAt': doc['addedAt'],
      };
    }).toList();

    // Step 4: Create the order
    await FirebaseFirestore.instance.collection('orders').add({
      'customerId': user.uid,
      'cart': shoppingCart,
      'addressId': selectedAddress['id'],
      'paymentMethodId': selectedPaymentMethod['id'],
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    // Step 5: Navigate to confirmation page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrderConfirmationPage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error placing order: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Summary")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Shipping Address:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${selectedAddress['full_Address']}"),
                  SizedBox(height: 20),
                  Text("Payment Method:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${selectedPaymentMethod['type']} ${selectedPaymentMethod['last4'] != null ? '- ****${selectedPaymentMethod['last4']}' : ''}"),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await createOrder(context);
              },
              child: Text("Confirm Order"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
