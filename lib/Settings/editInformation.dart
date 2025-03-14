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
  bool _isLoading = true; // ✅ Added Loading Indicator

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// **Fetch User Data from Firebase Authentication & Firestore**
  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        _nameController.text = user.displayName ?? "Unknown";
        _emailController.text = user.email ?? "Unknown";

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            _selectedAgeGroup = userDoc['age_group'] ?? "Adult";
            _selectedGender = userDoc['gender'] ?? "Male";
            _isLoading = false; // ✅ Stop Loading
          });
        } else {
          setState(() => _isLoading = false); // ✅ Prevent Infinite Loading
        }
      } else {
        setState(() => _isLoading = false); // ✅ Handle Unauthenticated User
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => _isLoading = false); // ✅ Handle Errors
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
          'age_group': _selectedAgeGroup ?? "Adult",
          'gender': _selectedGender ?? "Male",
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 47, 47, 47)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // ✅ Show Loader
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // **Name Field**
                  _buildTextField(
                    label: "Name",
                    controller: _nameController,
                    isMandatory: true,
                  ),

                  const SizedBox(height: 20),

                  // **Email Field (Read-Only)**
                  _buildTextField(
                    label: "Email Address",
                    controller: _emailController,
                    isMandatory: true,
                    isReadOnly: true,
                  ),

                  const SizedBox(height: 20),

                  // **Age Group Dropdown**
                  _buildDropdown(
                    label: "Age Group",
                    value: _selectedAgeGroup,
                    items: const [
                      "Infant (0-2 years)",
                      "Toddler (3-5 years)",
                      "Child (6-12 years)",
                      "Teenager (13-17 years)",
                      "Adult",
                    ],
                    onChanged: (value) {
                      setState(() => _selectedAgeGroup = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // **Gender Dropdown**
                  _buildDropdown(
                    label: "Gender",
                    value: _selectedGender,
                    items: const ["Male", "Female"],
                    onChanged: (value) {
                      setState(() => _selectedGender = value);
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
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    bool isReadOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
    );
  }

  /// **Reusable Dropdown Field**
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
