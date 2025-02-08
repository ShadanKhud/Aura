import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAddressPage extends StatefulWidget {
  @override
   final String customerId; // This is the customer's document ID

  AddAddressPage({required this.customerId});
  _AddAddressPageState createState() => _AddAddressPageState();
}

// Model: Represents Address Data
class Address {
  String customerId; 
  String title;
  String phoneNumber;
  String region;
  String city;
  String street;
  String full_Address;
  String postalCode;

  Address({
    required this.customerId,
    required this.title,
    required this.phoneNumber,
    required this.region,
    required this.city,
    required this.street,
    required this.postalCode,
    required this.full_Address,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'title': title,
      'phoneNumber': phoneNumber,
      'region': region,
      'city': city,
      'street': street,
      'postalCode': postalCode,
      'full_Address': full_Address, // ✅ FIXED (Now it's included!)
    };
  }
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller: Handles Business Logic
  Future<void> saveAddress(Address address) async {
    try {
      await FirebaseFirestore.instance.collection('addresses').add(address.toMap());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Address Saved Successfully!")));
      Navigator.pop(context); // Go back after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving address: $e")));
    }
  }


  // Form Variables
  String title = "";
  String phoneNumber = "";
  String region = "";
  String city = "";
  String street = "";
  String postalCode = "";
  String full_Address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Shipping Address"),
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
              _buildTextField("Title", "Enter title", (value) => title = value),
              _buildTextField("Phone Number", "+966", (value) => phoneNumber = value, keyboardType: TextInputType.phone),
              _buildDropdownField("Select Region", ["Riyadh", "Jeddah", "Dammam"], (value) => region = value),
              _buildDropdownField("Select City", ["City A", "City B", "City C"], (value) => city = value),
              _buildTextField("Street Address", "Enter street address", (value) => street = value),
              _buildTextField("Full Address", "Enter full address with building number", (value) => full_Address = value),
              _buildTextField("Postal Code", "Enter postal code", (value) => postalCode = value, keyboardType: TextInputType.number),
              Spacer(),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // View: UI Components
  Widget _buildTextField(String label, String hint, Function(String) onSaved, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? "Required" : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String) onSaved) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        onChanged: (value) {
          if (value != null) onSaved(value);
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF614FE0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Address newAddress = Address(
              customerId: widget.customerId,
              title: title,
              phoneNumber: phoneNumber,
              region: region,
              city: city,
              street: street,
              postalCode: postalCode,
              full_Address: full_Address,
            );
            saveAddress(newAddress);
          }
        },
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
