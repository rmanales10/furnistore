import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/src/user/home_screen.dart';
import 'package:furnistore/src/user/payment_track_order/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _orderController = Get.put(OrderController());
  late final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.off(() => const HomeScreen()),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() {
              _orderController.getOrderStatus();

              // Check if the order status list is empty
              if (_orderController.orderStatus.isEmpty) {
                return const Center(
                  child: Text('No Order Available'),
                );
              }

              // Use Expanded to give ListView a bounded height
              return Expanded(
                child: ListView.builder(
                  itemCount: _orderController.orderStatus.length,
                  itemBuilder: (context, index) {
                    final order = _orderController.orderStatus[index];

                    // Correctly handle Firebase Timestamp and convert to DateTime
                    Timestamp dateTimestamp =
                        order['date'] as Timestamp; // Firebase Timestamp
                    DateTime dateTime =
                        dateTimestamp.toDate(); // Convert to DateTime
                    String formattedDate =
                        DateFormat('MMMM dd, yyyy').format(dateTime);

                    // Return the order card widget
                    return _buildOrderCard(
                      status: order['status'],
                      statusDate: formattedDate,
                      deliveryDate: order['delivery_date'] ?? 'Processing',
                    );
                  },
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String status,
    required String statusDate,
    required String deliveryDate,
  }) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 16.0), // Add margin for spacing between cards
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF3E6BE0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusDate,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: Colors.black,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Delivery Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF3E6BE0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            deliveryDate,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
