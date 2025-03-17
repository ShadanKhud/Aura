import 'package:aura_app/cart_folder/orderConfirmationPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> selectedAddress;
  final Map<String, dynamic> selectedPaymentMethod;

  OrderSummaryPage({
    required this.selectedAddress,
    required this.selectedPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: Text("Order Summary")),
      body: Column(
        children: [
          // Display Order Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Shipping Address:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${selectedAddress['full_Address']}"),
                SizedBox(height: 10),
                Text("Payment Method:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${selectedPaymentMethod['type']} - ****${selectedPaymentMethod['last4']}"),
              ],
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () async {
              if (user == null) return;

              // Retrieve cart items (you might need to adjust this)
              QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('cart')
                  .get();

              List<Map<String, dynamic>> cartItems = cartSnapshot.docs.map((doc) {
                return {
                  'productId': doc['productId'],
                  'name': doc['name'],
                  'size': doc['size'],
                  'color': doc['color'],
                  'quantity': doc['quantity'],
                  'price': doc['price'],
                };
              }).toList();

              // Save order to Firestore
              await FirebaseFirestore.instance.collection('orders').add({
                'userId': user.uid,
                'items': cartItems,
                'shippingAddress': selectedAddress,
                'paymentMethod': selectedPaymentMethod,
                'status': 'Pending',
                'timestamp': FieldValue.serverTimestamp(),
              });

              // Clear cart after order
              for (var doc in cartSnapshot.docs) {
                await doc.reference.delete();
              }

              // Navigate to confirmation page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderConfirmationPage()),
              );
            },
            child: Text("Confirm Order"),
          ),
        ],
      ),
    );
  }
}
