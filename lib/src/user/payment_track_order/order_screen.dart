import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:furnistore/src/user/payment_track_order/order_controller.dart';
import 'package:furnistore/src/user/payment_track_order/review_each.dart';
import 'package:get/get.dart';

// Order Screen
class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final _controller = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: Obx(() {
        _controller.getOrderStatus();
        return ListView.separated(
          padding: const EdgeInsets.only(top: 12),
          itemCount: _controller.orderStatus.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final order = _controller.orderStatus[index];
            return OrderCard(
              isFirstItem: index != _controller.orderStatus.length,
              status: order['status'] ?? 'Packed',
              orderItems: '${order['total_items']} items', // Added items count
              orderId: '${order['order_id']}', // Added items count
            );
          },
        );
      }),
    );
  }
}

// Order Card Widget
class OrderCard extends StatelessWidget {
  final bool isFirstItem;
  final String status;
  final String orderItems;
  final String orderId;

  // Make the controller final and pass it via dependency injection
  final OrderController _controller = Get.find<OrderController>();

  OrderCard({
    super.key,
    required this.isFirstItem,
    required this.status,
    required this.orderItems,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.orderStatus.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Product Images (Dynamic GridView)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Adjust columns as needed
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _controller.orderStatus.first['products'].length,
                itemBuilder: (context, index) {
                  try {
                    // Fetch the image dynamically
                    String base64Image = _controller
                        .orderStatus.first['products'][index]['image'];
                    Uint8List decodedBytes = base64Decode(base64Image);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        decodedBytes,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    );
                  } catch (e) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/products/default.png', // Default image path
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderId,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            orderItems,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Standard Delivery',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (status == 'Delivered')
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        height: 30,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: const Color.fromARGB(255, 3, 138, 248),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              if (status != 'Delivered') {
                                Navigator.pushNamed(context, '/track');
                              } else {
                                Get.to(
                                  () => OrdersScreen1(
                                    orderId: orderId,
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(
                              status == 'Delivered' ? 'Review' : 'Track',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 3, 138, 248),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
