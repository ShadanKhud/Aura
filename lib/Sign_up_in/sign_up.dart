import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Sign_up_in/login.dart';
import 'package:aura_app/Sign_up_in/password_field.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordValid = false; // Track password validation state

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

Future<void> _createAccount() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showErrorDialog(context, "Please fill in all mandatory fields.");
    return;
  }

  if (!_isPasswordValid) {
    _showErrorDialog(context, "Password does not meet the required criteria.");
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _showSuccessDialog(context, "Account created successfully!");
    print("User created: ${userCredential.user?.email}");
  } on FirebaseAuthException catch (e) {
    _showErrorDialog(context, e.message ?? "An error occurred.");
  }
}


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
              height: 80,
            ),
            const SizedBox(height: 20),
            // Progress Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: index == 0 ? const Color(0xFF614FE0) : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              "Sign up",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Name Field
            _buildTextField(label: 'Name', isMandatory: true, controller: _nameController ),
            const SizedBox(height: 20),
            // Email Field
            // _buildTextField(label: 'Email', isMandatory: true, controller: _emailController ,),
            TextField(
              controller: _emailController,
             
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Password Field with validation
             PasswordField(
              controller: _passwordController,
              onPasswordValid: (isValid) {
                setState(() {
                  _isPasswordValid = isValid;
                });
              },
            ),
            const SizedBox(height: 20),
            // Age Group Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                label: _buildLabelWithAsterisk('Age group', true),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "Infant (0-2 years)", child: Text("Infant (0-2 years)")),
                DropdownMenuItem(value: "Toddler (3-5 years)", child: Text("Toddler (3-5 years)")),
                DropdownMenuItem(value: "Child (6-12 years)", child: Text("Child (6-12 years)")),
                DropdownMenuItem(value: "Teenager (13-17 years)", child: Text("Teenager (13-17 years)")),
                DropdownMenuItem(value: "Adult", child: Text("Adult")),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            // Gender Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                label: _buildLabelWithAsterisk('Gender', true),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            // Create Account Button
            ElevatedButton(
              onPressed: () async {
                print("Email entered: '${_emailController.text}'"); // Debugging output
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();
  print("Email: $email, Password: $password, isPasswordValid: $_isPasswordValid");

  if (email.isEmpty || password.isEmpty) {
    _showErrorDialog(context, "Please fill in all mandatory fields.");
    return;
  }

  if (!_isPasswordValid) {
    _showErrorDialog(context, "Password does not meet the required criteria.");
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _showSuccessDialog(context, "Account created successfully!");
    print("User created: ${userCredential.user?.email}");
  } on FirebaseAuthException catch (e) {
    _showErrorDialog(context, e.message ?? "An error occurred.");
  }
},        style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF614FE0),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Center(
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Google Sign-Up Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Google Sign-Up logic
                },
                icon: const Icon(Icons.account_circle, color: Colors.black54),
                label: const Text(
                  "Sign up with Google",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
            const SizedBox(height: 30), // Increased space after Google sign-up
            // Already have an account? Sign In
            RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: const TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: "Sign in",
                    style: const TextStyle(
                      color: Color(0xFF614FE0),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
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

  // Helper function for text fields
  Widget _buildTextField({required String label, bool isMandatory = false, required TextEditingController controller}) {
    return TextField(
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk(label, isMandatory),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
    );
  }

  // Helper function to build labels with red asterisks
  Widget _buildLabelWithAsterisk(String label, bool isMandatory) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        if (isMandatory)
          const Text(
            " *",
            style: TextStyle(
              color: Color(0xFFEE4D4D), // Red Asterisk
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
