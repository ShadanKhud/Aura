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

    // Handle image URLs properly
    String imagesString = item['images'] ?? '[]';

    // Ensure correct JSON format (replace single quotes with double quotes)
    imagesString = imagesString.replaceAll("'", '"');

    // Try decoding the string into a list. If any error occurs, fallback to an empty list.
    List<String> imageUrls = [];
    try {
      imageUrls = List<String>.from(jsonDecode(imagesString));
    } catch (e) {
      print("Error decoding image URLs: $e");
      // Fallback to an empty list if decoding fails
      imageUrls = [];
    }

    // Debug the parsed image URLs
    print('Decoded Image URLs: $imageUrls');

    // Handle 'reviews' being null, default to an empty list
    List reviews = item['reviews'] ?? [];

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
              // Display images in a PageView
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: imageUrls.isNotEmpty ? imageUrls.length : 1,
                  itemBuilder: (context, index) {
                    if (imageUrls.isNotEmpty) {
                      print('Rendering image: ${imageUrls[index]}');
                      return Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Text('Error loading image'));
                        },
                      );
                    } else {
                      return Center(child: Text('No images available.'));
                    }
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
                style: TextStyle(fontSize: 18, color: Colors.black),
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                "Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(item['description'] ?? 'No description available.'),
              const SizedBox(height: 16),
              // Ratings and Reviews
              ExpansionTile(
                title: Text("Ratings & Reviews"),
                children: [
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Summary"),
                        Text("${reviews.length} Reviews"),
                      ],
                    ),
                  ),
                  ListTile(
                    title: DropdownButtonFormField<String>(
                      value: sortOption,
                      items: [
                        "Recommended (default)",
                        "Rating - High to low",
                        "Rating - Low to high",
                      ].map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          sortOption = value!;
                        });
                      },
                    ),
                  ),
                  ...reviews.map<Widget>((review) {
                    return ListTile(
                      title: Text(review['reviewer_name'] ?? 'Anonymous'),
                      subtitle: Text(review['comment'] ?? 'No comment'),
                      trailing: Text("${review['rating']} ★"),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
