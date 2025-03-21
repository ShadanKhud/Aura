import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:aura_app/Settings/MyCreditCards/AddCard.dart';

class PaymentMethodSelectionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onPaymentMethodSelected;

  PaymentMethodSelectionPage({required this.onPaymentMethodSelected});

  @override
  _PaymentMethodSelectionPageState createState() => _PaymentMethodSelectionPageState();
}

class _PaymentMethodSelectionPageState extends State<PaymentMethodSelectionPage> {
  List<dynamic> _cards = [];
  dynamic _selectedCard;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cards = await _fetchCards(user.uid);
      setState(() {
        _cards = cards;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Select Payment Method")),
        body: Center(child: Text("Please log in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Select Payment Method")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardPage()),
                );
                _loadCards(); // Refresh list after adding card
              },
              child: Text("Add new payment method"),
            ),
          ),
          Expanded(
            child: _cards.isEmpty
                ? Center(child: Text("No cards found. Please add one."))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return _buildCardTile(card);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedCard == null
                  ? null
                  : () {
                      widget.onPaymentMethodSelected(_selectedCard);
                    },
              child: Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile(dynamic card) {
    final cardInfo = card['card'];
    final cardId = card['id'];
    final cardType = cardInfo['brand'];
    final last4 = cardInfo['last4'];

    final isSelected = _selectedCard != null && _selectedCard['id'] == cardId;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: isSelected ? Colors.blue.shade100 : _getCardColor(cardType),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(_getCardLogo(cardType), width: 50, height: 50),
        title: Text(cardType),
        subtitle: Text("**** $last4"),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
        onTap: () {
          setState(() {
            _selectedCard = card;
          });
        },
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
        return (data['data'] as List)
            .where((card) => storedPaymentIds.contains(card['id']))
            .toList();
      }
    } catch (e) {
      print("Error fetching cards: $e");
    }
    return [];
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
