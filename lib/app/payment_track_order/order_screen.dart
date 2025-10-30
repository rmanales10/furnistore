import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:furnistore/app/payment_track_order/order_controller.dart';
import 'package:furnistore/app/payment_track_order/review_each.dart';
import 'package:furnistore/app/payment_track_order/order_detail_screen.dart';
import 'package:get/get.dart';

// Order Screen
class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final _controller = Get.put(OrderController());

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
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        _controller.getOrderStatus();

        if (_controller.orderStatus.isEmpty) {
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
                  'No Orders Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your orders will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.orderStatus.length,
          itemBuilder: (context, index) {
            final order = _controller.orderStatus[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OrderCard(
                status: order['status'] ?? 'Pending',
                orderItems: '${order['total_items']} items',
                orderId: order['order_id'] ?? '',
                products: order['products'] ?? [],
              ),
            );
          },
        );
      }),
    );
  }
}

// Order Card Widget
class OrderCard extends StatelessWidget {
  final String status;
  final String orderItems;
  final String orderId;
  final List<dynamic> products;

  const OrderCard({
    super.key,
    required this.status,
    required this.orderItems,
    required this.orderId,
    required this.products,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF3B82F6);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'shipped':
        return const Color(0xFF3B82F6);
      case 'delivered':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left Column - Product Images (Stacked)
            _buildProductImagesStack(),
            const SizedBox(width: 12),

            // Middle Column - Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Item Count Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Order #$orderId',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        orderItems,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Delivery Type
                  Text(
                    'Standard Delivery',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Status
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ),

            // Right Column - Action Button
            const SizedBox(width: 12),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImagesStack() {
    if (products.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.image,
          color: Colors.grey.shade400,
          size: 20,
        ),
      );
    }

    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          // First image (bottom-right)
          if (products.length >= 2)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _buildProductImage(products[1]),
                ),
              ),
            ),

          // Second image (top-left)
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildProductImage(products[0]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(dynamic product) {
    try {
      String base64Image = product['image'] ?? '';
      if (base64Image.isNotEmpty) {
        Uint8List decodedBytes = base64Decode(base64Image);
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      }
    } catch (e) {
      // Handle error
    }

    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image,
        color: Colors.grey.shade400,
        size: 24,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isDelivered = status == 'Delivered';

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: isDelivered ? Colors.white : const Color(0xFF3B82F6),
        border: Border.all(
          color: isDelivered ? const Color(0xFF3B82F6) : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: () {
          if (isDelivered) {
            Get.to(() => OrderDetailScreen(orderId: orderId));
          } else {
            Get.to(() => OrderDetailScreen(orderId: orderId));
          }
        },
        style: TextButton.styleFrom(
          minimumSize: const Size(70, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          isDelivered ? 'Review' : 'Track',
          style: TextStyle(
            color: isDelivered ? const Color(0xFF3B82F6) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
