import 'package:aura_app/Sign_up_in/members/members1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isResendEnabled = true;

  // Check if email is verified
Future<void> _checkEmailVerification() async {
  User? user = _auth.currentUser;


  if (user != null) {
    await user.reload();
    user = _auth.currentUser; 

    if (user != null && user.emailVerified) {
      await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
        'isEmailVerified': true,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => members1()),
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
        _isResendEnabled = false;
      });

      await user.sendEmailVerification();
      _showSuccessDialog(context, "Verification email sent!");

      Future.delayed(const Duration(seconds: 30), () {
        setState(() {
          _isResendEnabled = true;
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
            onPressed: () => Navigator.pop(context),
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
            onPressed: () => Navigator.pop(context),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(""), // Leave empty or provide a title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Logo
              Image.asset(
                'assets/AuraLogo.png',
                height: 50,
              ),
              const SizedBox(height: 20),
              // Progress Indicator with 2 purple dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: const Color(0xFF614FE0),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: const Color(0xFF614FE0), // Second purple dot
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Verification Icon
              Image.asset(
                'assets/emailIcon.png',
                height: 70,
              ),
              const SizedBox(height: 30),
              // Verification Title
              const Text(
                "Email verification is needed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Verification Message
              const Text(
                "A link has been sent to your email to verify your account. Please verify your account then click on the button below. Don’t forget to check spam emails.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              // I Have Verified My Account Button
              ElevatedButton(
                onPressed: _checkEmailVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF614FE0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "I have verified my account",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Resend Email Verification Button
              ElevatedButton(
                onPressed: _isResendEnabled ? _resendVerificationEmail : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF614FE0),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Resend verification email",
                    style: TextStyle(
                      color: Color(0xFF614FE0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

