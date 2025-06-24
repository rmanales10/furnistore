import 'package:flutter/material.dart';
import 'package:furnistore/src/web/screens/orders/order_controller.dart';
import 'package:furnistore/src/web/screens/sidebar.dart';
import 'package:get/get.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final OrderController _firestore = Get.put(OrderController());
  final Set<String> _selectedOrders = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Slightly lighter background
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Orders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: 1500), // Adjust width as needed
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                      return Column(
                        children: [
                          // Table Header
                          Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F2F6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 48,
                                  child: Checkbox(
                                    value: _selectedOrders.length ==
                                            _firestore.orders.length &&
                                        _firestore.orders.isNotEmpty,
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedOrders.addAll(_firestore
                                              .orders
                                              .map((o) => o['order_id']));
                                        } else {
                                          _selectedOrders.clear();
                                        }
                                      });
                                    },
                                  ),
                                ),
                                _headerCell('Order ID'),
                                _headerCell('Items'),
                                _headerCell('Status'),
                                _headerCell('Action'),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView.builder(
                              itemCount: _firestore.orders.length,
                              itemBuilder: (context, index) {
                                final order = _firestore.orders[index];
                                final isSelected =
                                    _selectedOrders.contains(order['order_id']);
                                return Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 48,
                                        child: Checkbox(
                                          value: isSelected,
                                          onChanged: (checked) {
                                            setState(() {
                                              if (checked == true) {
                                                _selectedOrders
                                                    .add(order['order_id']);
                                              } else {
                                                _selectedOrders
                                                    .remove(order['order_id']);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      _bodyCell(
                                        GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            '#${order['order_id']}',
                                            style: const TextStyle(
                                              color: Color(0xFF3E6BE0),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                      _bodyCell(
                                        Text(
                                          '${order['total_items']} Items',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        flex: 2,
                                      ),
                                      _bodyCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6C8CFF),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            order['status'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        flex: 2,
                                      ),
                                      _bodyCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Sidebar(
                                                                orderId: order[
                                                                    'order_id'],
                                                                initialIndex: 8,
                                                              ))),
                                              icon: const Icon(
                                                  Icons.remove_red_eye,
                                                  color: Color(0xFFB0B0B0)),
                                              tooltip: 'View',
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                bool confirmDelete =
                                                    await _showDeleteConfirmationDialog(
                                                        context);
                                                if (confirmDelete) {
                                                  await _firestore.deleteOrder(
                                                      order['order_id']);
                                                  await _firestore.getOrders();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Order deleted successfully')),
                                                  );
                                                }
                                              },
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                        flex: 2,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _bodyCell(Widget child, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: child,
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
