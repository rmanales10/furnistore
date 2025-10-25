import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/app/payment_track_order/order_controller.dart';
import 'package:furnistore/app/payment_track_order/order_detail_screen.dart';
import 'package:furnistore/app/firebase_service/firestore_service.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Order Products Screen - Shows products from a specific order
// ignore: must_be_immutable
class OrdersScreen1 extends StatelessWidget {
  String orderId;
  String orderStatus;
  OrdersScreen1(
      {super.key, required this.orderId, this.orderStatus = 'pending'});
  final _controller = Get.put(OrderController());
  final _firestoreService = FirestoreService();

  /// Check if current user has already reviewed a product
  Future<bool> _checkIfUserReviewedProduct(String productId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      return await _firestoreService.hasUserReviewedProduct(
        productId: productId,
        userId: currentUser.uid,
      );
    } catch (e) {
      print('Error checking if user reviewed product: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Order Products',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        _controller.getProductList(orderId: orderId);

        if (_controller.productList['products'] == null ||
            _controller.productList['products'].isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Products Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This order has no products',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Items Header - Matching OrderDetailScreen
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Product List
              ..._controller.productList['products'].map<Widget>((product) {
                Uint8List imageBytes;
                if (product['image'] != null) {
                  imageBytes = base64Decode(product['image']);
                } else {
                  imageBytes = Uint8List.fromList([]);
                }

                return OrderProductCard(
                  product: product,
                  imageBytes: imageBytes,
                  orderStatus: orderStatus,
                  orderId: orderId,
                  checkIfUserReviewedProduct: _checkIfUserReviewedProduct,
                  onReviewSubmitted: () {
                    _controller.getProductList(orderId: orderId);
                  },
                );
              }).toList(),
            ],
          ),
        );
      }),
    );
  }
}

// Order Product Card Widget - Matching OrderDetailScreen design
class OrderProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Uint8List imageBytes;
  final String orderStatus;
  final String orderId;
  final Future<bool> Function(String) checkIfUserReviewedProduct;
  final VoidCallback onReviewSubmitted;

  const OrderProductCard({
    super.key,
    required this.product,
    required this.imageBytes,
    required this.orderStatus,
    required this.orderId,
    required this.checkIfUserReviewedProduct,
    required this.onReviewSubmitted,
  });

  // Helper method to display peso symbol with FontAwesome
  Widget _buildPesoText(String amount, {TextStyle? style}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          FontAwesomeIcons.pesoSign,
          size: (style?.fontSize ?? 16) * 0.8,
          color: style?.color ?? Colors.black87,
        ),
        const SizedBox(width: 2),
        Text(
          amount,
          style: style,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image - Matching OrderDetailScreen
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageBytes.isNotEmpty
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details - Matching OrderDetailScreen layout
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                _buildPesoText(
                  '${(product['price'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size (H ${product['height'] ?? 'N/A'} cm /W ${product['width'] ?? 'N/A'}cm)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (product['quantity'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${product['quantity']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                // Review Button - Only show for delivered orders
                if (orderStatus.toLowerCase() == 'delivered') ...[
                  const SizedBox(height: 12),
                  FutureBuilder<bool>(
                    future: checkIfUserReviewedProduct(
                      product['product_id'] ?? product['id'] ?? '',
                    ),
                    builder: (context, snapshot) {
                      bool hasReviewed = snapshot.data ?? false;

                      return SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: hasReviewed
                              ? null
                              : () {
                                  // Open review bottom sheet
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => ReviewBottomSheet(
                                      productId: product['product_id'] ??
                                          product['id'] ??
                                          '',
                                      productName:
                                          product['name'] ?? 'Unknown Product',
                                      productImage: product['image'] ?? '',
                                      orderId: orderId,
                                      userName:
                                          'Current User', // You might want to get this from auth
                                      userImage:
                                          '', // You might want to get this from auth
                                      onReviewSubmitted: onReviewSubmitted,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasReviewed
                                ? Colors.grey
                                : const Color(0xFF3E6BE0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            hasReviewed ? 'Reviewed' : 'Review',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
