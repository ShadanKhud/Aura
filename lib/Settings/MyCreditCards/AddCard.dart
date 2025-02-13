import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String cardType = "Visa";

  // Validate Card Number using Luhn Algorithm
  bool _validateCardNumber(String number) {
    number = number.replaceAll(RegExp(r"\s+"), "");
    if (number.length < 13 || number.length > 19) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  // Send card details to the backend server.js for Stripe
  Future<void> _addPaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      if (!_validateCardNumber(_cardNumberController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid card number!")),
        );
        return;
      }

      try {
        var response = await http.post(
          Uri.parse('http//192.168.100.149:5000/add-card'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'card_number': _cardNumberController.text.replaceAll(" ", ""),
            'exp_date': _expDateController.text,
            'cvv': _cvvController.text,
            'name': _nameController.text,
          }),
        );

        var responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          FirebaseFirestore.instance.collection('cards').add({
            'cardNumber': _cardNumberController.text,
            'name': _nameController.text,
            'expDate': _expDateController.text,
            'type': cardType,
            'last4': _cardNumberController.text.substring(_cardNumberController.text.length - 4),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Card added successfully!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['error'] ?? "Error adding card.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Card"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Card Number *", "4111 1111 1111 1111", _cardNumberController, keyboardType: TextInputType.number, maxLength: 19),
              _buildTextField("Name on card", "Enter name on the card", _nameController),
              _buildTextField("Expiration Date (MM/YY) *", "MM/YY", _expDateController, keyboardType: TextInputType.datetime, maxLength: 5),
              _buildTextField("CVV *", "123", _cvvController, keyboardType: TextInputType.number, maxLength: 3, obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF614FE0),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                ),
                onPressed: _addPaymentMethod,
                child: Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
