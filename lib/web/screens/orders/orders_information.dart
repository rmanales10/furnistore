import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furnistore/services/email_service.dart';
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
    case 'cancelled':
      return Colors.red; // Red for cancelled
    default:
      return const Color(0xFF3E6BE0); // Default blue
  }
}

String _getValidStatus(String status) {
  switch (status.toLowerCase()) {
    case 'shipped':
      return 'Processing'; // Map shipped to processing
    case 'cancelled':
      return 'Cancelled'; // Keep cancelled status
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

  /// Send email notification to customer about order status update
  Future<void> _sendOrderStatusEmail({
    required String customerEmail,
    required String customerName,
    required String orderId,
    required String newStatus,
    required String orderDate,
    required String totalAmount,
  }) async {
    try {
      // Get status-specific message
      String statusMessage = _getStatusMessage(newStatus);

      // Prepare email template
      String subject = 'Order Status Update - Order #$orderId';
      String message = '''
Dear $customerName,

Your order status has been updated to: $newStatus

Order Details:
- Order ID: #$orderId
- Order Date: $orderDate
- Total Amount: ₱$totalAmount

$statusMessage

Thank you for choosing FurniStore!

Best regards,
FurniStore Team
      ''';

      // Send email using EmailJS
      await EmailService.sendOrderStatusEmail(
        customerEmail: customerEmail,
        customerName: customerName,
        orderId: orderId,
        status: newStatus,
        message: message,
        subject: subject,
        orderDate: orderDate,
        totalAmount: totalAmount,
      );

      log('✅ Order status email sent successfully to $customerEmail');
    } catch (e) {
      log('❌ Error sending order status email: $e');
      // Don't throw error to prevent blocking status update
    }
  }

  /// Get status-specific message for email
  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Your order has been received and is being prepared for processing.';
      case 'processing':
        return 'Your order is currently being processed and prepared for shipment.';
      case 'out for delivery':
        return 'Great news! Your order is out for delivery and should arrive soon.';
      case 'delivered':
        return 'Your order has been successfully delivered! Thank you for your purchase.';
      default:
        return 'Your order status has been updated.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 30)),
        child: SingleChildScrollView(
          child: Obx(() {
            if (orderController.orderInfo.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 32 : 48),
                  child: CircularProgressIndicator(),
                ),
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
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: isMobile ? 20 : 24,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Orders Information',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : (isTablet ? 22 : 24),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 20),

                // Responsive Layout
                isMobile
                    ? Column(
                        children: [
                          // Customer info first on mobile
                          customerInfoCard(
                            profileImageBase64:
                                orderController.userInfo['image'] ?? '',
                            name: orderController.userInfo['name'] ?? '',
                            email: orderController.userInfo['email'] ?? '',
                            contactNumber:
                                orderController.userInfo['phone_number'] ?? '',
                            address:
                                '${orderController.userInfo['address']}, ${orderController.userInfo['town_city']}, ${orderController.userInfo['postcode']}',
                            isMobile: isMobile,
                          ),
                          SizedBox(height: 16),
                          orderInfoCard(
                            date: DateFormat('MMMM dd, yyyy').format(
                                (orderController.orderInfo['date'] as Timestamp)
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
                            onStatusChanged: (orderController
                                        .orderInfo['status']
                                        ?.toString()
                                        .toLowerCase() ==
                                    'cancelled')
                                ? null // Disable if cancelled
                                : (value) =>
                                    _handleStatusChange(value, context),
                            isCancelled: (orderController.orderInfo['status']
                                    ?.toString()
                                    .toLowerCase() ==
                                'cancelled'),
                            total:
                                orderController.orderInfo['total'].toString(),
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),
                          SizedBox(height: 16),
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
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),
                          SizedBox(height: 16),
                          transactionInfoCard(
                            iconAsset: 'assets/image_3.png',
                            label:
                                orderController.orderInfo['mode_of_payment'] ??
                                    '',
                            isMobile: isMobile,
                          )
                        ],
                      )
                    : Row(
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
                                        orderController.orderInfo['status'] ??
                                            ''),
                                    statusOptions: [
                                      'Pending',
                                      'Processing',
                                      'Out for Delivery',
                                      'Delivered',
                                    ],
                                    onStatusChanged: (orderController
                                                .orderInfo['status']
                                                ?.toString()
                                                .toLowerCase() ==
                                            'cancelled')
                                        ? null // Disable if cancelled
                                        : (value) =>
                                            _handleStatusChange(value, context),
                                    isCancelled: (orderController
                                            .orderInfo['status']
                                            ?.toString()
                                            .toLowerCase() ==
                                        'cancelled'),
                                    total: orderController.orderInfo['total']
                                        .toString(),
                                    isMobile: isMobile,
                                    isTablet: isTablet,
                                  ),
                                  SizedBox(height: isTablet ? 16 : 20),
                                  itemsSummaryCard(
                                    items: orderController.orderInfo['products']
                                        .map((product) => {
                                              'image': product['image'] ?? '',
                                              'name': product['name'] ?? '',
                                              'price':
                                                  product['price'].toString()
                                            })
                                        .toList(),
                                    subtotal: orderController
                                        .orderInfo['sub_total']
                                        .toString(),
                                    deliveryFee: orderController
                                        .orderInfo['delivery_fee']
                                        .toString(),
                                    total: orderController.orderInfo['total']
                                        .toString(),
                                    isMobile: isMobile,
                                    isTablet: isTablet,
                                  ),
                                  SizedBox(height: isTablet ? 16 : 20),
                                  transactionInfoCard(
                                    iconAsset: 'assets/image_3.png',
                                    label: orderController
                                            .orderInfo['mode_of_payment'] ??
                                        '',
                                    isMobile: isMobile,
                                  )
                                ],
                              )),
                          SizedBox(width: isTablet ? 16 : 20),
                          Expanded(
                            flex: 1,
                            child: customerInfoCard(
                              profileImageBase64:
                                  orderController.userInfo['image'] ?? '',
                              name: orderController.userInfo['name'] ?? '',
                              email: orderController.userInfo['email'] ?? '',
                              contactNumber:
                                  orderController.userInfo['phone_number'] ??
                                      '',
                              address:
                                  '${orderController.userInfo['address']}, ${orderController.userInfo['town_city']}, ${orderController.userInfo['postcode']}',
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> _handleStatusChange(String? value, BuildContext context) async {
    // Prevent status change if order is cancelled
    final currentStatus =
        orderController.orderInfo['status']?.toString().toLowerCase() ?? '';
    if (currentStatus == 'cancelled') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot change status of a cancelled order'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (value != null && value != orderController.orderInfo['status']) {
      // Show confirmation for important status changes
      if (value == 'Delivered') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.all(24),
            titlePadding: EdgeInsets.only(left: 24, right: 24, top: 24),
            actionsPadding: EdgeInsets.all(16),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF3E6BE0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF3E6BE0),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Confirm Status Change',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to change the order status to "$value"?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3E6BE0),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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

        // Send email notification to customer
        if (orderController.userInfo.isNotEmpty) {
          await _sendOrderStatusEmail(
            customerEmail: orderController.userInfo['email'] ??
                orderController.userInfo['user_email'] ??
                '',
            customerName: orderController.userInfo['name'] ??
                orderController.userInfo['username'] ??
                'Customer',
            orderId: widget.orderId,
            newStatus: value,
            orderDate: DateFormat('MMMM dd, yyyy').format(
                (orderController.orderInfo['date'] as Timestamp).toDate()),
            totalAmount: orderController.orderInfo['total'].toString(),
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Order status updated to $value and customer notified'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating status: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

Widget orderInfoCard({
  required String date,
  required int items,
  required String status,
  required List<String> statusOptions,
  required void Function(String?)? onStatusChanged,
  required String total,
  bool isMobile = false,
  bool isTablet = false,
  bool isCancelled = false,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
    ),
    padding: EdgeInsets.symmetric(
      vertical: isMobile ? 20 : (isTablet ? 20 : 24),
      horizontal: isMobile ? 20 : (isTablet ? 24 : 32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : 18,
          ),
        ),
        SizedBox(height: isMobile ? 20 : 32),
        isMobile
            ? Column(
                children: [
                  _buildInfoItem('Date', date, isMobile),
                  SizedBox(height: 16),
                  _buildInfoItem('Items', '$items Items', isMobile),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getStatusColor(status).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: isCancelled
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: status,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: _getStatusColor(status),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  items: statusOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: onStatusChanged,
                                ),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.pesoSign, size: 14),
                          Text(total,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 12 : 13)),
                        SizedBox(height: 8),
                        Text(date,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: isTablet ? 13 : 14)),
                      ],
                    ),
                  ),
                  // Items
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Items',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 12 : 13)),
                        SizedBox(height: 8),
                        Text('$items Items',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 13 : 14)),
                      ],
                    ),
                  ),
                  // Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 12 : 13)),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _getStatusColor(status).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12 : 16, vertical: 8),
                          child: isCancelled
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 12 : 16,
                                      vertical: 8),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: isTablet ? 12 : 14,
                                    ),
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: status,
                                    dropdownColor: Colors.white,
                                    iconEnabledColor: _getStatusColor(status),
                                    iconSize: 18,
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: isTablet ? 12 : 14,
                                    ),
                                    items: statusOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: onStatusChanged,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  // Total
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 12 : 13)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.pesoSign,
                                size: isTablet ? 12 : 14),
                            Text(total,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 14 : 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ],
    ),
  );
}

