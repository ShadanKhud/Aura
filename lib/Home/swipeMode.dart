import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:aura_app/Settings/settings.dart';
import 'package:aura_app/wishlist/wishlist.dart';
import 'package:aura_app/Home/listMode.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SwipeModePage extends StatefulWidget {
  const SwipeModePage({Key? key}) : super(key: key);

  @override
  State<SwipeModePage> createState() => _SwipeModePageState();
}

class _SwipeModePageState extends State<SwipeModePage> {
  final CardSwiperController controller = CardSwiperController();
  List<Map<String, dynamic>> products = [];
  DocumentSnapshot? lastDocument;
  bool isFetching = false;
  Set<String> wishlistItems = {};

  @override
  void initState() {
    super.initState();
    _loadWishlist();
    _loadProducts();
  }

  ///  Fetch wishlist items from Firestore
  Future<void> _loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('wishlist')
        .get();

    setState(() {
      wishlistItems = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  ///  Add or Remove from Wishlist
  Future<void> _toggleWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId);

    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
      setState(() {
        wishlistItems.remove(productId);
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
        wishlistItems.add(productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to wishlist!')),
      );
    }
  }

  ///  Fetches products in batches of 6
  Future<void> _loadProducts({int limit = 6}) async {
    if (isFetching) return;
    isFetching = true;

    try {
      Query query = FirebaseFirestore.instance
          .collection('clothes')
          .orderBy('product_number')
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        isFetching = false;
        return;
      }

      lastDocument = snapshot.docs.last;

      final List<Map<String, dynamic>> newProducts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'image': (data['images'] as List<dynamic>).isNotEmpty
              ? data['images'][0]
              : 'https://via.placeholder.com/150', // Fallback image
          'title': data['title'] ?? 'Unknown Title',
          'price': data['price'] != null ? '${data['price']} SAR' : 'N/A',
          'rating': data['rating']?.toDouble() ?? 0.0,
        };
      }).toList();

      setState(() {
        products.addAll(newProducts);
        isFetching = false;
      });
    } catch (e) {
      debugPrint("Error fetching products: $e");
      isFetching = false;
    }
  }

  /// ✅ Loads more products when the last card is swiped
  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (currentIndex == null || currentIndex >= products.length - 2) {
      _loadProducts(); // Load more products when near the end
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Image.asset(
                'assets/AuraLogo.png',
                scale: 5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsPage()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 600,
              child: products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : CardSwiper(
                      controller: controller,
                      cardsCount: products.length,
                      allowedSwipeDirection: const AllowedSwipeDirection.only(
                          left: true, right: true),
                      onSwipe: _onSwipe,
                      numberOfCardsDisplayed: 3,
                      backCardOffset: const Offset(20, 20),
                      padding: EdgeInsets.zero,
                      cardBuilder: (context,
                          index,
                          horizontalThresholdPercentage,
                          verticalThresholdPercentage) {
                        return _buildProductCard(products[index], index);
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 96, 95, 95),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // For "Home"
        onTap: (index) {
          if (index == 0) {
            // Home - current page
          } else if (index == 1) {
            // Search Page
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SearchPage()));
          } else if (index == 2) {
            // Cart Page
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CartPage()));
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

  ///  Product Card
  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final String productId = product['id'];
    final bool isFavorite = wishlistItems.contains(productId);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Column(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              product['image'],
              fit: BoxFit.cover,
              height: 500,
              width: double.infinity,
            ),
          ),
          ListTile(
            title: Text(product['title'], overflow: TextOverflow.ellipsis),
            subtitle: Text(product['price']),
            trailing: IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite
                    ? Colors.pink
                    : const Color.fromARGB(255, 53, 52, 52),
              ),
              onPressed: () => _toggleWishlist(productId),
            ),
          ),
          Transform.translate(
            offset: const Offset(-18, -20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  product['rating'].toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  product['rating'] >= 5
                      ? Icons.star // Full star if rating is 4.5 or higher
                      : product['rating'] >= 0.1
                          ? Icons
                              .star_half // Half star if rating is between 0.5 and 4.4
                          : Icons
                              .star_border, // Empty star if rating is less than 0.5
                  color: Colors.orange,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
