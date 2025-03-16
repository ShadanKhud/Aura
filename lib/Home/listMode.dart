import 'dart:convert';
import 'package:aura_app/cart_folder/cartMainPage.dart';
import 'package:aura_app/itemDetails/ItemDetailsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aura_app/Settings/settings.dart';
import 'package:aura_app/wishlist/wishlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aura_app/Home/swipeMode.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _documents = [];

  bool _isLoading = false;
  bool _hasMore = true;

  Map<String, dynamic>? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadProducts();
  }

  void _scrollListener() {
    // If the user scrolled to the bottom, and we still have more data to load
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('clothes');

      // Apply filters
      if (_filters['colors'].isNotEmpty) {
        query = query.where('colors', arrayContainsAny: _filters['colors']);
      }
      if (_filters['sizes'].isNotEmpty) {
        query = query.where('sizes', arrayContainsAny: _filters['sizes']);
      }
      if (_filters['stores'].isNotEmpty) {
        query = query.where('store_id', whereIn: _filters['stores']);
      }

      // Apply sorting
      switch (_currentSort) {
        case 'rating-high-low':
          query = query.orderBy('rating', descending: true);
          break;
        case 'rating-low-high':
          query = query.orderBy('rating', descending: false);
          break;
        case 'price-high-low':
          query = query.orderBy('price', descending: true);
          break;
        case 'price-low-high':
          query = query.orderBy('price', descending: false);
          break;
        default:
          query = query.orderBy('product_number', descending: false);
      }

      final snapshot = await query.limit(6).get();

      setState(() {
        _documents.clear();
        _documents.addAll(snapshot.docs);
        _hasMore = snapshot.docs.length == 6;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_hasMore) return;

    setState(() => _isLoading = true);

    // Start after the last document in the current list
    final lastDoc = _documents.last;
    final snapshot = await FirebaseFirestore.instance
        .collection('clothes')
        .startAfterDocument(lastDoc)
        .limit(6)
        .get();

    setState(() {
      _isLoading = false;
      _documents.addAll(snapshot.docs);
      _hasMore = (snapshot.docs.length == 6);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

void _selectProduct(DocumentSnapshot productSnapshot) {
  final productData = productSnapshot.data() as Map<String, dynamic>;

  // Add the document ID to the product data map
// In _selectProduct() 
productData['productId'] = productSnapshot.id; // instead of 'id'

  setState(() {
    _selectedProduct = productData;
  });
}


 void _NavToDetialsPage() {
  if (_selectedProduct != null) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(itemDetails: _selectedProduct!),
      ),
    );
  }
}


  void _deselectProduct() {
    setState(() {
      _selectedProduct = null;
    });
  }

  Set<String> _wishlistItems = {};

  Future<void> _loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('wishlist')
        .get();

    setState(() {
      _wishlistItems = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

// First, add these state variables to your _ProductsPageState class:
  String _currentSort = 'recommended';
  Map<String, dynamic> _filters = {
    'colors': <String>[],
    'sizes': <String>[],
    'brands': <String>[],
    'stores': <String>[],
    'priceRange': const RangeValues(10, 8000),
    'ratingRange': const RangeValues(0, 5),
  };

// Add these methods to your _ProductsPageState class:
  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  Widget _buildSortBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Recommended (default)'),
            leading: Radio<String>(
              value: 'recommended',
              groupValue: _currentSort,
              onChanged: (value) {
                setState(() => _currentSort = value!);
                _loadProducts();
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            title: const Text('Rating - High to low'),
            leading: Radio<String>(
              value: 'rating-high-low',
              groupValue: _currentSort,
              onChanged: (value) {
                setState(() => _currentSort = value!);
                _loadProducts();
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            title: const Text('Rating - Low to high'),
            leading: Radio<String>(
              value: 'rating-low-high',
              groupValue: _currentSort,
              onChanged: (value) {
                setState(() => _currentSort = value!);
                _loadProducts();
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            title: const Text('Price - High to low'),
            leading: Radio<String>(
              value: 'price-high-low',
              groupValue: _currentSort,
              onChanged: (value) {
                setState(() => _currentSort = value!);
                _loadProducts();
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            title: const Text('Price - Low to high'),
            leading: Radio<String>(
              value: 'price-low-high',
              groupValue: _currentSort,
              onChanged: (value) {
                setState(() => _currentSort = value!);
                _loadProducts();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _buildFilterSection('Color', [
                    'Black',
                    'Blue',
                    'Brown',
                    'Copper',
                    'Gold',
                    'Green',
                    'Grey',
                    'Navy'
                  ]),
                  _buildFilterSection('Size',
                      ['X-Small', 'Small', 'Medium', 'Large', 'X-Large']),
                  _buildFilterSection(
                      'Store', ['Amazon', 'Bershka', 'H&M', 'Zara']),
                  _buildPriceRangeSlider(),
                  _buildRatingRangeSlider(),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filters = {
                          'colors': <String>[],
                          'sizes': <String>[],
                          'brands': <String>[],
                          'stores': <String>[],
                          'priceRange': const RangeValues(10, 8000),
                          'ratingRange': const RangeValues(0, 5),
                        };
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _loadProducts();
                      Navigator.pop(context);
                    },
                    child: const Text('View Items'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    selected: _filters[title.toLowerCase()].contains(option),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _filters[title.toLowerCase()].add(option);
                        } else {
                          _filters[title.toLowerCase()].remove(option);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RangeSlider(
          values: _filters['priceRange'],
          min: 10,
          max: 8000,
          divisions: 799,
          labels: RangeLabels(
            '${_filters['priceRange'].start.round()} SAR',
            '${_filters['priceRange'].end.round()} SAR',
          ),
          onChanged: (values) {
            setState(() {
              _filters['priceRange'] = values;
            });
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildRatingRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RangeSlider(
          values: _filters['ratingRange'],
          min: 0,
          max: 5,
          divisions: 50,
          labels: RangeLabels(
            _filters['ratingRange'].start.toStringAsFixed(1),
            _filters['ratingRange'].end.toStringAsFixed(1),
          ),
          onChanged: (values) {
            setState(() {
              _filters['ratingRange'] = values;
            });
          },
        ),
      ],
    );
  }

  // Add to wishlist
  Future<void> _addToWishlist(DocumentSnapshot productSnapshot) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final productId = productSnapshot.id;

      final docRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .collection('wishlist')
          .doc(productId);

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
        setState(() {
          _wishlistItems.remove(productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from wishlist.')),
        );
      } else {
        await docRef.set({
          'productId': productId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _wishlistItems.add(productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to wishlist!')),
        );
      }
    } catch (e) {
      print("Error updating wishlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Theme.of(context).colorScheme.surface
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // Fix for color change when scrolling
        scrolledUnderElevation: 0,
        elevation: 0,
        // Fix for back arrow
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Account Image
            CircleAvatar(
              radius: 16, // Adjust size as needed
              // backgroundImage: AssetImage('assets/profile.jpg'), // Replace with the actual image path
            ),
            const SizedBox(width: 10), // Space between avatar and logo
            // Centered Logo
            Expanded(
              child: Image.asset(
                'assets/AuraLogo.png',
                scale: 5,
                // fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        centerTitle: true, // Ensures title is centered
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SwipeModePage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showSortDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('SORT'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showFilterDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('FILTER'),
                        Icon(Icons.filter_list),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: (_isLoading && _documents.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : _documents.isEmpty
                    ? const Center(child: Text('No products found'))
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 5.0,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          final productSnapshot = _documents[index];
                          final product =
                              productSnapshot.data() as Map<String, dynamic>;

                          // Make sure images & price & title exist
                          if (product['images'] == null ||
                              product['price'] == null ||
                              product['title'] == null) {
                            return const Center(
                              child: Text('Product data is incomplete'),
                            );
                          }

                     return ProductCard(
  product: product,
  onTap: () {
    final productData = Map<String, dynamic>.from(product);
    productData['productId'] = productSnapshot.id; // Ensure product ID is passed

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsPage(itemDetails: productData),
      ),
    );
  },
                            onHeartPressed: () =>
                                _addToWishlist(productSnapshot),
                          );
                        },
                      ),
          ),
          // Show a small loading indicator at bottom if fetching more
          if (_isLoading && _selectedProduct == null)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 96, 95, 95),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // for "Settings"
        onTap: (index) {
          if (index == 0) {
            // Home - current page
          } else if (index == 1) {
            // Search Page
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchPage()));
          } else if (index == 2) {
            // Cart Page
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CartMainPage()));
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WishlistPage()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "My Cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Wishlist"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  // Widget _buildProductDetailView() {
  //   if (_selectedProduct == null) return const SizedBox();

  //   final product = _selectedProduct!;
  //   // images is already an array of URLs, so just cast it
  //   final List<dynamic> imagesDynamic = product['images'];
  //   final imageUrls = imagesDynamic.map((e) => e.toString()).toList();

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         if (imageUrls.isNotEmpty)
  //           ClipRRect(
  //             borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
  //             child: Image.network(
  //               imageUrls[0],
  //               fit: BoxFit.cover,
  //               width: double.infinity,
  //               height: 250,
  //             ),
  //           ),
  //         const SizedBox(height: 16),
  //         Text(
  //           product['title'] ?? 'No Title',
  //           style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           '${product['price'] ?? 'N/A'} SAR',
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.green,
  //             fontSize: 18,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         ElevatedButton(
  //           onPressed: _deselectProduct,
  //           child: const Text('Back to Products'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onHeartPressed;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onHeartPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      final List<dynamic> imagesDynamic = product['images'] ?? [];
      final imageUrls = imagesDynamic.map((e) => e.toString()).toList();
      final String title = product['title'] ?? 'No Title';
      final String price = product['price'] ?? 'N/A';
      final double rating = product['rating']?.toDouble() ?? 0.0;

      return GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrls.isNotEmpty)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.network(
                          imageUrls[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Heart Icon on top-right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: onHeartPressed,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Colors.white, // Background color for visibility
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.black54,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$price SAR',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error rendering product card: $e');
      return const Center(child: Text('Error rendering product'));
    }
  }
}
