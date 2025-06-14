import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furnistore/src/user/add_to_cart_review_rates/cart/add_to_cart.dart';
import 'package:furnistore/src/user/firebase_service/auth_service.dart';
import 'package:furnistore/src/user/firebase_service/firestore_service.dart';
import 'package:get/get.dart';

// Chairs Screen
class ChairsScreen extends StatefulWidget {
  const ChairsScreen({super.key});

  @override
  State<ChairsScreen> createState() => _ChairsScreenState();
}

class _ChairsScreenState extends State<ChairsScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // Adjust the height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Chairs',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
      ),
      body: Obx(() {
        // Fetch the products from Firestore
        _firestore.getProduct(category: 'Chair');
        if (_firestore.products.isEmpty) {
          return const Center(child: Text('Products not Available'));
        }

        // Use GridView.builder for dynamic grid layout
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 12, // Horizontal space between items
            mainAxisSpacing: 12, // Vertical space between items
            childAspectRatio: 0.75, // Adjust the aspect ratio
          ),
          padding: const EdgeInsets.all(16),
          itemCount: _firestore.products.length,
          itemBuilder: (context, index) {
            final product = _firestore.products[index];
            Uint8List imageBytes = base64Decode(product['image']);

            return _buildProductCard(context, product['name'], product['price'],
                imageBytes, product['description'], product['id'], () {
              _firestore.insertCart(
                  productId: product['id'],
                  quantity: 1,
                  userId: _auth.currentUser!.uid);
              _addToCart(product['name']);
            }, size);
          },
        );
      }),
    );
  }

  void _addToCart(String productName) async {
    // Trigger the animation
    await _animationController.forward();
    _animationController.reverse();

    // Show snackbar notification
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName added to cart!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Tables Screen
class TablesScreen extends StatelessWidget {
  TablesScreen({super.key});
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // Adjust the height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Tables',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
      ),
      body: Obx(() {
        // Fetch the products from Firestore
        _firestore.getProduct(category: 'Table');
        if (_firestore.products.isEmpty) {
          return const Center(child: Text('Products not Available'));
        }

        // Use GridView.builder for dynamic grid layout
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 12, // Horizontal space between items
            mainAxisSpacing: 12, // Vertical space between items
            childAspectRatio: 0.75, // Adjust the aspect ratio
          ),
          padding: const EdgeInsets.all(16),
          itemCount: _firestore.products.length,
          itemBuilder: (context, index) {
            final product = _firestore.products[index];
            Uint8List imageBytes = base64Decode(product['image']);

            return _buildProductCard(context, product['name'], product['price'],
                imageBytes, product['description'], product['id'], () {
              _firestore.insertCart(
                  productId: product['id'],
                  quantity: 1,
                  userId: _auth.currentUser!.uid);
              Get.snackbar('Success', 'added to cart ${product['name']}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(milliseconds: 800));
            }, size);
          },
        );
      }),
    );
  }
}

// Sofas Screen
class SofasScreen extends StatelessWidget {
  SofasScreen({super.key});
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // Adjust the height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Sofas',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
      ),
      body: Obx(() {
        // Fetch the products from Firestore
        _firestore.getProduct(category: 'Sofa');
        if (_firestore.products.isEmpty) {
          return const Center(child: Text('Products not Available'));
        }

        // Use GridView.builder for dynamic grid layout
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 12, // Horizontal space between items
            mainAxisSpacing: 12, // Vertical space between items
            childAspectRatio: 0.75, // Adjust the aspect ratio
          ),
          padding: const EdgeInsets.all(16),
          itemCount: _firestore.products.length,
          itemBuilder: (context, index) {
            final product = _firestore.products[index];
            Uint8List imageBytes = base64Decode(product['image']);

            return _buildProductCard(context, product['name'], product['price'],
                imageBytes, product['description'], product['id'], () {
              _firestore.insertCart(
                  productId: product['id'],
                  quantity: 1,
                  userId: _auth.currentUser!.uid);
              Get.snackbar('Success', 'added to cart ${product['name']}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(milliseconds: 800));
            }, size);
          },
        );
      }),
    );
  }
}

// Beds Screen
class BedsScreen extends StatelessWidget {
  BedsScreen({super.key});
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // Adjust the height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Beds',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
      ),
      body: Obx(() {
        // Fetch the products from Firestore
        _firestore.getProduct(category: 'Bed');
        if (_firestore.products.isEmpty) {
          return const Center(child: Text('Products not Available'));
        }

        // Use GridView.builder for dynamic grid layout
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 12, // Horizontal space between items
            mainAxisSpacing: 12, // Vertical space between items
            childAspectRatio: 0.75, // Adjust the aspect ratio
          ),
          padding: const EdgeInsets.all(16),
          itemCount: _firestore.products.length,
          itemBuilder: (context, index) {
            final product = _firestore.products[index];
            Uint8List imageBytes = base64Decode(product['image']);

            return _buildProductCard(context, product['name'], product['price'],
                imageBytes, product['description'], product['id'], () {
              _firestore.insertCart(
                  productId: product['id'],
                  quantity: 1,
                  userId: _auth.currentUser!.uid);
              Get.snackbar('Success', 'added to cart ${product['name']}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(milliseconds: 800));
            }, size);
          },
        );
      }),
    );
  }
}

// Lamps Screen
class LampsScreen extends StatelessWidget {
  LampsScreen({super.key});
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // Adjust the height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Lamps',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
      ),
      body: Obx(() {
        // Fetch the products from Firestore
        _firestore.getProduct(category: 'Lamp');
        if (_firestore.products.isEmpty) {
          return const Center(child: Text('Products not Available'));
        }

        // Use GridView.builder for dynamic grid layout
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 12, // Horizontal space between items
            mainAxisSpacing: 12, // Vertical space between items
            childAspectRatio: 0.75, // Adjust the aspect ratio
          ),
          padding: const EdgeInsets.all(16),
          itemCount: _firestore.products.length,
          itemBuilder: (context, index) {
            final product = _firestore.products[index];

            Uint8List imageBytes = base64Decode(product['image']);

            return _buildProductCard(context, product['name'], product['price'],
                imageBytes, product['description'], product['id'], () {
              _firestore.insertCart(
                  productId: product['id'],
                  quantity: 1,
                  userId: _auth.currentUser!.uid);
              Get.snackbar('Success', 'added to cart ${product['name']}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(milliseconds: 800));
            }, size);
          },
        );
      }),
    );
  }
}

Widget _buildProductCard(
    BuildContext context,
    String name,
    int price,
    Uint8List imagePath,
    String description,
    String productId,
    VoidCallback onTap,
    Size size) {
  return GestureDetector(
    onTap: () => Get.to(() => ProductDetailsScreen(
          nameProduct: name,
          description: description,
          price: price,
          imageBytes: imagePath,
          productId: productId,
        )),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
      color: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.memory(
                    imagePath,
                    height: size.height * 0.1,
                    width: size.width * 0.25,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
               Row(children: [ Icon(FontAwesomeIcons.pesoSign,size: 12,),Text(
                  ' $price',
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),],)
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    topLeft: Radius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '+',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
