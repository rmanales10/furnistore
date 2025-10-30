import 'package:flutter/material.dart';
import 'package:furnistore/web/screens/orders/order_controller.dart';
import 'package:furnistore/web/screens/sidebar.dart';
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
  void initState() {
    super.initState();
    _firestore.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Orders',
              style: TextStyle(
                fontSize: isMobile ? 24 : (isTablet ? 26 : 28),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1500),
                  child: Container(
                    padding:
                        EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 30)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() {
                      if (_firestore.orders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: isMobile ? 64 : 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No orders available',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (isMobile) {
                        // Mobile Card Layout
                        return ListView.builder(
                          itemCount: _firestore.orders.length,
                          itemBuilder: (context, index) {
                            final order = _firestore.orders[index];
                            return _buildOrderCard(order, context);
                          },
                        );
                      } else {
                        // Desktop/Tablet Table Layout
                        return Column(
                          children: [
                            // Table Header
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: isTablet ? 20 : 30),
                              height: isTablet ? 44 : 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F2F6),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  _headerCell('Order ID', isTablet),
                                  _headerCell('Items', isTablet),
                                  _headerCell('Status', isTablet),
                                  _headerCell('Action', isTablet),
                                ],
                              ),
                            ),

                            Expanded(
                              child: ListView.builder(
                                itemCount: _firestore.orders.length,
                                itemBuilder: (context, index) {
                                  final order = _firestore.orders[index];
                                  _selectedOrders.contains(order['order_id']);

                                  return Container(
                                    height: isTablet ? 52 : 56,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        _bodyCell(
                                          GestureDetector(
                                            onTap: () {},
                                            child: Text(
                                              '#${order['order_id']}',
                                              style: TextStyle(
                                                color: Color(0xFF3E6BE0),
                                                fontSize: isTablet ? 13 : 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          flex: 2,
                                          isTablet: isTablet,
                                        ),
                                        _bodyCell(
                                          Text(
                                            '${order['total_items']} Item/s',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isTablet ? 13 : 14,
                                            ),
                                          ),
                                          flex: 2,
                                          isTablet: isTablet,
                                        ),
                                        _bodyCell(
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isTablet ? 10 : 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                  order['status']),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              order['status'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: isTablet ? 12 : 13,
                                              ),
                                            ),
                                          ),
                                          flex: 2,
                                          isTablet: isTablet,
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
                                                      orderId:
                                                          order['order_id'],
                                                      initialIndex: 7,
                                                    ),
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.remove_red_eye,
                                                  color: Color(0xFFB0B0B0),
                                                  size: isTablet ? 20 : 24,
                                                ),
                                                tooltip: 'View',
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  bool confirmDelete =
                                                      await _showDeleteConfirmationDialog(
                                                          context);
                                                  if (confirmDelete) {
                                                    await _firestore
                                                        .deleteOrder(
                                                            order['order_id']);
                                                    await _firestore
                                                        .getOrders();
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Order deleted successfully'),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: isTablet ? 20 : 24,
                                                ),
                                                tooltip: 'Delete',
                                              ),
                                            ],
                                          ),
                                          flex: 2,
                                          isTablet: isTablet,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
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

  Widget _buildOrderCard(dynamic order, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '#${order['order_id']}',
                        style: TextStyle(
                          color: Color(0xFF3E6BE0),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 18, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  '${order['total_items']} Item/s',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.remove_red_eye, size: 18),
                    label: Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF3E6BE0),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Color(0xFF3E6BE0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Sidebar(
                          orderId: order['order_id'],
                          initialIndex: 7,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    bool confirmDelete =
                        await _showDeleteConfirmationDialog(context);
                    if (confirmDelete) {
                      await _firestore.deleteOrder(order['order_id']);
                      await _firestore.getOrders();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order deleted successfully'),
                          ),
                        );
                      }
                    }
                  },
                  child: Icon(Icons.delete, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Color(0xFF3B82F6);
      case 'processing':
        return Color(0xFF3B82F6);
      case 'out for delivery':
        return Color(0xFF3B82F6);
      case 'delivered':
        return Color(0xFF3B82F6);
      case 'cancelled':
        return Color(0xFF3B82F6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Widget _headerCell(String label, bool isTablet) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 13 : 15,
          ),
        ),
      ),
    );
  }

  Widget _bodyCell(Widget child, {int flex = 2, bool isTablet = false}) {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Delete Order'),
            content: const Text(
                'Are you sure you want to delete this order? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
