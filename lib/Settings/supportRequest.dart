import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ContactSupportPage extends StatefulWidget {
  @override
  _ContactSupportPageState createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _orderNumberController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

  bool _isLoading = false;
  String? customerEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  void _fetchUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      customerEmail = user?.email;
    });
  }

  Future<void> _sendSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (customerEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No user logged in.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String issueTitle = _titleController.text.trim();
    final String orderNumber = _orderNumberController.text.trim();
    final String issueDescription = _issueController.text.trim();

    final smtpServer = gmail("aura2025app@gmail.com", "lxix ifts axyz xoaf");

    //  Email to Admin
    final adminMessage = Message()
      ..from = Address("aura2025app@gmail.com", "Support Team")
      ..recipients.add("shouqsaad47@gmail.com") // Admin's email
      ..subject = "New Support Request: $issueTitle"
      ..text = "New support request from: $customerEmail\n"
          "Order Number: $orderNumber\n"
          "Issue: $issueDescription";

    //  Confirmation Email to Customer
    final customerMessage = Message()
      ..from = Address("aura2025app@gmail.com", "Support Team")
      ..recipients.add(customerEmail!)
      ..subject = "Support Request Received"
      ..text = "Dear Customer,\n\n"
          "We have received your support request:\n"
          "Title: $issueTitle\n"
          "Order Number: $orderNumber\n"
          "Issue: $issueDescription\n\n"
          "Our support team will get back to you soon.";

    try {
      await send(adminMessage, smtpServer);
      await send(customerMessage, smtpServer);

      if (!mounted) return;
      _showConfirmationDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error sending request: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Your complaint has been sent successfully!"),
          content: const Text(
              "You will receive an email regarding your complaint. Our support team will get in touch with you via email as soon as possible."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearFields();
              },
              child: const Text("Got it"),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    setState(() {
      _titleController.clear();
      _orderNumberController.clear();
      _issueController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Contact Support"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 47, 47, 47)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTextField(
                  label: "Title",
                  controller: _titleController,
                  isMandatory: true),
              const SizedBox(height: 20),
              _buildTextField(
                  label: "Order Number (Optional)",
                  controller: _orderNumberController),
              const SizedBox(height: 20),
              _buildTextField(
                label: "Your problem",
                controller: _issueController,
                isMandatory: true,
                isMultiline: true,
                maxLength: 600,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _sendSupportRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF614FE0),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Center(
                        child: Text(
                          "Send",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isMandatory = false,
    bool isMultiline = false,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: isMultiline ? 4 : 1,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: isMandatory ? "$label *" : label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
      validator: (value) => (isMandatory && value!.isEmpty) ? "Required" : null,
    );
  }
}
