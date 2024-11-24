import 'package:flutter/material.dart';
import 'package:furnistore/src/admin/screens/orders/order_controller.dart';
import 'package:furnistore/src/admin/screens/orders/orders_info.dart';
import 'package:get/get.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final OrderController _firestore = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Ensure full-width usage
          children: [
            const Text(
              'Orders',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double
                    .infinity, // Ensure container takes the full available width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Obx(() {
                  _firestore.getOrders();
                  if (_firestore.orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'No orders available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                        ), // Constrain table to at least screen width
                        child: DataTable(
                          columnSpacing: 5, // Increase column spacing
                          headingRowHeight: 50,
                          columns: [
                            myDataColumn('Order ID'),
                            myDataColumn('Items'),
                            myDataColumn('Status'),
                            myDataColumn('Action'),
                          ],
                          rows: _firestore.orders.map((order) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => OrderInformationPage(
                                            orderId: order['order_id'],
                                            orderStatus: order['status'],
                                          ));
                                    },
                                    child: Text(
                                      order['order_id'],
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(order['total_items'].toString())),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      order['status'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            Get.to(() => OrderInformationPage(
                                                  orderId: order['order_id'],
                                                  orderStatus: order['status'],
                                                )),
                                        icon: const Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          bool confirmDelete =
                                              await _showDeleteConfirmationDialog(
                                                  context);
                                          if (confirmDelete) {
                                            await _firestore
                                                .deleteOrder(order['order_id']);
                                            await _firestore.getOrders();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Order deleted successfully')),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn myDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Order'),
            content: const Text('Are you sure you want to delete this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
