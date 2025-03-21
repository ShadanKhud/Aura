import 'package:aura_app/cart_folder/orderSummaryPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/ShippingAddresses/newAddres.dart';
import 'package:aura_app/Settings/ShippingAddresses/EditAddressPage.dart';
import 'package:aura_app/cart_folder/paymentMethodSelectionPage.dart';

class ShippingAddressSelectionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddressSelected;

  ShippingAddressSelectionPage({required this.onAddressSelected});

  @override
  _ShippingAddressSelectionPageState createState() => _ShippingAddressSelectionPageState();
}

class _ShippingAddressSelectionPageState extends State<ShippingAddressSelectionPage> {
  Map<String, dynamic>? _selectedAddress;
  
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Select Shipping Address")),
      body: Column(
        children: [
          // Add New Address Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAddressPage(customerId: userId)),
                );
              },
              child: Text("Add new address"),
            ),
          ),
          // Address List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("addresses")
                  .where('customerId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No addresses available."));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    Map<String, dynamic> address = doc.data() as Map<String, dynamic>;

                    return Card(
                      color: _selectedAddress == address ? Colors.blue.shade100 : Colors.white,
                      child: ListTile(
                        title: Text(address['title']),
                        subtitle: Text("${address['street']}, ${address['city']}, ${address['country']}"),
                        trailing: Icon(Icons.check_circle, color: _selectedAddress == address ? Colors.blue : Colors.grey),
                        onTap: () {
                          setState(() {
                                _selectedAddress = {
      ...address,
      'id': doc.id, // <-- Add the doc.id here
    };
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Continue Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
  onPressed: _selectedAddress == null
      ? null
      : () {
          widget.onAddressSelected(_selectedAddress!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentMethodSelectionPage(
                onPaymentMethodSelected: (selectedPaymentMethod) {
                  // Go to Order Summary Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderSummaryPage(
                        selectedAddress: _selectedAddress!,
                        selectedPaymentMethod: selectedPaymentMethod,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
  child: Text("Continue"),
),

          ),
        ],
      ),
    );
  }
}
