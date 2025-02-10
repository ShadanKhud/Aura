import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = "", name = "", expDate = "", cvv = "", type = "Visa";

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('cards').add({
        'cardNumber': cardNumber,
        'name': name,
        'expDate': expDate,
        'cvv': cvv,
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
              _buildTextField("Card Number *", "4111 1111 1111 1111", (value) => cardNumber = value, keyboardType: TextInputType.number, maxLength: 16),
              _buildTextField("Name on card", "Enter the name written on the card", (value) => name = value),
              _buildDateField("Expiration date *"),
              _buildTextField("CVV *", "123", (value) => cvv = value, keyboardType: TextInputType.number, maxLength: 3),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:Color(0xFF614FE0), padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40)),
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
