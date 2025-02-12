import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // For sharing feature

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> itemDetails;

  const ItemDetailsPage({Key? key, required this.itemDetails}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? 'Item Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share('Check out this item: ${item['title']}');
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
              // Image Carousel
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: (item['images'] as List).length,
                  itemBuilder: (context, index) {
                    return Image.network(item['images'][index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Title and Price
              Text(
                item['title'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${item['price']} SAR",
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 16),
              // Colors and Sizes
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedColor,
                      hint: Text("Select Color"),
                      items: (item['colors'] as List<dynamic>).map<DropdownMenuItem<String>>((color) {
                        return DropdownMenuItem<String>(
                          value: color as String,
                          child: Text(color),
                        );
                      }).toList(),
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
                      items: (item['sizes'] as List<dynamic>).map<DropdownMenuItem<String>>((size) {
                        return DropdownMenuItem<String>(
                          value: size as String,
                          child: Text(size),
                        );
                      }).toList(),
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
              // Add to Cart Button
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
                    '/lib/cart_folder/cartMainPage.dart',
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
              Text(
                item['description'] ?? 'No description available.',
              ),
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
                        Text("${item['reviews'].length} Reviews"),
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
                  ...item['reviews'].map<Widget>((review) {
                    return ListTile(
                      title: Text(review['reviewer_name']),
                      subtitle: Text(review['comment']),
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
