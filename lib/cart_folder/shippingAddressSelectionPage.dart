import 'package:aura_app/cart_folder/paymentMethodSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/ShippingAddresses/newAddres.dart';
import 'package:aura_app/Settings/ShippingAddresses/EditAddressPage.dart';

class ShippingAddressSelectionPage extends StatelessWidget {
  final Function(Address) onAddressSelected;

  ShippingAddressSelectionPage({required this.onAddressSelected});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Shipping Address"),
      ),
      body: Column(
        children: [
          // Add new address button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAddressPage(customerId: userId),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade400),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Add new address",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          // List of addresses
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("addresses")
                  .where('customerId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No addresses available."),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    Address address = Address(
                      customerId: doc['customerId'],
                      title: doc['title'],
                      phoneNumber: doc['phoneNumber'],
                      region: doc['region'],
                      city: doc['city'],
                      street: doc['street'],
                      postalCode: doc['postalCode'],
                      full_Address: doc['full_Address'],
                      country: doc['country'],
                    );

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Color(0xFFEFEDFB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(address.title),
                        subtitle: Text(
                          "${address.street}, ${address.city}, ${address.country}",
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {
                            // Call the callback to handle the selected address
                            onAddressSelected(address);

                            // Navigate to the Payment Method Selection Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentMethodSelectionPage(
                                  onPaymentMethodSelected: (selectedPaymentMethod) {
                                    // Handle the selected payment method
                                    print("Selected Payment Method: ${selectedPaymentMethod['type']}");
                                    // Proceed to the final checkout step
                                    // You can add your final checkout logic here
                                  },
                                ),
                              ),
                            );

                            // Close the Shipping Address Selection Page
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

