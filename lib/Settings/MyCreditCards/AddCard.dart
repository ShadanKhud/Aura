import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart'; // For hashing CVV
import 'dart:convert'; // For utf8 encoding

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = "", name = "", expDate = "", cvv = "", type = "Visa";

  // Function to validate card using Luhn Algorithm
  bool _validateCardNumber(String number) {
    number = number.replaceAll(RegExp(r"\s+"), ""); // Remove spaces
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

  // Function to hash the CVV
  String _hashCVV(String cvv) {
    var key = utf8.encode("secure_key"); // Replace with a more secure key
    var bytes = utf8.encode(cvv);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      if (!_validateCardNumber(cardNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid card number!"))
        );
        return;
      }

      FirebaseFirestore.instance.collection('cards').add({
        'cardNumber': cardNumber,
        'name': name,
        'expDate': expDate,
        'cvvToken': _hashCVV(cvv), // Store hashed CVV instead of raw
        'type': type,
        'last4': cardNumber.substring(cardNumber.length - 4),
      });

      Navigator.pop(context);
    }
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
              _buildTextField("Card Number *", "4111 1111 1111 1111", (value) => cardNumber = value, keyboardType: TextInputType.number, maxLength: 19),
              _buildTextField("Name on card", "Enter the name written on the card", (value) => name = value),
              _buildDateField("Expiration date *"),
              _buildTextField("CVV *", "123", (value) => cvv = value, keyboardType: TextInputType.number, maxLength: 3),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF614FE0), padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40)),
                onPressed: _saveCard,
                child: Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onChanged, {TextInputType keyboardType = TextInputType.text, int? maxLength}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.datetime,
        validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
        },
      ),
    );
  }
}
