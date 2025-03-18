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
              return _buildCardTile(context, user.uid, card);
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

  Future<String?> getStripeCustomerId() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customers').doc(uid).get();
        if (userDoc.exists) {
          return userDoc['stripeCustomerId'];
        } else {
          return null;
        }
      }
    } catch (e) {
      print('Error retrieving customer: $e');
    }
    return null;
  }

  Future<List<dynamic>> _fetchCards(String userId) async {
    try {
      final firebaseCards = await FirebaseFirestore.instance.collection('cards').where('customerId', isEqualTo: userId).get();
      if (firebaseCards.docs.isEmpty) return [];

      final List<String> storedPaymentIds = [];
      String? stripeCustomerId;

      for (var doc in firebaseCards.docs) {
        storedPaymentIds.add(doc['paymentMethodId'].toString());
      }

      stripeCustomerId = await getStripeCustomerId();
      if (stripeCustomerId == null) return [];

      final response = await http.get(
        Uri.parse("https://api.stripe.com/v1/payment_methods?customer=$stripeCustomerId&type=card"),
        headers: {
          "Authorization": "Bearer sk_test_51Qrl4ARth5SQH9HL6u9t5ryvllJyPSpGVtTFt3xY4US1tki0kIvdCiRnkSO3BHGWIMI6I4zImWk5nsndcreUrfJz004vj2yoQM",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null || data['data'].isEmpty) return [];

        final filteredCards = (data['data'] as List)
            .where((card) => storedPaymentIds.contains(card['id']))
            .toList();

        return filteredCards;
      }
    } catch (e) {
      print("Error fetching cards: $e");
    }
    return [];
  }

  Future<void> _deleteCard(BuildContext context, String userId, String cardId) async {
    try {
      String? stripeCustomerId = await getStripeCustomerId();
      if (stripeCustomerId == null) return;

      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_methods/$cardId/detach"),
        headers: {
          "Authorization": "Bearer sk_test_51Qrl4ARth5SQH9HL6u9t5ryvllJyPSpGVtTFt3xY4US1tki0kIvdCiRnkSO3BHGWIMI6I4zImWk5nsndcreUrfJz004vj2yoQM",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        await FirebaseFirestore.instance.collection('cards').doc(cardId).delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Card deleted successfully')));

        // Refresh the card list after deletion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreditCardsPage()), // Force refresh by recreating the page
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting card')));
      }
    } catch (e) {
      print("Error deleting card: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting card')));
    }
  }

  Widget _buildCardTile(BuildContext context, String userId, dynamic card) {
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
              SizedBox(height: 8),
              Text('$cardType **** $last4', style: TextStyle(fontSize: 16)),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              // Show confirmation dialog before deleting
              bool confirmDelete = await _showDeleteConfirmationDialog(context);
              if (confirmDelete) {
                await _deleteCard(context, userId, cardId);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
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
