import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  String _password = "";

  // Validation rules
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _password.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => _password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  bool get _isAtLeast8 => _password.length >= 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          obscureText: _obscureText,
          onChanged: (value) {
            setState(() {
              _password = value;
            });
          },
          decoration: InputDecoration(
            label: _buildLabelWithAsterisk('Password'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFF614FE0)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Password validation rules
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRule("Must be at least 8 characters long", _isAtLeast8),
            _buildRule("Include at least 1 uppercase letter", _hasUppercase),
            _buildRule("Include at least 1 lowercase letter", _hasLowercase),
            _buildRule("Include at least 1 number", _hasNumber),
            _buildRule("Include at least 1 special character (!@#\$%^&*)", _hasSpecialChar),
          ],
        ),
      ],
    );
  }

  Widget _buildRule(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          color: isValid ? Colors.green : Colors.grey,
          size: 16, // Reduced size to match text weight better
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w300, // Consistent light font weight
          ),
        ),
      ],
    );
  }

  // Helper function for the label with a red asterisk
  Widget _buildLabelWithAsterisk(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const Text(
          " *",
          style: TextStyle(
            color: Color(0xFFEE4D4D), // Red asterisk
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
