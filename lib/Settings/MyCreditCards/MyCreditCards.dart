import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Settings/MyCreditCards/AddCard.dart';

class CreditCardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("My Credit Cards")),
        body: Center(child: Text("Please log in to view your cards")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Credit Cards", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardPage()),
                ),
                child: Text("Add new credit card", style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('cards')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: snapshot.data!.docs.map((doc) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getCardColor(doc['type']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(_getCardLogo(doc['type']), width: MediaQuery.of(context).size.width * 0.15),
                                SizedBox(height: 10),
                                Text(doc['type'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text("**** ${doc['last4']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.black54),
                              onPressed: () => FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('cards')
                                  .doc(doc.id)
                                  .delete(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
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
