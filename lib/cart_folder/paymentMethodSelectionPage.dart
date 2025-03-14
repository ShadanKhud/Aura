import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/MyCreditCards/AddCard.dart';

class PaymentMethodSelectionPage extends StatelessWidget {
  final Function(Map<String, dynamic>) onPaymentMethodSelected;

  PaymentMethodSelectionPage({required this.onPaymentMethodSelected});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Select Payment Method")),
        body: Center(child: Text("Please log in to view your payment methods")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Payment Method"),
      ),
      body: Column(
        children: [
          // Add new card button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardPage()),
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
                "Add new payment method",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          // List of payment methods
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('cards')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: _getCardColor(doc['type']),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          _getCardLogo(doc['type']),
                          width: 50,
                          height: 50,
                        ),
                        title: Text(doc['type']),
                        subtitle: Text("**** ${doc['last4']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {
                            onPaymentMethodSelected(doc.data() as Map<String, dynamic>);
                            Navigator.pop(context); // Return to the previous screen
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

  Color _getCardColor(String type) {
    switch (type) {
      case 'Mastercard': return Colors.orange.shade100;
      case 'Visa': return Colors.blue.shade100;
      default: return Colors.grey.shade200;
    }
  }

  String _getCardLogo(String type) {
    switch (type) {
      case 'Mastercard': return 'assets/Mastercard-logo.svg.png';
      case 'Visa': return 'assets/Visa-Logo.png';
      default: return 'assets/Visa-Logo.png';
    }
  }
}
 