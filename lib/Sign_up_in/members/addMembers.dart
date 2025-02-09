import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aura_app/Sign_up_in/members/manage_members.dart';

class addMembers extends StatefulWidget {
  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<addMembers> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  String? _selectedAgeGroup;
  String? _selectedAvatar;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _ageGroups = [
    'Infant (0-2 years)',
    'Toddler (3-5 years)',
    'Child (6-12 years)',
    'Teenager (13-17 years)',
    'Adult'
  ];

  final List<Map<String, String>> _avatars = List.generate(
    9,
        (index) => {
      'name': 'Avatar ${index + 1}',
      'image': 'assets/avatar${index + 1}.png',
    },
  );


  void _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userId == null || userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No customer record found!")),
        );
        return;
      }

      String customerDocId = querySnapshot.docs.first.id;

      QuerySnapshot memberSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerDocId)
          .collection('members')
          .get();

      if (memberSnapshot.docs.length >= 9) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can't add more than 9 members!")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerDocId)
          .collection('members')
          .add({
        'name': _nameController.text,
        'gender': _selectedGender,
        'ageGroup': _selectedAgeGroup,
        'avatar': _selectedAvatar,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Member added successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManageMembersPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save member! Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Member"),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Shopping for who?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Find clothes for everyone based on their style easily.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Name',
                isMandatory: true,
                controller: _nameController,
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Gender',
                isMandatory: true,
                value: _selectedGender,
                options: _genders,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Age group',
                isMandatory: true,
                value: _selectedAgeGroup,
                options: _ageGroups,
                onChanged: (value) => setState(() => _selectedAgeGroup = value),
              ),
              const SizedBox(height: 20),
              _buildAvatarDropdownField(),
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
                  onPressed: _saveMember,
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required bool isMandatory,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk(label, isMandatory),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? 'Please enter a $label' : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required bool isMandatory,
    required String? value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk(label, isMandatory),
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

  Widget _buildAvatarDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk('Avatar', true),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      value: _selectedAvatar, // Ensure this value matches the "name" field of the Map
      items: _avatars
          .map(
            (avatar) => DropdownMenuItem(
          value: avatar['name'], // The value here is the "name" field from the Map
          child: Row(
            children: [
              Image.asset(
                avatar['image']!,
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 10),
              Text(avatar['name']!),
            ],
          ),
        ),
      )
          .toList(),
      onChanged: (value) => setState(() {
        _selectedAvatar = value; // Update the selected avatar based on the "name" field
      }),
      validator: (value) => value == null ? 'Please select an Avatar' : null,
    );
  }


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