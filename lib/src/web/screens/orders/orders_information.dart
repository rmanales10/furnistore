import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/src/web/screens/orders/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrdersInformation extends StatefulWidget {
  final String orderId;
  const OrdersInformation({super.key, required this.orderId});

  @override
  State<OrdersInformation> createState() => _OrdersInformationState();
}

class _OrdersInformationState extends State<OrdersInformation> {
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Obx(() {
            orderController.getOrderInfo(orderId: "FURN-1733388878102");

            if (orderController.orderInfo.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            orderController.getUserInfo(
                userId: orderController.orderInfo['user_id'].toString());
            print(orderController.orderInfo['user_id'].toString());
            print(orderController.userInfo);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
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
                              status: orderController.orderInfo['status'] ?? '',
                              statusOptions: [
                                'Pending',
                                'Shipped',
                                'Delivered'
                              ],
                              onStatusChanged: (value) {},
                              total:
                                  orderController.orderInfo['total'].toString(),
                            ),
                            const SizedBox(height: 20),
                            itemsSummaryCard(
                              items: [
                                {
                                  'image': 'assets/no_profile.webp',
                                  'name': 'Item 1',
                                  'price': '100'
                                }
                              ],
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
                        contactNumber: orderController.userInfo['phone'] ?? '',
                        address: orderController.userInfo['address'] ?? '',
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
                    color: const Color(0xFF7B9EFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: status,
                      dropdownColor: const Color(0xFFF7F8FA),
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                      items: statusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(color: Colors.black)),
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
                Text(total,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
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
  required List<Map<String, String>> items, // [{image, name, price}]
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
                    backgroundImage: AssetImage(item['image']!),
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
                  Text(
                    item['price']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
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
                  Text(subtotal, style: const TextStyle(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text('Delivery Fee', style: TextStyle(fontSize: 15)),
                  ),
                  Text(deliveryFee, style: const TextStyle(fontSize: 15)),
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
                  Text(total,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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
