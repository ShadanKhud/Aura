import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/ShippingAddresses/newAddres.dart';
import 'package:aura_app/Settings/ShippingAddresses/EditAddressPage.dart';


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
                    // Pass the document ID to AddressCard
                    return AddressCard(
                      address,
                      documentId: doc.id, // Pass the document ID
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
  final String documentId;

  AddressCard(this.address, {required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Color(0xFFEFEDFB),//(239,237,251,255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              address.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            
            // Combined address text
            Text(
              "${address.street}, ${address.city},",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            Text(
              "${address.country}. Postal Code ${address.postalCode}",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            
            // Phone number
            Text(
              address.phoneNumber,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            
            // Divider
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
            
            // Edit button
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  Map<String, dynamic> addressData = {
                    'customerId': address.customerId,
                    'title': address.title,
                    'phoneNumber': address.phoneNumber,
                    'region': address.region,
                    'city': address.city,
                    'street': address.street,
                    'postalCode': address.postalCode,
                    'full_Address': address.full_Address,
                    'country': address.country,
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAddressPage(
                        customerId: address.customerId,
                        addressId: documentId,
                        addressData: addressData,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "EDIT",
                  style: TextStyle(//rgba(239,237,251,255)Color(0xFF614FE0)
                    color: Color(0xFF614FE0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


