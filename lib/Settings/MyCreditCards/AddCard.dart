import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/services.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

bool _cardComplete = false;
final String userId = FirebaseAuth.instance.currentUser!.uid;

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String cardType = "Visa";

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
Future<void> _addPaymentMethod() async {
  try {
    if (!_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Card details not complete!")),
      );
      return;
    }

    // Step 1: Create a Stripe payment method
    final paymentMethod = await Stripe.instance.createPaymentMethod(
      params: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: BillingDetails(
            name: _nameController.text,
          ),
        ),
      ),
    );

    // Step 2: Retrieve user document from Firestore (Customers collection)
    DocumentReference customerRef = FirebaseFirestore.instance.collection('customers').doc(userId);
    DocumentSnapshot customerDoc = await customerRef.get();

    String? stripeCustomerId;

    if (customerDoc.exists) {
      Map<String, dynamic> customerData = customerDoc.data() as Map<String, dynamic>;

      // Check if customer already has a Stripe customer ID
      if (customerData.containsKey('stripeCustomerId')) {
        stripeCustomerId = customerData['stripeCustomerId'];
        print('Stripe customer already exists: $stripeCustomerId');
      }
    }

    // Step 3: If no Stripe customer ID, create one
    if (stripeCustomerId == null) {
      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer sk_test_51Qrl4ARth5SQH9HL6u9t5ryvllJyPSpGVtTFt3xY4US1tki0kIvdCiRnkSO3BHGWIMI6I4zImWk5nsndcreUrfJz004vj2yoQM', // Replace with your secret key
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': FirebaseAuth.instance.currentUser!.email ?? '',
        },
      );

      final customerData = json.decode(customerResponse.body);
      stripeCustomerId = customerData['id'];

      // Step 4: Save stripeCustomerId in the customers collection in Firestore
      await customerRef.set({
        'stripeCustomerId': stripeCustomerId,
        'email': FirebaseAuth.instance.currentUser!.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((error) {
        print("Firestore save failed: $error");
      });

      print('Stripe customer created and saved in customers collection: $stripeCustomerId');
    }

    // Step 5: Attach the payment method to the Stripe customer
    final attachResponse = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_methods/${paymentMethod.id}/attach'),
      headers: {
        'Authorization': 'Bearer sk_test_51Qrl4ARth5SQH9HL6u9t5ryvllJyPSpGVtTFt3xY4US1tki0kIvdCiRnkSO3BHGWIMI6I4zImWk5nsndcreUrfJz004vj2yoQM', // Use your actual secret key
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'customer': stripeCustomerId!,
      },
    );

    final attachData = json.decode(attachResponse.body);

    if (attachResponse.statusCode != 200) {
      print('Failed to attach payment method: ${attachData['error']['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error attaching payment method: ${attachData['error']['message']}')),
      );
      return;
    }

    print('Payment Method successfully attached: ${paymentMethod.id}');

    // Step 6: Save card details in Firestore (Optional: You can also store the card in a separate collection)
    await FirebaseFirestore.instance.collection('cards').add({
      'customerId': userId,
      'stripeCustomerId': stripeCustomerId, // Save Stripe customer ID
      'name': _nameController.text,
      'type': cardType,
      'paymentMethodId': paymentMethod.id,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Card added successfully!")),
    );

    Navigator.pop(context);
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}






  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false, int? maxLength, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
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
              _buildTextField("Name on card", "Enter name on the card", _nameController),
              // Stripe's secure card input field
              CardField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onCardChanged: (card) {
                  setState(() {
                    _cardComplete = card?.complete ?? false;
                  });
                },
              ),
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

class _DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
