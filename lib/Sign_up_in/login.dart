import 'package:aura_app/Sign_up_in/forget_password.dart';
import 'package:aura_app/Sign_up_in/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Sign_up_in/PlaceholderPage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            // Logo
            Image.asset(
              'assets/AuraLogo.png',
              height: 80, // Adjust as needed
            ),
            const SizedBox(height: 30),
            // Title
            const Text(
              "Sign in",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                label: Row(
                  children: const [
                    Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      " *",
                      style: TextStyle(
                        color: Color(0xFFEE4D4D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFF614FE0)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                label: Row(
                  children: const [
                    Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      " *",
                      style: TextStyle(
                        color: Color(0xFFEE4D4D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFF614FE0)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Forgot Password logic
                  Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                 );
                },
                child: const Text(
                  "Forgot password?",
                  style: TextStyle(
                    color: Color(0xFF614FE0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sign-In Button
            ElevatedButton(
              onPressed: isLoading ? null : _loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF614FE0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // Google Sign-In Button
            SizedBox(
              width: double.infinity, // Ensures button spans full width
              child: OutlinedButton.icon(
                onPressed: () {
                  // Google Sign-In logic
                },
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.black54,
                ),
                label: const Text(
                  "Sign in with Google",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
            const SizedBox(height: 30), // Increased space after Google sign-in
            // Don't have an account? Sign up
            RichText(
              text: TextSpan(
                text: "Don’t have an account? ",
                style: const TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: "Sign up",
                    style: const TextStyle(
                      color: Color(0xFF614FE0),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          // If email is not verified, show dialog to prompt user to verify email
          _showEmailVerificationDialog(user);
        } else {
          // If email is verified, navigate to PlaceholderPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PlaceholderPage()),
          );
        }
      }
    } catch (e) {
      // Handle login error (e.g., wrong credentials)
      _showErrorDialog(context, "Login failed. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEmailVerificationDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Email Verification"),
        content: const Text(
            "Your email is not verified. Please verify your email to proceed."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              user.sendEmailVerification(); // Send verification email
              _showSuccessDialog(context, "Verification email sent!");
            },
            child: const Text("Resend Verification Email"),
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
}
