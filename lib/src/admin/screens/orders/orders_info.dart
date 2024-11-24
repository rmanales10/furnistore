import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:furnistore/src/admin/screens/orders/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderInformationPage extends StatefulWidget {
  final String orderId;
  final String orderStatus;

  const OrderInformationPage(
      {super.key, required this.orderId, required this.orderStatus});

  @override
  State<OrderInformationPage> createState() => _OrderInformationPageState();
}

class _OrderInformationPageState extends State<OrderInformationPage> {
  final _orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Orders Information",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Obx(() {
              _orderController.getOrderInfo(orderId: widget.orderId);
              _orderController.getUserInfo(
                  userId: _orderController.orderInfo['user_id']);

              if (_orderController.orderInfo.containsKey('user_id') &&
                  _orderController.orderInfo['user_id'] != null) {
                _orderController.getUserInfo(
                    userId: _orderController.orderInfo['user_id']);
              }

              final orderInfo = _orderController.orderInfo;
              final userInfo = _orderController.userInfo;

              Uint8List profilePic;
              if (userInfo['image'] != null) {
                profilePic = base64Decode(userInfo['image']);
              } else {
                profilePic = Uint8List.fromList([]);
              }
              Timestamp dateTimestamp =
                  orderInfo['date'] as Timestamp; // Firebase Timestamp
              DateTime dateTime = dateTimestamp.toDate(); // Convert to DateTime
              String formattedDate =
                  DateFormat('MMMM dd, yyyy').format(dateTime);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      // Wrap here to make only this section scrollable
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _orderInformationCard(context, formattedDate,
                              orderInfo['total_items'], orderInfo['total']),
                          const SizedBox(height: 20),
                          _itemsCard(context),
                          const SizedBox(height: 20),
                          _transactionsCard(context),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: _customerDetailsCard(
                        context,
                        userInfo['name'] ?? 'unknown',
                        userInfo['email'] ?? 'unknown',
                        userInfo['phone_number'] ?? 'unknown',
                        '${userInfo['address']} ${userInfo['town_city']} ${userInfo['postcode']} ',
                        profilePic),
                  ),
                ],
              );
            })),
      ),
    );
  }

  Widget _orderInformationCard(
      BuildContext context, String date, int items, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Information",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _orderInformationDetail("Date", date),
              _orderInformationDetail("Items", "$items Items"),
              Obx(() {
                return Row(
                  children: [
                    const Text("Status", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _orderController.orderStatus.value == ''
                          ? widget.orderStatus
                          : _orderController.orderStatus.value,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(color: Colors.blue),
                      underline: const SizedBox(),
                      items: ["Pending", "Shipped", "Delivered", "Cancelled"]
                          .map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        await _orderController.updateStatus(
                            orderId: widget.orderId, status: value!);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Status updated to $value'),
                        ));
                      },
                    ),
                  ],
                );
              }),
              _orderInformationDetail("Total", "₱ $total"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderInformationDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _itemsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () {
          _orderController.getAllProducts(orderId: widget.orderId);
          _orderController.getOrderInfo(orderId: widget.orderId);
          if (_orderController.allProducts.isEmpty ||
              _orderController.orderInfo.isEmpty) {
            return const Center(
              child: Text(
                'No orders available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          final orderInfo = _orderController.orderInfo;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Added Expanded and ListView.builder for scrolling
              SizedBox(
                height:
                    250, // Set an appropriate height for the scrollable list
                child: ListView.builder(
                  shrinkWrap:
                      true, // Needed to make ListView work inside Column
                  physics: const BouncingScrollPhysics(), // Enable scrolling
                  itemCount: _orderController.allProducts.length,
                  itemBuilder: (context, index) {
                    final product = _orderController.allProducts[index];
                    Uint8List? imageBytes = base64Decode(product['image']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _itemDetail(
                        context,
                        '${product['name']} (x${product['quantity']})',
                        "₱ ${product['price']}",
                        imageBytes,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _subtotalDetail("Subtotal", "₱ ${orderInfo['sub_total']}"),
              _subtotalDetail("Delivery Fee", "₱ ${orderInfo['delivery_fee']}"),
              const Divider(height: 30),
              _subtotalDetail("Total", "₱ ${orderInfo['total']}"),
            ],
          );
        },
      ),
    );
  }

  Widget _itemDetail(
      BuildContext context, String itemName, String price, Uint8List image) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: MemoryImage(image),
            ),
            const SizedBox(width: 10),
            Text(
              itemName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          price,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _transactionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.money, color: Colors.blue),
          SizedBox(width: 10),
          Text(
            "Cash",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _customerDetailsCard(BuildContext context, String name, String email,
      String number, String deliveryAddress, Uint8List profilePic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              backgroundImage: MemoryImage(profilePic),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(email,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            "Contact Number",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(number, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          const Text(
            "Delivery Address",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(deliveryAddress, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _subtotalDetail(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
