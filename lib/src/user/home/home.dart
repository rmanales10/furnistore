import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:furnistore/src/user/add_to_cart_review_rates/cart/add_to_cart.dart';
import 'package:furnistore/src/user/firebase_service/auth_service.dart';
import 'package:furnistore/src/user/firebase_service/firestore_service.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
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
                  'Popular Products',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  // Fetch the products from Firestore
                  _firestore.getAllProduct();
                  if (_firestore.allProducts.isEmpty) {
                    return const Center(child: Text('Products not Available'));
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.6, // Adjust this height as needed
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 12, // Horizontal space between items
                        mainAxisSpacing: 12, // Vertical space between items
                        childAspectRatio: 0.75, // Adjust the aspect ratio
                      ),
                      padding: const EdgeInsets.all(16),
                      itemCount: _firestore.allProducts.length,
                      itemBuilder: (context, index) {
                        final product = _firestore.allProducts[index];
                        Uint8List imageBytes = base64Decode(product['image']);
                        return _buildProductCard(
                          context,
                          product['name'],
                          product['price'],
                          imageBytes,
                          product['description'],
                          product['id'],
                          () {
                            _firestore.insertCart(
                              productId: product['id'],
                              quantity: 1,
                              userId: _auth.currentUser!.uid,
                            );
                            Get.snackbar(
                              'Success',
                              'Added to cart ${product['name']}',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(milliseconds: 800),
                            );
                          },
                        );
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
      Uint8List imagePath,
      String description,
      String productId,
      VoidCallback onTap) {
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
                      height: 100,
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
                  Text(
                    '₱ $price',
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
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
}
