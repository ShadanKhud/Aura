import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> itemDetails;

  const ItemDetailsPage({Key? key, required this.itemDetails})
      : super(key: key);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  String? selectedSize;
  String? selectedColor;
  String sortOption = "Recommended (default)";

  @override
  Widget build(BuildContext context) {
    final item = widget.itemDetails;

    // Ensure images is a list
    List<String> imageUrls = (item['images'] is List)
        ? List<String>.from(item['images'])
        : (item['images'] is String)
            ? List<String>.from(jsonDecode(item['images']))
            : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(item['name'] ?? 'Item Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share('Check out this item: ${item['name']}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(imageUrls[index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item['name'] ?? 'No name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${item['price']} SAR",
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedColor,
                      hint: Text("Select Color"),
                      items: (item['colors'] as List<dynamic>?)
                              ?.map<DropdownMenuItem<String>>((color) {
                            return DropdownMenuItem<String>(
                              value: color as String,
                              child: Text(color),
                            );
                          }).toList() ??
                          [],
                      onChanged: (value) {
                        setState(() {
                          selectedColor = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSize,
                      hint: Text("Select Size"),
                      items: (item['sizes'] as List<dynamic>?)
                              ?.map<DropdownMenuItem<String>>((size) {
                            return DropdownMenuItem<String>(
                              value: size as String,
                              child: Text(size),
                            );
                          }).toList() ??
                          [],
                      onChanged: (value) {
                        setState(() {
                          selectedSize = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (selectedColor == null || selectedSize == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select size and color"),
                      ),
                    );
                    return;
                  }
                  Navigator.pushNamed(
                    context,
                    '/cart_folder/cartMainPage.dart',
                    arguments: {
                      'itemId': item['item_id'],
                      'color': selectedColor,
                      'size': selectedSize,
                    },
                  );
                },
                child: Text("Add to Cart"),
              ),
              const SizedBox(height: 16),
              Text(
                "Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(item['description'] ?? 'No description available.'),
            ],
          ),
        ),
      ),
    );
  }
}
