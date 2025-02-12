import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAddressPage extends StatefulWidget {
  final String customerId;
  final String addressId;
  final Map<String, dynamic> addressData;

  EditAddressPage({
    required this.customerId,
    required this.addressId,
    required this.addressData,
  });

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _streetController;
  late TextEditingController _postalCodeController;
  late TextEditingController _fullAddressController;

  // Non-editable fields
  late String _country;
  late String _region;
  late String _city;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.addressData['title']);
    _phoneNumberController = TextEditingController(text: widget.addressData['phoneNumber']);
    _streetController = TextEditingController(text: widget.addressData['street']);
    _postalCodeController = TextEditingController(text: widget.addressData['postalCode']);
    _fullAddressController = TextEditingController(text: widget.addressData['full_Address']);
    
    // Set non-editable fields
    _country = widget.addressData['country'];
    _region = widget.addressData['region'];
    _city = widget.addressData['city'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _phoneNumberController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _fullAddressController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    try {
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(widget.addressId)
          .update({
        'title': _titleController.text,
        'phoneNumber': _phoneNumberController.text,
        'street': _streetController.text,
        'postalCode': _postalCodeController.text,
        'full_Address': _fullAddressController.text,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating address: $e')),
      );
    }
  }

  Future<void> _deleteAddress() async {
    try {
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(widget.addressId)
          .delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting address: $e')),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Address'),
          content: Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                _deleteAddress();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          label: _buildLabelWithAsterisk(label, true),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF614FE0)),
          ),
        ),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildNonEditableField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelWithAsterisk(label, false),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Text(value),
          ),
        ],
      ),
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
              color: Color(0xFFEE4D4D),
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Shipping Address"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Title", _titleController),
              _buildTextField("Phone Number", _phoneNumberController),
              
              // Non-editable fields with note
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow[100]!),
                ),
                child: Text(
                  "Note: To change country, region, or city, please add a new address instead.",
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ),
              
              _buildNonEditableField("Country", _country),
              _buildNonEditableField("Region", _region),
              _buildNonEditableField("City", _city),
              
              _buildTextField("Street Address", _streetController),
              _buildTextField("Full Address", _fullAddressController),
              _buildTextField("Postal Code", _postalCodeController),
              
              SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _showDeleteConfirmation,
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF614FE0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateAddress();
                        }
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}