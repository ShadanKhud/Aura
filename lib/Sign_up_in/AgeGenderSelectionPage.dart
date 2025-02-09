import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'members/members1.dart'; // Ensure this is the correct import

class AgeGenderSelectionPage extends StatefulWidget {
  final User user; // Add this line

  AgeGenderSelectionPage({required this.user}); // Modify constructor

  @override
  _AgeGenderSelectionPageState createState() => _AgeGenderSelectionPageState();
}

class _AgeGenderSelectionPageState extends State<AgeGenderSelectionPage> {
  String? _selectedGender;
  String? _selectedAgeGroup;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _ageGroups = [
    'Infant (0-2 years)',
    'Toddler (3-5 years)',
    'Child (6-12 years)',
    'Teenager (13-17 years)',
    'Adult'
  ];

  // Function to save the selected age and gender to Firebase Firestore
Future<void> _saveDataToFirebase() async {
  try {
    // Save user data (email, name, age, gender) to Firestore under the 'customers' collection
    await FirebaseFirestore.instance.collection('customers').doc(widget.user.uid).set({
      'gender': _selectedGender,
      'age_group': _selectedAgeGroup,
      'isEmailVerified': true,
      //'UID': widget.user.uid,
      'email': widget.user.email, // Save email from FirebaseAuth
      'name': widget.user.displayName ?? 'Anonymous', // Save name (if available) or 'Anonymous'
    });
    print("User data saved successfully!");
  } catch (e) {
    print("Error saving user data: $e");
  }
}


  void _proceedToSignUp() async {
    if (_selectedGender == null || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both age and gender!")),
      );
      return;
    }

    // Save data before navigating
    await _saveDataToFirebase();

    // Proceed to the next page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => members1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Age & Gender"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Who are you shopping for?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Select the age and gender to get personalized recommendations.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildDropdownField(
              label: 'Gender',
              value: _selectedGender,
              options: _genders,
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Age group',
              value: _selectedAgeGroup,
              options: _ageGroups,
              onChanged: (value) => setState(() => _selectedAgeGroup = value),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF614FE0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _proceedToSignUp,
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      value: value,
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a $label' : null,
    );
  }
}
