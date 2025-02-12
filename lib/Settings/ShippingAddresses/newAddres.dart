import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAddressPage extends StatefulWidget {
  @override
   final String customerId; // This is the customer's document ID

  AddAddressPage({required this.customerId});
  _AddAddressPageState createState() => _AddAddressPageState();
}


// Model: Represents Address Data
class Address {
  String customerId;
  String title;
  String phoneNumber;
  String region;
  String city;
  String street;
  String full_Address;
  String postalCode;
  String country;

  Address({
    required this.customerId,
    required this.title,
    required this.phoneNumber,
    required this.region,
    required this.city,
    required this.street,
    required this.postalCode,
    required this.full_Address,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'title': title,
      'phoneNumber': phoneNumber,
      'region': region,
      'city': city,
      'street': street,
      'postalCode': postalCode,
      'full_Address': full_Address, // ✅ FIXED (Now it's included!)
      'country':country,
    };
  }
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
String country = "";
String region = "";
String city = "";
String countrycode ="";
  List<String> countries = [];
  List<String> regions = [];
  List<String> cities = [];
  
Map<String, String> regionCodeMap = {};
  @override
  void initState() {
    super.initState();
    fetchCountries();
  }
// ✅ Fetch Countries from REST Countries API
  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse("https://restcountries.com/v3.1/all"));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        countries = data.map((country) => country['name']['common'].toString()).toList();
      });
    }
  }

  // ✅ Fetch Regions (States) from GeoNames
Future<void> fetchRegions(String countryCode) async {
    print("Fetching regions for: $countryCode");

    final response = await http.get(Uri.parse(
        "http://api.geonames.org/searchJSON?country=$countryCode&featureClass=A&featureCode=ADM1&maxRows=50&username=munirahi"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['geonames'];
      print("Regions found: ${data.length}");

      setState(() {
        regions = data.map((region) => region['name'].toString()).toList();
        regionCodeMap.clear(); // ✅ Reset the mapping

        for (var region in data) {
          String name = region['name'].toString();
          String code = region['adminCode1'].toString();
          regionCodeMap[name] = code;
        }
        print("Region Code Map: $regionCodeMap"); // ✅ Debugging
      });
    } else {
      print("❌ Error fetching regions: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

 Future<void> fetchCities(String regionName, String countryCode) async {
  print("Fetching cities for: country=$countryCode, region=$regionName");

  String? regionCode = regionCodeMap[regionName];
  if (regionCode == null) {
    print("❌ No region code found for $regionName");
    return;
  }

  print("Using region code: $regionCode"); // Debugging

  final response = await http.get(Uri.parse(
      "http://api.geonames.org/searchJSON?country=$countryCode&adminCode1=$regionCode&maxRows=50&featureClass=P&username=munirahi"));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List geonames = data['geonames'] ?? [];
    print("API Response: $data"); // Debugging
    print("Cities found: ${geonames.length}");

    setState(() {
      // Ensure you're correctly extracting the city names as a List<String>
      cities = geonames.map((city) {
        // Extract the city name and cast to String
        return city['name']?.toString() ?? 'Unknown';
      }).toList();
    });
  } else {
    print("❌ Error fetching cities: ${response.statusCode}");
    print("Response body: ${response.body}");
  }
}

 final Map<String, String> countryDialCodes = {
    'sa': '+966',
    'us': '+1',
    'eg': '+20',
    'uk': '+44',
    'de': '+49',
  };
  String _getDialCodeHint() {
    return countryDialCodes[countrycode.toLowerCase()] ?? '+';
  }

Widget _buildCountryPicker() {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk("Country", true),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder( // Only change border color when focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF614FE0)),
        ),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      validator: (value) => value!.isEmpty ? "Please select a country" : null,
      controller: TextEditingController(text: country),
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (Country selectedCountry) {
            setState(() {
              country = selectedCountry.name;
              countrycode = selectedCountry.countryCode.toLowerCase();
              region = "";
              city = "";
              fetchRegions(countrycode);
            });
          },
        );
      },
    ),
  );
}

Widget _buildRegionPicker() {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk("Region", true),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder( // Only change border color when focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
      value: region.isNotEmpty ? region : null,
      items: regions.map((String region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region),
        );
      }).toList(),
      validator: (value) => value == null ? "Please select a region" : null,
      onChanged: (String? selectedRegion) {
        setState(() {
          region = selectedRegion!;
          city = "";
          fetchCities(region, countrycode);
        });
      },
    ),
  );
}

Widget _buildCityPicker() {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk("City", true),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder( // Only change border color when focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
      value: city.isNotEmpty ? city : null,
      items: cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      validator: (value) => value == null ? "Please select a city" : null,
      onChanged: (value) {
        setState(() {
          city = value!;
        });
      },
    ),
  );
}


  // Controller: Handles Business Logic
  Future<void> saveAddress(Address address) async {
    try {
      await FirebaseFirestore.instance.collection('addresses').add(address.toMap());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Address Saved Successfully!")));
      Navigator.pop(context); // Go back after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving address: $e")));
    }
  }


  // Form Variables
  String title = "";
  String phoneNumber = "";
  String street = "";
  String postalCode = "";
  String full_Address = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Shipping Address"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:SingleChildScrollView(
      padding: EdgeInsets.all(16), // Keeps padding around content
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align fields properly
          children: [
            _buildTextField("Title", "Enter title,home office etc.", (value) => title = value),
            _buildCountryPicker(),
            _buildRegionPicker(),
            _buildCityPicker(),
            _buildTextField("Phone Number", "Use Country code as +966..", (value) => phoneNumber = value, keyboardType: TextInputType.phone),
            _buildTextField("Street Address", "Enter street address", (value) => street = value),
            _buildTextField("Full Address", "Enter full address with building number", (value) => full_Address = value),
            _buildTextField("Postal Code", "Enter postal code", (value) => postalCode = value, keyboardType: TextInputType.number),
            SizedBox(height: 20), // Add spacing before button
            _buildSaveButton(),
          ],
        ),
      ),
    ),
  );
}
  // View: UI Components
Widget _buildTextField(String label, String hint, Function(String) onSaved,
    {TextInputType keyboardType = TextInputType.text}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: TextFormField(
      decoration: InputDecoration(
        label: _buildLabelWithAsterisk(label, true),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder( // Only change border color when focused
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF614FE0)),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? "Required" : null,
      onSaved: (value) => onSaved(value!),
    ),
  );
}

  Widget _buildDropdownPicker(String label, VoidCallback onTap, {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
          ],
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Show the selected value or placeholder text
                  label == "Select Country" && country.isNotEmpty
                      ? country
                      : label == "Select Region" && region.isNotEmpty
                      ? region
                      : label == "Select City" && city.isNotEmpty
                      ? city
                      : "Select $label",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
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
            _formKey.currentState!.save();
            Address newAddress = Address(
              customerId: widget.customerId,
              title: title,
              phoneNumber: phoneNumber,
              region: region,
              city: city,
              street: street,
              postalCode: postalCode,
              full_Address: full_Address,
              country:country,
            );
            saveAddress(newAddress);
          }
        },
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