Widget _buildInfoItem(String label, String value, bool isMobile) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 15)),
    ],
  );
}

Widget customerInfoCard({
  required String profileImageBase64,
  required String name,
  required String email,
  required String contactNumber,
  required String address,
  bool isMobile = false,
}) {
  // Build profile image widget
  Widget buildProfileImage() {
    if (profileImageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profileImageBase64);
        return CircleAvatar(
          radius: isMobile ? 24 : 28,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: (isMobile ? 24 : 28) * 2,
              height: (isMobile ? 24 : 28) * 2,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to default avatar if image fails to load
                return CircleAvatar(
                  radius: isMobile ? 24 : 28,
                  backgroundColor: Colors.blue[50],
                  child: Icon(
                    Icons.person,
                    size: isMobile ? 24 : 28,
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),
        );
      } catch (e) {
        // Fallback to default avatar if Base64 decoding fails
        return CircleAvatar(
          radius: isMobile ? 24 : 28,
          backgroundColor: Colors.blue[50],
          child: Icon(
            Icons.person,
            size: isMobile ? 24 : 28,
            color: Colors.blue,
          ),
        );
      }
    } else {
      // Default placeholder
      return CircleAvatar(
        radius: isMobile ? 24 : 28,
        backgroundColor: Colors.blue[50],
        child: Icon(
          Icons.person,
          size: isMobile ? 24 : 28,
          color: Colors.blue,
        ),
      );
    }
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.symmetric(
      vertical: isMobile ? 20 : 30,
      horizontal: isMobile ? 20 : 24,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 15 : 16,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          children: [
            buildProfileImage(),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 14 : 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isMobile ? 12 : 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 20 : 28),
        Text(
          'Contact Number',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 15,
          ),
        ),
        SizedBox(height: 8),
        Text(
          contactNumber,
          style: TextStyle(
            color: Colors.grey,
            fontSize: isMobile ? 13 : 14,
          ),
        ),
        SizedBox(height: isMobile ? 20 : 24),
        Text(
          'Delivery Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 15,
          ),
        ),
        SizedBox(height: 8),
        Text(
          address,
          style: TextStyle(
            color: Colors.grey,
            fontSize: isMobile ? 13 : 14,
          ),
        ),
      ],
    ),
  );
}

