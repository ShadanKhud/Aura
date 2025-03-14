import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPasswordPage extends StatefulWidget {
  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordValid = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _validatePassword(String password) {
    setState(() {
      _isPasswordValid = password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) && // Uppercase letter
          password.contains(RegExp(r'[a-z]')) && // Lowercase letter
          password.contains(RegExp(r'[0-9]')) && // Number
          password
              .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // Special character
    });
  }

  Future<void> _updatePassword() async {
    setState(() => _isLoading = true);

    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog("Please fill in all mandatory fields.");
      setState(() => _isLoading = false);
      return;
    }

    if (!_isPasswordValid) {
      _showErrorDialog("Password does not meet the required criteria.");
      setState(() => _isLoading = false);
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog("Passwords do not match.");
      setState(() => _isLoading = false);
      return;
    }

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        _showSuccessDialog("Password updated successfully!");
        Navigator.pop(context);
      } catch (e) {
        _showErrorDialog("Error updating password: ${e.toString()}");
      }
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
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

  void _showSuccessDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 47, 47, 47)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your new password and remember it.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // **New Password Field**
            _buildTextField(
              label: "Password",
              controller: _newPasswordController,
              isMandatory: true,
              isObscure: !_isPasswordVisible,
              onChanged: _validatePassword,
              onToggleVisibility: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
              isPasswordField: true,
            ),

            // **Password Validation Rules**
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildValidationIndicator("At least 8 characters",
                    _newPasswordController.text.length >= 8),
                _buildValidationIndicator("At least 1 uppercase letter",
                    _newPasswordController.text.contains(RegExp(r'[A-Z]'))),
                _buildValidationIndicator("At least 1 lowercase letter",
                    _newPasswordController.text.contains(RegExp(r'[a-z]'))),
                _buildValidationIndicator("At least 1 number",
                    _newPasswordController.text.contains(RegExp(r'[0-9]'))),
                _buildValidationIndicator(
                    "At least 1 special character (!@#\$%^&*)",
                    _newPasswordController.text
                        .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
              ],
            ),

            const SizedBox(height: 20),

            // **Confirm Password Field**
            _buildTextField(
              label: "Confirm Password",
              controller: _confirmPasswordController,
              isMandatory: true,
              isObscure: !_isConfirmPasswordVisible,
              onToggleVisibility: () {
                setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
              },
              isPasswordField: true,
            ),

            const SizedBox(height: 30),

            // **Save Button**
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF614FE0),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Center(
                      child: Text("Save",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **Reusable Input Field with Red Asterisk**
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    bool isObscure = false,
    bool isPasswordField = false,
    Function(String)? onChanged,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk(label, isMandatory),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  /// ✅ **Method to Add Red Asterisk for Required Fields**
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

  /// ✅ **Password Validation Indicators**
  Widget _buildValidationIndicator(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(color: isValid ? Colors.green : Colors.grey)),
      ],
    );
  }
}
