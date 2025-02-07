import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reset_password.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email;
  CodeVerificationPage({required this.email});

  @override
  _CodeVerificationPageState createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> _verifyCode() async {
    String enteredCode = _codeController.text.trim();

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('password_resets')
        .doc(widget.email)
        .get();

    if (snapshot.exists && snapshot['code'] == enteredCode) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordPage(email: widget.email)),
      );
    } else {
      _showDialog("Error", "Invalid verification code.");
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
      appBar: AppBar(title: Text("Verify Code")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter the verification code sent to your email."),
            SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Code", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyCode,
              child: Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
