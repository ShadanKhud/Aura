import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
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
      body: FutureBuilder<List<dynamic>>(
        future: _fetchCards(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } 
          if (snapshot.hasError) {
            return Center(child: Text("Failed to load cards: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No cards found"));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.map((card) {
              return _buildCardTile(context, user.uid, card, snapshot.data!);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddCardPage())),
      ),
    );
  }

  Future<List<dynamic>> _fetchCards(String userId) async {
    const stripeSecretKey = "sk_test_51Qrl4ARth5SQH9HL6u9t5ryvllJyPSpGVtTFt3xY4US1tki0kIvdCiRnkSO3BHGWIMI6I4zImWk5nsndcreUrfJz004vj2yoQM";

    final doc = await FirebaseFirestore.instance.collection('customers').doc(userId).get();
    final stripeCustomerId = doc.data()?['stripeCustomerId'];

    if (stripeCustomerId == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse("https://api.stripe.com/v1/payment_methods?customer=$stripeCustomerId&type=card"),
      headers: {
        "Authorization": "Bearer $stripeSecretKey",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Stripe API Response: ${response.body}");
      if (data['data'] == null || data['data'].isEmpty) {
          print("No cards found in Stripe for this customer.");
        return [];
      }
      return data['data'];
    } else {
      return [];
    }
  }

  Widget _buildCardTile(BuildContext context, String userId, dynamic card, List<dynamic> cards) {
    final cardInfo = card['card'];
    final cardId = card['id'];
    final cardType = cardInfo['brand'];
    final last4 = cardInfo['last4'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(cardType),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(_getCardLogo(cardType), width: 50),
              SizedBox(height: 10),
              Text(cardType.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("**** $last4", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteCard(context, userId, cardId, cards),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard(BuildContext context, String userId, String cardId, List<dynamic> cards) async {
    const stripeSecretKey = "sk_test_51Qrl4ARth5SQH9HL6u9t5ryvllJyPSpGVtTFt3xY4US1tki0kIvdCiRnkSO3BHGWIMI6I4zImWk5nsndcreUrfJz004vj2yoQM";

    final response = await http.delete(
      Uri.parse("https://api.stripe.com/v1/payment_methods/$cardId"),
      headers: {
        "Authorization": "Bearer $stripeSecretKey",
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    if (response.statusCode == 200) {
      // Update the card list locally by removing the deleted card
      cards.removeWhere((card) => card['id'] == cardId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Card deleted successfully!")));
    } else {
      print("Failed to delete card: ${response.body}");
    }
  }

  Color _getCardColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'mastercard': return Colors.orange.shade100;
      case 'visa': return Colors.blue.shade100;
      default: return Colors.grey.shade200;
    }
  }

  String _getCardLogo(String brand) {
    switch (brand.toLowerCase()) {
      case 'mastercard': return 'assets/Mastercard-logo.svg.png';
      case 'visa': return 'assets/Visa-Logo.png';
      default: return 'assets/default-card.png';
    }
  }
}
