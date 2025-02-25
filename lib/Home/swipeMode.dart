import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:aura_app/Settings/settings.dart';
import 'package:aura_app/wishlist/wishlist.dart';
import 'package:aura_app/Home/listMode.dart';

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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  /// ✅ Improved Card Design matching your preference
  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // ✅ Product Image
              Container(
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ✅ Colors List (Bottom Left, Vertical)
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: product['colors']
                      .map<Widget>(
                        (color) => Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),

          // ✅ Product Details Section (Fixed Height)
          Container(
            height: 90, // 🔥 Fixed Bottom Section Height
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ Title & Heart Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // ✅ Like Button
                    IconButton(
                      icon: Icon(
                        product['isFavorite']
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: product['isFavorite']
                            ? Colors.pink
                            : const Color.fromARGB(255, 0, 0, 0),
                        size: 28, // ✅ Bigger Heart Icon
                      ),
                      onPressed: () {
                        setState(() {
                          products[index]['isFavorite'] =
                              !products[index]['isFavorite'];
                        });
                      },
                    ),
                  ],
                ),

                // ✅ Price & Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['price'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
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
                              ? Icons
                                  .star // Full star if rating is 4.5 or higher
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Fetches products in batches of 6
  Future<void> fetchProducts({int limit = 6}) async {
    if (isFetching) return;
    isFetching = true;

    try {
      Query query = FirebaseFirestore.instance
          .collection('clothes')
          .orderBy('title')
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
          'image': data['images'][0], // Use first image URL
          'title': data['title'],
          'price': '${data['price']} SAR',
          'rating': data['rating']?.toDouble() ?? 0.0,
          'colors': (data['colors'] as List<dynamic>)
              .map((colorName) => Color(_hexToColor(colorName)))
              .toList(),
          'isFavorite': false,
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

  /// ✅ Converts Color Name to Hex Code
  int _hexToColor(String colorName) {
    Map<String, String> colorMap = {
      "Black": "0xFF000000",
      "Chocolate Fondant": "0xFF7B3F00",
      "Hot Pink": "0xFFFF69B4",
      "Ivory": "0xFFFFFFF0",
      "Military Olive": "0xFF6F6F3F",
      "Rose Dust": "0xFF9E5E6F",
      "Ultramarine Green": "0xFF006B3C",
      "Dark Purple": "0xFF301934",
      "Navy": "0xFF000080",
      "Praline": "0xFFAD6F69",
      "Beige": "0xFFF5F5DC"
    };
    return int.parse(colorMap[colorName] ?? "0xFF808080");
  }

  /// ✅ Loads more products when the last card is swiped
  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (currentIndex == null || currentIndex >= products.length - 2) {
      fetchProducts();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ App Bar Matching List Mode
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

      // ✅ Bottom Navigation Bar Matching List Mode
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
}
