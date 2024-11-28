import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:furnistore/src/user/payment_track_order/order_controller.dart';
import 'package:get/get.dart';

// Order Screen
class OrdersScreen1 extends StatelessWidget {
  OrdersScreen1({super.key});
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
          'Product List',
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
              child: Builder(
                builder: (context) {
                  try {
                    String base64Image =
                        _controller.orderStatus.first['products'][0]['image'];
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
                        'assets/products/default.png',
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
                              if (status == 'Delivered') {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => ReviewBottomSheet(),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(
                              'Review',
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

// Review Bottom Sheet

class ReviewBottomSheet extends StatefulWidget {
  const ReviewBottomSheet({super.key});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int rating = 0;
  bool showThankYou = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        // Use scrollable content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 180),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (showThankYou) ...[
              // Thank you message contents
              Container(
                height: 220,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Done!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Thank you for your review!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 28,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Review input fields
              Row(
                children: [
                  const SizedBox(
                    width: 40,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              // User Profile Image Placeholder
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 18,
                                backgroundImage: const AssetImage(
                                    'assets/no_profile.webp'), // Dummy image
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'User Name', // Replace with dynamic data
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'User Comment', // Replace with dynamic data
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Star rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(5, (index) {
                            return SizedBox(
                              width: 30,
                              child: IconButton(
                                icon: Icon(
                                  index < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 25,
                                ),
                                onPressed: () {
                                  setState(() {
                                    rating = index + 1;
                                  });
                                },
                                constraints: const BoxConstraints(),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Adjust the image position
                  Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(-50, 10),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                          child: Image.asset(
                            'assets/products/edmond_table.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Comment TextField
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Your comment',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
            const SizedBox(
                height: 16), // Adding a little space before the button
            // Submit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showThankYou = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Say it!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
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
