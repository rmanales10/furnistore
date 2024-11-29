import 'dart:typed_data';
import 'package:furnistore/src/user/add_to_cart_review_rates/reviews/reviews_rating.dart';
import 'package:furnistore/src/user/add_to_cart_review_rates/reviews/reviews_controller.dart';
import 'package:furnistore/src/user/firebase_service/auth_service.dart';
import 'package:furnistore/src/user/firebase_service/firestore_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProductDetailsScreen extends StatefulWidget {
  String nameProduct;
  String description;
  int price;
  Uint8List imageBytes;
  String productId;
  ProductDetailsScreen(
      {super.key,
      required this.nameProduct,
      required this.description,
      required this.price,
      required this.imageBytes,
      required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _counter = 1.obs;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());
  final _reviewsController = Get.put(ReviewsController());

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Define the scale animation
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart() async {
    // Trigger the animation
    await _animationController.forward();
    _animationController.reverse();

    // Show snackbar notification
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.nameProduct} added to cart!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Obx(() {
            _reviewsController.getAllReviews(productId: widget.productId);
            final List<Map<String, dynamic>> review =
                List<Map<String, dynamic>>.from(
                    _reviewsController.allReviews['reviews'] ?? []);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Image.memory(
                      widget.imageBytes,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Product Title, Price, and Rating
                Text(
                  '₱ ${widget.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.nameProduct,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '4.5',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '(${review.length} Reviews)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Product Description
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Reviews Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews (${review.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                        onTap: () => Get.to(() => ReviewsScreen(
                              productId: widget.productId,
                            )),
                        child: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),

                // Quantity Selector and Add to Cart Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(() => Row(
                            children: [
                              IconButton(
                                onPressed: () => _counter.value <= 1
                                    ? null
                                    : _counter.value--,
                                icon: const Icon(Icons.remove, size: 18),
                              ),
                              Text(
                                _counter.toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () => _counter.value++,
                                icon: const Icon(Icons.add, size: 18),
                              ),
                            ],
                          )),
                    ),

                    // Add to Cart Button with Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: ElevatedButton(
                        onPressed: () {
                          _addToCart();
                          _firestore.insertCart(
                              productId: widget.productId,
                              quantity: _counter.value,
                              userId: _auth.currentUser!.uid);
                          // _firestore.insertCart(productId: widget.productId, quantity: _counter.value, userId: userId)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16), // Adjust button size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
