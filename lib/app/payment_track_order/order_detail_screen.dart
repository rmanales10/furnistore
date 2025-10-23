import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/app/firebase_service/firestore_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late FirestoreService _firestoreService;
  Map<String, dynamic> orderDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🚀 OrderDetailScreen initialized with orderId: ${widget.orderId}');
    try {
      _firestoreService = Get.find<FirestoreService>();
    } catch (e) {
      print('❌ FirestoreService not found, creating new instance: $e');
      _firestoreService = FirestoreService();
    }
    _loadOrderDetails();
  }

  // Helper method to clean the order ID
  String _cleanOrderId(String orderId) {
    // Remove "Order #" prefix if present
    if (orderId.startsWith('Order #')) {
      return orderId.substring(7); // Remove "Order #" (7 characters)
    }
    return orderId;
  }

  // Helper method to display peso symbol with FontAwesome
  Widget _buildPesoText(String amount, {TextStyle? style}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          FontAwesomeIcons.pesoSign,
          size: (style?.fontSize ?? 16) * 0.8,
          color: style?.color ?? Colors.black87,
        ),
        const SizedBox(width: 2),
        Text(
          amount,
          style: style,
        ),
      ],
    );
  }

  Future<void> _loadOrderDetails() async {
    try {
      String cleanOrderId = _cleanOrderId(widget.orderId);
      print('🔍 Original orderId: ${widget.orderId}');
      print('🔍 Cleaned orderId: $cleanOrderId');

      // First, let's test if the order exists with a direct query
      QuerySnapshot testQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('order_id', isEqualTo: cleanOrderId)
          .limit(1)
          .get();

      print('🔍 Direct query result: ${testQuery.docs.length} documents found');
      if (testQuery.docs.isNotEmpty) {
        Map<String, dynamic> testData =
            testQuery.docs.first.data() as Map<String, dynamic>;
        print('🔍 Direct query - Order ID: ${testData['order_id']}');
        print('🔍 Direct query - Products: ${testData['products']}');
        print(
            '🔍 Direct query - Products count: ${(testData['products'] as List?)?.length ?? 0}');

        // Test if products are accessible
        if (testData['products'] != null) {
          List<dynamic> testProducts = testData['products'] as List<dynamic>;
          print(
              '🔍 Direct query - First product: ${testProducts.isNotEmpty ? testProducts[0] : 'No products'}');
        }
      } else {
        print('❌ No documents found for order ID: ${widget.orderId}');
        print('🔍 Searching for any orders with similar ID...');

        // Try to find orders with similar ID pattern
        QuerySnapshot similarQuery = await FirebaseFirestore.instance
            .collection('orders')
            .where('order_id', isGreaterThanOrEqualTo: 'FURN-')
            .where('order_id', isLessThan: 'FURN-9999999999999')
            .limit(5)
            .get();

        print('🔍 Similar orders found: ${similarQuery.docs.length}');
        for (var doc in similarQuery.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print('  - ${data['order_id']}');
        }
      }

      // Get order details using FirestoreService
      Map<String, dynamic>? orderData = await _firestoreService.getOrderDetails(
        orderId: cleanOrderId,
      );

      if (orderData != null) {
        print('📦 Order Data Loaded:');
        print('  - Order ID: ${orderData['order_id']}');
        print('  - Status: ${orderData['status']}');
        print('  - User: ${orderData['user_name']}');
        print('  - Email: ${orderData['user_email']}');
        print('  - Address: ${orderData['delivery_address']}');
        print(
            '  - Products Field: ${orderData['products']}'); // Added this line
        print(
            '  - Products Count: ${(orderData['products'] as List?)?.length ?? 0}');
        print('  - Total: ${orderData['total']}');
        print('  - Delivery Fee: ${orderData['delivery_fee']}');

        setState(() {
          orderDetails = orderData;
          isLoading = false;
        });
      } else {
        print(
            '❌ No order data found via service, trying direct Firebase query...');
        await _loadOrderDetailsDirect();
      }
    } catch (e) {
      print('❌ Error with FirestoreService, trying direct Firebase query: $e');
      await _loadOrderDetailsDirect();
    }
  }

  Future<void> _loadOrderDetailsDirect() async {
    try {
      String cleanOrderId = _cleanOrderId(widget.orderId);
      print('🔍 Direct fallback - Cleaned orderId: $cleanOrderId');

      // Direct Firebase query as fallback
      QuerySnapshot orderQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('order_id', isEqualTo: cleanOrderId)
          .limit(1)
          .get();

      if (orderQuery.docs.isNotEmpty) {
        DocumentSnapshot orderDoc = orderQuery.docs.first;
        Map<String, dynamic> orderData =
            orderDoc.data() as Map<String, dynamic>;

        // Get user information for delivery details
        String userId = orderData['user_id'] ?? '';
        Map<String, dynamic> userData = {};

        if (userId.isNotEmpty) {
          try {
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

            if (userDoc.exists) {
              userData = userDoc.data() as Map<String, dynamic>;
            }
          } catch (e) {
            print('Error fetching user data: $e');
          }
        }

        Map<String, dynamic> finalOrderData = {
          ...orderData,
          'user_name':
              userData['name'] ?? userData['username'] ?? 'Unknown User',
          'user_email': userData['email'] ?? 'No email provided',
          'delivery_address': userData['address'] ?? 'No address provided',
          'town_city': userData['town_city'] ?? '',
          'postcode': userData['postcode'] ?? '',
          'phone_number':
              userData['phone_number'] ?? userData['phoneNumber'] ?? '',
        };

        print('📦 Order Data Loaded via Direct Query:');
        print('  - Order ID: ${finalOrderData['order_id']}');
        print('  - Status: ${finalOrderData['status']}');
        print('  - User: ${finalOrderData['user_name']}');
        print('  - Email: ${finalOrderData['user_email']}');
        print('  - Address: ${finalOrderData['delivery_address']}');
        print(
            '  - Products Field: ${finalOrderData['products']}'); // Added this line
        print(
            '  - Products Count: ${(finalOrderData['products'] as List?)?.length ?? 0}');
        print('  - Total: ${finalOrderData['total']}');
        print('  - Delivery Fee: ${finalOrderData['delivery_fee']}');

        setState(() {
          orderDetails = finalOrderData;
          isLoading = false;
        });
      } else {
        print('❌ No order data found for ID: ${widget.orderId}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading order details directly: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Date
                _buildOrderDate(),
                const SizedBox(height: 12),

                // Order Status
                _buildOrderStatus(),
                const SizedBox(height: 24),

                // Products List
                _buildProductsList(),
                const SizedBox(height: 24),

                // Cancel Order Button
                _buildCancelOrderButton(),
                const SizedBox(height: 24),

                // Delivery Information
                _buildDeliveryInfo(),
                const SizedBox(height: 16),

                // Purchase Number
                _buildPurchaseNumber(),
                const SizedBox(height: 16),

                // Payment Information
                _buildPaymentInfo(),
                const SizedBox(height: 16),

                // Order Summary
                _buildOrderSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'My Orders',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildOrderDate() {
    String formattedDate = 'May 03, 2025'; // Default fallback

    try {
      if (orderDetails['date'] != null) {
        if (orderDetails['date'] is Timestamp) {
          Timestamp timestamp = orderDetails['date'] as Timestamp;
          formattedDate =
              DateFormat('MMMM dd, yyyy').format(timestamp.toDate());
        } else if (orderDetails['date'] is String) {
          // Handle string date format from Firebase
          String dateString = orderDetails['date'] as String;
          if (dateString.contains('at')) {
            // Parse Firebase string format: "June 25, 2025 at 1:33:59 PM UTC+8"
            List<String> parts = dateString.split(' at ');
            if (parts.isNotEmpty) {
              formattedDate = parts[0]; // "June 25, 2025"
            }
          }
        }
      }
    } catch (e) {
      print('Error formatting date: $e');
    }

    return Text(
      'Purchased Online - $formattedDate',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildOrderStatus() {
    final status = orderDetails['status'] ?? 'Order confirmed';
    Color statusColor = Colors.green;
    Color backgroundColor = Colors.green.shade50;
    Color borderColor = Colors.green.shade200;

    // Set colors based on status
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade200;
        break;
      case 'processing':
        statusColor = Colors.blue;
        backgroundColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade200;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        backgroundColor = Colors.purple.shade50;
        borderColor = Colors.purple.shade200;
        break;
      case 'delivered':
        statusColor = Colors.green;
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        break;
      default:
        statusColor = Colors.green;
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 14,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    // More robust products extraction
    dynamic productsRaw = orderDetails['products'];
    List<dynamic> products = [];

    if (productsRaw != null) {
      if (productsRaw is List) {
        products = productsRaw;
      } else if (productsRaw is Map) {
        // If it's a Map, try to extract values
        products = productsRaw.values.toList();
      }
    }

    print('🔍 Products raw data: $productsRaw');
    print('🔍 Products type: ${productsRaw.runtimeType}');
    print('🔍 Products in order: ${products.length}');
    for (int i = 0; i < products.length; i++) {
      print('  Product $i: ${products[i]}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (products.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'No items found in this order',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ...products.map((product) => _buildProductItem(product)).toList(),
      ],
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildProductImage(product),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ??
                      product['product_name'] ??
                      'Unknown Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                _buildPesoText(
                  '${(product['price'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size (H ${product['height'] ?? 'N/A'} cm /W ${product['width'] ?? 'N/A'}cm)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (product['quantity'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${product['quantity']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> product) {
    try {
      String base64Image = product['image'] ?? '';
      if (base64Image.isNotEmpty) {
        Uint8List decodedBytes = base64Decode(base64Image);
        return Image.memory(
          decodedBytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      }
    } catch (e) {
      // Handle error
    }

    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  Widget _buildCancelOrderButton() {
    // Only show cancel button if order is not cancelled
    if (orderDetails['status'] == 'Cancelled') {
      return const SizedBox.shrink(); // Hide button for cancelled orders
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showCancelOrderDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Cancel Order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    final deliveryAddress =
        orderDetails['delivery_address'] ?? 'No address provided';
    final userName = orderDetails['user_name'] ?? 'Unknown User';
    final userEmail = orderDetails['user_email'] ?? 'No email provided';
    final townCity = orderDetails['town_city'] ?? '';
    final postcode = orderDetails['postcode'] ?? '';
    final phoneNumber = orderDetails['phone_number'] ?? '';

    // Build full address
    String fullAddress = deliveryAddress;
    if (townCity.isNotEmpty) fullAddress += ', $townCity';
    if (postcode.isNotEmpty) fullAddress += ', $postcode';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Delivery',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildPurchaseNumber() {
    final orderId = orderDetails['order_id'] ?? widget.orderId;

    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Purchase Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Text(
                orderId,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    final paymentMethod = orderDetails['mode_of_payment'] ?? 'Unknown';

    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      paymentMethod,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _getPaymentIcon(paymentMethod),
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'credit card':
        return Icons.credit_card;
      case 'cash on delivery':
        return Icons.money;
      case 'paypal':
        return Icons.payment;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Widget _buildOrderSummary() {
    // Calculate subtotal from products array
    double subtotal = 0.0;
    if (orderDetails['products'] != null) {
      List<dynamic> products = orderDetails['products'] as List<dynamic>;
      for (var product in products) {
        double price = (product['price'] ?? 0).toDouble();
        int quantity = product['quantity'] ?? 1;
        subtotal += price * quantity;
      }
    }

    final delivery = (orderDetails['delivery_fee'] ?? 0.0).toDouble();
    final total = subtotal + delivery;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Subtotal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            _buildPesoText(
              '${subtotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Delivery',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            _buildPesoText(
              '${delivery.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Total',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            _buildPesoText(
              '${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCancelOrderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Want to cancel your order?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'You can cancel orders for a short time after they are placed - free of charge.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Buttons
              Column(
                children: [
                  // Go Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _cancelOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelOrder() async {
    try {
      String cleanOrderId = _cleanOrderId(widget.orderId);
      print('🔍 Cancelling order with cleaned ID: $cleanOrderId');

      // Update order status using FirestoreService
      bool success = await _firestoreService.updateOrderStatus(
        orderId: cleanOrderId,
        newStatus: 'Cancelled',
      );

      if (success) {
        // Update local state
        setState(() {
          orderDetails['status'] = 'Cancelled';
        });

        // Show success confirmation dialog
        _showCancellationSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel order'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error cancelling order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling order: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCancellationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Your order has been cancelled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Good news! Your cancellation has been processed and you won\'t be charged. It can take a few minutes for this page to show your order\'s status updated.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Got It Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to orders list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
