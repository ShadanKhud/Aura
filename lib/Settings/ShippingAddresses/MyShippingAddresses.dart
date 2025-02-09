import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/ShippingAddresses/newAddres.dart';

class ShippingAddressesScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shipping Addresses"),
      ),
      body: Column(
        children: [
          // Add new address button at the top
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddAddressPage(customerId: userId)),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                side: BorderSide(color: Colors.grey.shade400), // Border color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding
              ),
              child: Text(
                "Add new address",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          // StreamBuilder for displaying the addresses
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
                    return AddressCard(address);
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



Future<List<Address>> fetchAddresses(String customerId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('addresses')
      .where('customerId', isEqualTo: customerId) // Filter by customer UID
      .get();

  return querySnapshot.docs.map((doc) {
    return Address(
      customerId: doc['customerId'],
      title: doc['title'],
      phoneNumber: doc['phoneNumber'],
      region: doc['region'],
      city: doc['city'],
      street: doc['street'],
      postalCode: doc['postalCode'],
      full_Address: doc['full_Address'],
      country: doc['country'], // Ensure field names match Firestore
    );
  }).toList();
}

class AddressCard extends StatelessWidget {
  final Address address;

  AddressCard(this.address);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address.title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("full_Address: ${address.full_Address}"),
            Text("City: ${address.city}"),
            Text("Street: ${address.street}"),
            Text("Region: ${address.region}"),
            Text("Postal Code: ${address.postalCode}"),
            Text("Phone: ${address.phoneNumber}"),
            Text("country: ${address.country}"),

            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Add edit functionality here
                },
                child: Text("EDIT", style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


