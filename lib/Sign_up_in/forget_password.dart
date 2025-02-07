import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'code_verification.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendVerificationCode() async {
    String email = _emailController.text.trim();

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        _showDialog("Error", "No account found with this email.");
        return;
      }

      // Generate a 6-digit random code
      String verificationCode = (Random().nextInt(900000) + 100000).toString();

      // Store in Firestore
      await FirebaseFirestore.instance.collection('password_resets').doc(email).set({
        'code': verificationCode,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Normally, you'd send this via email using a backend function
      print("Verification code: $verificationCode"); 

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CodeVerificationPage(email: email)),
      );

    } catch (e) {
      _showDialog("Error", e.toString());
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter your email to receive a verification code."),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendVerificationCode,
              child: Text("Send Code"),
            ),
          ],
        ),
      ),
    );
  }
}
