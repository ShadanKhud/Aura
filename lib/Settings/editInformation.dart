import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedAgeGroup;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// **Fetch User Data from Firebase Authentication & Firestore**
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _nameController.text = user.displayName ?? "Unknown";
      _emailController.text = user.email ?? "Unknown";

      // Fetch additional user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _selectedAgeGroup = userDoc['age_group'] ?? "Adult";
          _selectedGender = userDoc['gender'] ?? "Male";
        });
      }
    }
  }

  /// **Update User Information in Firebase**
  Future<void> _updateUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.updateDisplayName(_nameController.text.trim());
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .update({
          'name': _nameController.text.trim(),
          'age_group': _selectedAgeGroup,
          'gender': _selectedGender,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Account Information",
          style: TextStyle(color: Color.fromARGB(255, 47, 47, 47)),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 47, 47, 47)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // **Name Field**
            _buildTextField(
                label: "Name", controller: _nameController, isMandatory: true),

            const SizedBox(height: 20),

            // **Email Field (Read-Only)**
            _buildTextField(
                label: "Email Address",
                controller: _emailController,
                isMandatory: true,
                isReadOnly: true),

            const SizedBox(height: 20),

            // **Age Group Dropdown**
            DropdownButtonFormField<String>(
              value: _selectedAgeGroup,
              decoration: _inputDecoration("Age Group"),
              items: const [
                DropdownMenuItem(
                    value: "Infant (0-2 years)",
                    child: Text("Infant (0-2 years)")),
                DropdownMenuItem(
                    value: "Toddler (3-5 years)",
                    child: Text("Toddler (3-5 years)")),
                DropdownMenuItem(
                    value: "Child (6-12 years)",
                    child: Text("Child (6-12 years)")),
                DropdownMenuItem(
                    value: "Teenager (13-17 years)",
                    child: Text("Teenager (13-17 years)")),
                DropdownMenuItem(value: "Adult", child: Text("Adult")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAgeGroup = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // **Gender Dropdown**
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration("Gender"),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 40),

            // **Save Button**
            ElevatedButton(
              onPressed: _updateUserInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF614FE0),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Center(
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// **Reusable Input Field**
  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      bool isMandatory = false,
      bool isReadOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: isMandatory ? "$label *" : label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
    );
  }

  /// **Input Decoration for Dropdowns**
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF614FE0)),
      ),
    );
  }
}
