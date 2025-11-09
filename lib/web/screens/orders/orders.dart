import 'package:flutter/material.dart';
import 'package:furnistore/web/screens/orders/order_controller.dart';
import 'package:furnistore/web/screens/sidebar.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final OrderController _firestore = Get.put(OrderController());
  final Set<String> _selectedOrders = {};
  String _selectedFilter = 'Latest'; // Default filter: Latest orders
  String? _selectedStatusFilter; // Optional status filter
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _firestore.getOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await _firestore.getOrders();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // Get filtered and sorted orders
  List<dynamic> get _filteredOrders {
    List<dynamic> orders = List.from(_firestore.orders);

    // Apply status filter
    if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
      orders = orders.where((order) {
        final orderStatus = (order['status'] ?? '').toString().toLowerCase();
        return orderStatus == _selectedStatusFilter!.toLowerCase();
      }).toList();
    }

    // Apply sort filter
    orders.sort((a, b) {
      DateTime? dateA;
      DateTime? dateB;

      try {
        final dateAField = a['date'] ?? a['created_at'] ?? a['updated_at'];
        final dateBField = b['date'] ?? b['created_at'] ?? b['updated_at'];

        if (dateAField is Timestamp) {
          dateA = dateAField.toDate();
        }
        if (dateBField is Timestamp) {
          dateB = dateBField.toDate();
        }

        if (dateA == null || dateB == null) return 0;

        switch (_selectedFilter) {
          case 'Latest':
            return dateB.compareTo(dateA); // Newest first
          case 'Oldest':
            return dateA.compareTo(dateB); // Oldest first
          default:
            return dateB.compareTo(dateA); // Default to latest
        }
      } catch (e) {
        return 0;
      }
    });

    return orders;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : (isTablet ? 26 : 28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Filter buttons and refresh
                if (!isMobile)
                  Row(
                    children: [
                      // Refresh button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: IconButton(
                          icon: _isRefreshing
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF3E6BE0)),
                                  ),
                                )
                              : Icon(Icons.refresh, size: 18),
                          color: const Color(0xFF3E6BE0),
                          onPressed: _isRefreshing ? null : _refreshOrders,
                          tooltip: 'Refresh orders',
                        ),
                      ),
                      SizedBox(width: 12),
                      // Sort filter dropdown
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          underline: SizedBox(),
                          icon: Icon(Icons.sort, size: 18),
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                          items: ['Latest', 'Oldest'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedFilter = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      // Status filter dropdown
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String?>(
                          value: _selectedStatusFilter,
                          underline: SizedBox(),
                          icon: Icon(Icons.filter_list, size: 18),
                          hint: Text('All Status',
                              style: TextStyle(fontSize: 14)),
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                          items: [
                            DropdownMenuItem<String?>(
                                value: null, child: Text('All Status')),
                            DropdownMenuItem<String>(
                                value: 'pending', child: Text('Pending')),
                            DropdownMenuItem<String>(
                                value: 'processing', child: Text('Processing')),
                            DropdownMenuItem<String>(
                                value: 'out for delivery',
                                child: Text('Out for Delivery')),
                            DropdownMenuItem<String>(
                                value: 'delivered', child: Text('Delivered')),
                            DropdownMenuItem<String>(
                                value: 'cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatusFilter = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // Mobile filter buttons
            if (isMobile) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  // Refresh button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: _isRefreshing
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF3E6BE0)),
                              ),
                            )
                          : Icon(Icons.refresh, size: 18),
                      color: const Color(0xFF3E6BE0),
                      onPressed: _isRefreshing ? null : _refreshOrders,
                      tooltip: 'Refresh orders',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        underline: SizedBox(),
                        icon: Icon(Icons.sort, size: 18),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        items: ['Latest', 'Oldest'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String?>(
                        value: _selectedStatusFilter,
                        isExpanded: true,
                        underline: SizedBox(),
                        icon: Icon(Icons.filter_list, size: 18),
                        hint:
                            Text('All Status', style: TextStyle(fontSize: 14)),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        items: [
                          DropdownMenuItem<String?>(
                              value: null, child: Text('All Status')),
                          DropdownMenuItem<String>(
                              value: 'pending', child: Text('Pending')),
                          DropdownMenuItem<String>(
                              value: 'processing', child: Text('Processing')),
                          DropdownMenuItem<String>(
                              value: 'out for delivery',
                              child: Text('Out for Delivery')),
                          DropdownMenuItem<String>(
                              value: 'delivered', child: Text('Delivered')),
                          DropdownMenuItem<String>(
                              value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatusFilter = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

                      final filteredOrders = _filteredOrders;

                      if (filteredOrders.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt_outlined,
                                size: isMobile ? 64 : 80,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No orders match the selected filters',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedStatusFilter = null;
                                    _selectedFilter = 'Latest';
                                  });
                                },
                                child: Text('Clear Filters'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (isMobile) {
                        // Mobile Card Layout
                        return ListView.builder(
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
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
                                  // _headerCell('Notes', isTablet),
                                  Expanded(
                                    flex: 3,
                                    child:
                                        SizedBox(), // Empty space for notes column
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
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
                                        _bodyCell(
                                          _getOrderNote(order).isNotEmpty
                                              ? Text(
                                                  _getOrderNote(order),
                                                  style: TextStyle(
                                                    fontSize:
                                                        isTablet ? 12 : 13,
                                                    color: Colors.orange[700],
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                          flex: 3,
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
            if (_getOrderNote(order).isNotEmpty) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: Colors.orange[700]),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _getOrderNote(order),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
        return Colors.red;
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getOrderNote(dynamic order) {
    final status = (order['status'] ?? '').toString().toLowerCase();

    try {
      final orderDate =
          order['date'] ?? order['created_at'] ?? order['updated_at'];
      if (orderDate == null) {
        return ''; // No date available
      }

      DateTime orderDateTime;
      if (orderDate is Timestamp) {
        orderDateTime = orderDate.toDate();
      } else if (orderDate is String) {
        // Try to parse string date if needed
        return ''; // Skip string parsing for now
      } else {
        return '';
      }

      // Check if 3 hours or more have passed
      final now = DateTime.now();
      final difference = now.difference(orderDateTime);

      // Only show reminder if 3+ hours have passed
      if (difference.inHours < 3) {
        return ''; // Less than 3 hours, no reminder needed
      }

      // Default reminders based on status
      switch (status) {
        case 'pending':
          return 'Needs status update today';
        case 'processing':
          return 'Consider updating to next status';
        case 'out for delivery':
          return 'Track delivery and update when delivered';
        case 'delivered':
          return ''; // No action needed for delivered orders
        case 'cancelled':
          return ''; // No action needed for cancelled orders
        default:
          return 'Action required - check order status';
      }
    } catch (e) {
      return ''; // Error parsing date, return empty
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