Widget itemsSummaryCard({
  required List items,
  required String subtotal,
  required String deliveryFee,
  required String total,
  bool isMobile = false,
  bool isTablet = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.symmetric(
      vertical: isMobile ? 20 : (isTablet ? 20 : 24),
      horizontal: isMobile ? 20 : (isTablet ? 24 : 32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : 18,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(item['image']!),
                      width: isMobile ? 50 : (isTablet ? 50 : 56),
                      height: isMobile ? 50 : (isTablet ? 50 : 56),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 13 : (isTablet ? 14 : 15)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.pesoSign,
                        size: isMobile ? 12 : 14,
                      ),
                      Text(
                        item['price']!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : (isTablet ? 14 : 16)),
                      ),
                    ],
                  ),
                ],
              ),
            )),
        SizedBox(height: isMobile ? 12 : 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Subtotal',
                        style: TextStyle(fontSize: isMobile ? 13 : 15)),
                  ),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.pesoSign, size: isMobile ? 12 : 14),
                      Text(subtotal,
                          style: TextStyle(fontSize: isMobile ? 13 : 15)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text('Delivery Fee',
                        style: TextStyle(fontSize: isMobile ? 13 : 15)),
                  ),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.pesoSign, size: isMobile ? 12 : 14),
                      Text(deliveryFee,
                          style: TextStyle(fontSize: isMobile ? 13 : 15)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 15 : 16)),
                  ),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.pesoSign, size: isMobile ? 12 : 14),
                      Text(total,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 15 : 16)),
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
  bool isMobile = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.symmetric(
      vertical: isMobile ? 20 : 24,
      horizontal: isMobile ? 20 : 32,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : 18,
          ),
        ),
        SizedBox(width: isMobile ? 20 : 40),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          child: Image.asset(
            iconAsset,
            width: isMobile ? 24 : 32,
            height: isMobile ? 24 : 32,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: isMobile ? 14 : 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
