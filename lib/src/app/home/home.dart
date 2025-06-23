import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furnistore/src/app/add_to_cart_review_rates/cart/add_to_cart.dart';
import 'package:furnistore/src/app/firebase_service/auth_service.dart';
import 'package:furnistore/src/app/firebase_service/firestore_service.dart';
import 'package:furnistore/src/app/profile/edit_profile/profile_controller.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());
  final _profileController = Get.put(ProfileController());
  final _search = TextEditingController();
  late AnimationController _animationController;
  // Variable to store search results
  RxList<Map<String, dynamic>> filteredProducts =
      RxList<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();

    // Initialize filteredProducts with all products
    _firestore.getAllProduct();
    filteredProducts.value = _firestore.allProducts;

    // Add listener to search text field
    _search.addListener(() {
      filterProducts(_search.text);
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      // If search query is empty, show all products
      filteredProducts.value = _firestore.allProducts;
    } else {
      // Filter products by name
      filteredProducts.value = _firestore.allProducts
          .where((product) => (product['name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Obx(() {
                  _profileController.getUserInfo();
                  final userInfo = _profileController.userInfo;
                  final image = userInfo['image'] ?? '';
                  Uint8List imageBytes =
                      image.isNotEmpty ? base64Decode(image) : Uint8List(0);

                  return Row(
                    children: [
                      ClipOval(
                        child: imageBytes.isEmpty
                            ? Image.asset('assets/no_profile.webp',
                                fit: BoxFit.cover, width: 50, height: 50)
                            : Image.memory(
                                imageBytes,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Hi, ${userInfo['name'] ?? 'No name'}\nStart Shopping Today!',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 30),
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search for Furniture',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 114, 114, 114),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: Color.fromARGB(255, 114, 114, 114),
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(255, 242, 241, 241),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Categories',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCategoryIcon(context, 'assets/categories/chair.png',
                        'Chairs', '/chair'),
                    const SizedBox(width: 20),
                    _buildCategoryIcon(context, 'assets/categories/table.png',
                        'Tables', '/table'),
                    const SizedBox(width: 20),
                    _buildCategoryIcon(context, 'assets/categories/sofa.png',
                        'Sofas', '/sofa'),
                    const SizedBox(width: 20),
                    _buildCategoryIcon(
                        context, 'assets/categories/bed.png', 'Beds', '/bed'),
                    const SizedBox(width: 20),
                    _buildCategoryIcon(context, 'assets/categories/lamp.png',
                        'Lamps', '/lamp'),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'All Products',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  // Listen to filtered products
                  if (filteredProducts.isEmpty) {
                    return const Center(child: Text('Products not Available'));
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final productName =
                            product['name'] ?? 'Unnamed Product';
                        final productPrice = product['price'] ?? 0;
                        final productDescription =
                            product['description'] ?? 'No description';
                        final productImage = product['image'] ?? '';
                        final productId = product['id'] ?? '';

                        Uint8List imageBytes;
                        try {
                          imageBytes = base64Decode(productImage);
                        } catch (e) {
                          imageBytes = Uint8List(0);
                        }

                        return _buildProductCard(
                            context,
                            productName,
                            productPrice,
                            imageBytes,
                            productDescription,
                            productId, () {
                          _firestore.insertCart(
                            productId: productId,
                            quantity: 1,
                            userId: _auth.currentUser!.uid,
                          );
                          _addToCart(productName);
                        }, size);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
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

Widget _buildCategoryIcon(
    BuildContext context, String imagePath, String label, String route) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, route);
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(imagePath, width: 35, height: 35),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    ),
  );
}

Widget _buildProductCard(
  BuildContext context,
  String name,
  int price,
  Uint8List imageBytes,
  String description,
  String productId,
  VoidCallback onTap,
  Size size,
) {
  return GestureDetector(
    onTap: () => Get.to(() => ProductDetailsScreen(
          nameProduct: name,
          description: description,
          price: price,
          imageBytes: imageBytes,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.memory(
                    imageBytes,
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
                  color: Color(0xFF3E6BE0),
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
