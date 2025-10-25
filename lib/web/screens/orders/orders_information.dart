import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furnistore/web/screens/orders/order_controller.dart';
import 'package:furnistore/web/screens/sidebar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const Color(0xFF3E6BE0); // Blue
    case 'processing':
      return const Color(0xFF3E6BE0); // Blue
    case 'out for delivery':
      return const Color(0xFF3E6BE0); // Blue
    case 'delivered':
      return const Color(0xFF3E6BE0); // Blue
    default:
      return const Color(0xFF3E6BE0); // Default blue
  }
}

String _getValidStatus(String status) {
  switch (status.toLowerCase()) {
    case 'shipped':
      return 'Processing'; // Map shipped to processing
    case 'cancelled':
      return 'Pending'; // Map cancelled to pending
    case 'returned':
      return 'Pending'; // Map returned to pending
    case 'pending':
    case 'processing':
    case 'out for delivery':
    case 'delivered':
      return status; // Keep valid statuses as is
    default:
      return 'Pending'; // Default to pending for unknown statuses
  }
}

class OrdersInformation extends StatefulWidget {
  final String orderId;
  const OrdersInformation({super.key, required this.orderId});

  @override
  State<OrdersInformation> createState() => _OrdersInformationState();
}

class _OrdersInformationState extends State<OrdersInformation> {
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    orderController.getOrderInfo(orderId: widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Obx(() {
            if (orderController.orderInfo.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (orderController.userInfo.isEmpty) {
              orderController.getUserInfo(
                  userId: orderController.orderInfo['user_id']);
              log(orderController.userInfo.toString());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Sidebar(
                                    initialIndex: 5,
                                  ))),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    const Text(
                      'Orders Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            orderInfoCard(
                              date: DateFormat('MMMM dd, yyyy').format(
                                  (orderController.orderInfo['date']
                                          as Timestamp)
                                      .toDate()),
                              items: int.parse(orderController
                                  .orderInfo['total_items']
                                  .toString()),
                              status: _getValidStatus(
                                  orderController.orderInfo['status'] ?? ''),
                              statusOptions: [
                                'Pending',
                                'Processing',
                                'Out for Delivery',
                                'Delivered',
                              ],
                              onStatusChanged: (value) async {
                                if (value != null &&
                                    value !=
                                        orderController.orderInfo['status']) {
                                  // Show confirmation for important status changes
                                  if (value == 'Delivered') {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirm Status Change'),
                                        content: Text(
                                            'Are you sure you want to change the order status to "$value"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: Text('Confirm'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed != true) return;
                                  }

                                  try {
                                    await orderController.updateOrderStatus(
                                      orderId: widget.orderId,
                                      newStatus: value,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Order status updated to $value'),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Error updating status: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                              total:
                                  orderController.orderInfo['total'].toString(),
                            ),
                            const SizedBox(height: 20),
                            itemsSummaryCard(
                              items: orderController.orderInfo['products']
                                  .map((product) => {
                                        'image': product['image'] ?? '',
                                        'name': product['name'] ?? '',
                                        'price': product['price'].toString()
                                      })
                                  .toList(),
                              subtotal: orderController.orderInfo['sub_total']
                                  .toString(),
                              deliveryFee: orderController
                                  .orderInfo['delivery_fee']
                                  .toString(),
                              total:
                                  orderController.orderInfo['total'].toString(),
                            ),
                            const SizedBox(height: 20),
                            transactionInfoCard(
                              iconAsset: 'assets/image_3.png',
                              label: orderController
                                      .orderInfo['mode_of_payment'] ??
                                  '',
                            )
                          ],
                        )),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: customerInfoCard(
                        avatarUrl: 'assets/no_profile.webp',
                        name: orderController.userInfo['name'] ?? '',
                        email: orderController.userInfo['email'] ?? '',
                        contactNumber:
                            orderController.userInfo['phone_number'] ?? '',
                        address:
                            '${orderController.userInfo['address']}, ${orderController.userInfo['town_city']}, ${orderController.userInfo['postcode']}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }
}

Widget orderInfoCard({
  required String date,
  required int items,
  required String status,
  required List<String> statusOptions,
  required void Function(String?) onStatusChanged,
  required String total,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
    ),
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text(date, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            // Items
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('$items Items',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            // Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(status).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: status,
                      dropdownColor: Colors.white,
                      iconEnabledColor: _getStatusColor(status),
                      iconSize: 20,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      items: statusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(value),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getStatusColor(value)
                                            .withOpacity(0.3),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  value,
                                  style: TextStyle(
                                    color: _getStatusColor(value),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onStatusChanged,
                    ),
                  ),
                ),
              ],
            ),
            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.pesoSign,
                      size: 14,
                    ),
                    Text(total,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(width: 45),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget customerInfoCard({
  required String avatarUrl,
  required String name,
  required String email,
  required String contactNumber,
  required String address,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(avatarUrl),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Contact Number',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          contactNumber,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Delivery Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          address,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

Widget itemsSummaryCard({
  required List items, // [{image, name, price}]
  required String subtotal,
  required String deliveryFee,
  required String total,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 24),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: MemoryImage(base64Decode(item['image']!)),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.pesoSign,
                        size: 14,
                      ),
                      Text(
                        item['price']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            )),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Subtotal', style: TextStyle(fontSize: 15)),
                  ),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.pesoSign, size: 14),
                      Text(subtotal, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text('Delivery Fee', style: TextStyle(fontSize: 15)),
                  ),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.pesoSign, size: 14),
                      Text(deliveryFee, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.pesoSign, size: 14),
                      Text(total,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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

Widget transactionInfoCard({
  required String iconAsset,
  required String label,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 40),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            iconAsset,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ],
    ),
  );
}
