import 'package:aura_app/Sign_up_in/PlaceholderPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aura_app/Sign_up_in/login.dart';
import 'package:aura_app/Sign_up_in/password_field.dart';


class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isResendEnabled = true; // Flag to disable resend button temporarily

  // Check if email is verified
Future<void> _checkEmailVerification() async {
  User? user = _auth.currentUser;

  if (user != null) {
    // Reload the user to get the latest status
    await user.reload();

    if (user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PlaceholderPage()), // Redirect to the next page
      );
    } else {
      _showErrorDialog(context, "Your email is not verified yet.");
    }
  }
}

  Future<void> _resendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && _isResendEnabled) {
      setState(() {
        _isResendEnabled = false; // Disable resend button
      });

      await user.sendEmailVerification();
      _showSuccessDialog(context, "Verification email sent!");

      // Re-enable the resend button after a delay (e.g., 30 seconds)
      Future.delayed(Duration(seconds: 30), () {
        setState(() {
          _isResendEnabled = true; // Enable resend button again
        });
      });
    } else {
      _showErrorDialog(context, "Please wait a while before requesting again.");
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              "Email verification needed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkEmailVerification,
              child: const Text("I have verified my account"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF614FE0),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isResendEnabled ? _resendVerificationEmail : null, // Disable button temporarily
              child: const Text("Resend email verification"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 193, 189, 218),
              ),
            ),
          ],
        ),
      ),
    );
  }
}