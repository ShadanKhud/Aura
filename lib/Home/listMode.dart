import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aura_app/Settings/settings.dart';
import 'package:aura_app/wishlist/wishlist.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late ScrollController _scrollController;
  late QuerySnapshot _productsSnapshot;
  bool _isLoading = false;
  bool _hasMore = true;
  Map<String, dynamic>? _selectedProduct; // Track the selected product

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadProducts();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      // If we are at the bottom of the list and not currently loading
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch the initial set of products (e.g., limit to 6)
    var snapshot = await FirebaseFirestore.instance
        .collection('products_asos')
        .limit(6)
        .get();

    setState(() {
      _isLoading = false;
      _productsSnapshot = snapshot;
      _hasMore = snapshot.docs.length == 6; // Check if more products exist
    });
  }

  Future<void> _loadMoreProducts() async {
    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // Fetch more products starting from the last document in the current snapshot
    var lastDoc = _productsSnapshot.docs.last;
    var snapshot = await FirebaseFirestore.instance
        .collection('products_asos')
        .startAfterDocument(lastDoc)
        .limit(6)
        .get();

    setState(() {
      _isLoading = false;
      _productsSnapshot.docs.addAll(snapshot.docs); // Append the new products
      _hasMore = snapshot.docs.length == 6; // Check if more products exist
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectProduct(Map<String, dynamic> product) {
    setState(() {
      _selectedProduct = product;
    });
  }

  void _deselectProduct() {
    setState(() {
      _selectedProduct = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AURA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Show the product details view if a product is selected, else show the grid
          Expanded(
            child: _selectedProduct == null
                ? _isLoading && _productsSnapshot.docs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _productsSnapshot.docs.isEmpty
                        ? const Center(child: Text('No products found'))
                        : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 columns
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio:
                                  0.75, // Aspect ratio for the grid items
                            ),
                            itemCount: _productsSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              var product = _productsSnapshot.docs[index].data()
                                  as Map<String, dynamic>;

                              // Ensure product contains necessary data
                              if (product['images'] == null ||
                                  product['name'] == null ||
                                  product['price'] == null) {
                                return const Center(
                                    child: Text('Product data is incomplete'));
                              }

                              return ProductCard(
                                product: product,
                                onTap: () => _selectProduct(product),
                              );
                            },
                          )
                : _buildProductDetailView(),
          ),
          if (_isLoading)
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
        currentIndex: 4, // Settings tab index
        onTap: (index) {
          if (index == 0) {
            return;
          } else if (index == 1) {
            // Navigate to Search Page
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchPage()));
          } else if (index == 2) {
            // Navigate to Cart Page
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CartPage()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => WishlistPage()));
          } else if (index == 4) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SettingsPage()));
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

  Widget _buildProductDetailView() {
    if (_selectedProduct == null) return Container();

    var product = _selectedProduct!;
    String imagesString = product['images'];
    imagesString = imagesString.replaceAll("'", '"');
    List<String> imageUrls = List<String>.from(jsonDecode(imagesString));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrls.isNotEmpty
              ? ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    imageUrls[0], // First image URL from the list
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250, // Adjusted height for image
                  ),
                )
              : Container(),
          const SizedBox(height: 16),
          Text(
            product['name'] ?? 'No Name',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            '${product['price'] ?? 'N/A'} SAR',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _deselectProduct,
            child: const Text('Back to Products'),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    try {
      String imagesString = product['images'];
      imagesString = imagesString.replaceAll("'", '"');
      List<String> imageUrls = List<String>.from(jsonDecode(imagesString));

      return GestureDetector(
        onTap: onTap,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          child: Image.network(
                            imageUrls[0],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? 'No Name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${product['price'] ?? 'N/A'} SAR',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error parsing product data: $e');
      return const Center(child: Text('Error loading product'));
    }
  }
}
