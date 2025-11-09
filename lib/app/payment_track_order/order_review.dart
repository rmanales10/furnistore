import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/app/firebase_service/firestore_service.dart';
import 'package:furnistore/app/payment_track_order/order_controller.dart';
import 'package:furnistore/app/payment_track_order/payment_successful.dart';
import 'package:furnistore/app/profile/delivery/delivery_address.dart';
import 'package:furnistore/app/profile/edit_profile/edit_profile.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderReviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> productList;

  const OrderReviewScreen({super.key, required this.productList});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  String selectedDeliveryOption = ''; // Default delivery option
  String paymentMethod = 'Cash on Delivery'; // Default payment method
  int additionalFee = 100; // Default delivery fee
  final _orderController = Get.put(OrderController());
  final _firestore = Get.put(FirestoreService());
  final _auth = FirebaseAuth.instance;
  final totalItem = 0.obs;
  final subtotal = 0.obs;

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

  // Method to place the order
  Future<void> _placeOrder() async {
    try {
      await _firestore.storeOrderData(
        date: DateTime.now(),
        modeOfPayment: paymentMethod,
        orderId: generateOrderId(),
        product: widget.productList,
        status: 'Pending',
        subTotal: subtotal.value,
        total: subtotal.value + additionalFee,
        totalItems: totalItem.value,
        userId: _auth.currentUser!.uid,
        deliveryFee: additionalFee,
      );
      await _firestore.deleteCartForCheckout();
      Get.back();
      _showSuccessDialog(context);
    } catch (e) {
      log('❌ Error placing order: $e');
      Get.snackbar(
        'Error',
        'Failed to place order. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    subtotal.value = widget.productList.fold(0, (sum, item) {
      return sum + (item['price'] as int) * (item['quantity'] as int);
    });

    totalItem.value = widget.productList
        .fold(0, (sum, item) => sum + (item['quantity'] as int));

    int total = subtotal.value + additionalFee;
    _firestore.getUserCartInfo();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar in body
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Order Review',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery Address
                      _buildSectionTitle('Delivery Address'),
                      Obx(() {
                        _orderController.getUserInfo();
                        final userInfo = _orderController.userInfo;

                        // Build address string properly handling null values
                        String addressText = '';
                        final address = userInfo['address'];
                        final townCity = userInfo['town_city'];
                        final postcode = userInfo['postcode'];
                        final phoneNumber = userInfo['phone_number'];

                        // Check if address is null or empty
                        if (address == null ||
                            address.toString().trim().isEmpty ||
                            address.toString().toLowerCase() == 'null') {
                          addressText = 'Please click edit to enter details';
                        } else {
                          // Build address string with available fields
                          List<String> addressParts = [];

                          if (address != null &&
                              address.toString().trim().isNotEmpty &&
                              address.toString().toLowerCase() != 'null') {
                            addressParts.add(address.toString().trim());
                          }
                          if (townCity != null &&
                              townCity.toString().trim().isNotEmpty &&
                              townCity.toString().toLowerCase() != 'null') {
                            addressParts.add(townCity.toString().trim());
                          }
                          if (postcode != null &&
                              postcode.toString().trim().isNotEmpty &&
                              postcode.toString().toLowerCase() != 'null') {
                            addressParts.add(postcode.toString().trim());
                          }
                          if (phoneNumber != null &&
                              phoneNumber.toString().trim().isNotEmpty &&
                              phoneNumber.toString().toLowerCase() != 'null') {
                            addressParts.add(phoneNumber.toString().trim());
                          }

                          if (addressParts.isEmpty) {
                            addressText = 'Please click edit to enter details';
                          } else {
                            addressText = addressParts.join('\n');
                          }
                        }

                        return _buildEditableRow(
                          addressText,
                          () => Get.to(() => const DeliveryAddressScreen()),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Contact Information
                      _buildSectionTitle('Contact Information'),
                      Obx(() {
                        _orderController.getUserInfo();
                        if (_orderController.userInfo.isNotEmpty) {
                          final user =
                              _orderController.userInfo; // Access the user data
                          return _buildEditableRow(
                              '${user['email'] ?? 'Not Set'}',
                              () => Get.to(() => const EditProfileScreen()));
                        } else {
                          return _buildEditableRow(
                              'Loading user information...',
                              () => Get.to(() => const EditProfileScreen()));
                        }
                      }),

                      const SizedBox(height: 16),

                      // Items
                      _buildSectionTitle('Items'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.productList.length,
                        itemBuilder: (context, index) {
                          final product = widget.productList[index];

                          return _buildCartItem(
                            product['name'],
                            product['price'].toString(),
                            product['image'],
                            product['quantity'],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Delivery Options
                      _buildSectionTitle('Delivery'),
                      _buildDeliveryOptions(),
                      const SizedBox(height: 16),

                      // Payment Method
                      _buildSectionTitle('Payment Method'),
                      _buildPaymentMethodDisplay(),
                      const SizedBox(height: 16),

                      // Subtotal and Total
                      _buildPriceSummary(subtotal.value, additionalFee, total),

                      // Pay Button
                      const SizedBox(height: 20),
                      _buildPayButton(total),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEditableRow(String text, VoidCallback onTap) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            height: 1.5,
          ),
        ),
        const Spacer(),
        IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.edit,
              color: Color.fromARGB(255, 27, 108, 174),
            )),
      ],
    );
  }

  Widget _buildCartItem(
      String title, String price, String imageBase64, int quantity) {
    Uint8List imageBytes = Uint8List(0); // Default empty image
    try {
      imageBytes = base64Decode(imageBase64);
    } catch (e) {
      log("Error decoding base64: $e");
    }

    return Row(
      children: [
        // Use `Image.memory` to render the image:
        Image.memory(
          imageBytes,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$title (x$quantity)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        _buildPesoText(
          price,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDeliveryOptions() {
    return Column(
      children: [
        _buildRadioOption('Delivery Fee', '100'),
        // _buildRadioOption('Additional Fee', '20 per km beyond 5 km'),
      ],
    );
  }

  Widget _buildRadioOption(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<String>(
        activeColor: const Color(0xFF3E6BE0),
        value: title,
        groupValue: selectedDeliveryOption,
        onChanged: (value) {
          setState(() {
            selectedDeliveryOption = value!;
            additionalFee = (value == 'Delivery Fee')
                ? 100
                : (value == 'Base Fee')
                    ? 50
                    : (value == 'Additional Fee')
                        ? 20
                        : 0;
          });
        },
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.pesoSign,
            size: 10,
            color: Colors.grey,
          ),
          const SizedBox(width: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodDisplay() {
    return Text(
      paymentMethod,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }

  Widget _buildPriceSummary(int subtotal, int additionalFee, int total) {
    return Column(
      children: [
        _buildPriceRow('Subtotal', subtotal),
        _buildPriceRow('Delivery Fee', additionalFee),
        const Divider(height: 24, thickness: 1),
        _buildPriceRow(
          'Total',
          total,
          isBold: true,
          fontSize: 18,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, int amount,
      {bool isBold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        _buildPesoText(
          amount.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF3E6BE0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Total  ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPesoText(
                total.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              // Check if address is null, empty, or the string "null"
              final address = _orderController.userInfo['address'];
              final isAddressValid = address != null &&
                  address.toString().trim().isNotEmpty &&
                  address.toString().toLowerCase() != 'null';

              if (!isAddressValid) {
                return Get.dialog(
                  Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Info Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E6BE0).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 40,
                              color: const Color(0xFF3E6BE0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            'Delivery Address Required',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Message
                          Text(
                            'Please enter your delivery address details to proceed with your order.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Buttons
                          Row(
                            children: [
                              // Cancel Button
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Get.back(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Go to Address Button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.to(() => const DeliveryAddressScreen());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3E6BE0),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Enter Address',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              // Validate delivery option is selected
              if (selectedDeliveryOption.isEmpty ||
                  selectedDeliveryOption == '') {
                return Get.dialog(
                  Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Warning Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              size: 40,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            'Delivery Option Required',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Message
                          Text(
                            'Please select a delivery option before placing your order.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // OK Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3E6BE0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: Colors.white,
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
              Get.dialog(
                Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Total Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            _buildPesoText(
                              total.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Place Order Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Validate stock availability before placing order
                                  final stockValidation = await _firestore
                                      .validateStockAvailability(
                                          widget.productList);

                                  if (!stockValidation['isValid']) {
                                    // Show error dialog if stock validation fails
                                    Get.dialog(
                                      AlertDialog(
                                        title: Text('Stock Unavailable'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'The following items are not available:'),
                                            SizedBox(height: 10),
                                            ...stockValidation['errors']
                                                .map<Widget>((error) => Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: Text('• $error',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ))
                                                .toList(),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }

                                  // Show warnings if any
                                  if (stockValidation['warnings'].isNotEmpty) {
                                    Get.dialog(
                                      Dialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Warning Icon
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade50,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 40,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Title
                                              const Text(
                                                'Stock Warning',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Subtitle
                                              Text(
                                                'Please note:',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Warning List Container
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color:
                                                        Colors.orange.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ...stockValidation[
                                                            'warnings']
                                                        .map<Widget>(
                                                            (warning) =>
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              8),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .info_outline,
                                                                        size:
                                                                            18,
                                                                        color: Colors
                                                                            .orange
                                                                            .shade700,
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          warning,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            color:
                                                                                Colors.orange.shade900,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            height:
                                                                                1.4,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ))
                                                        .toList(),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              // Buttons
                                              Row(
                                                children: [
                                                  // Cancel Button
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          Get.back(),
                                                      style:
                                                          TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 14),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          side: BorderSide(
                                                            color: Colors
                                                                .grey.shade300,
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  // Continue Button
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Get.back();
                                                        _placeOrder();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xFF3E6BE0),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 14),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        elevation: 0,
                                                      ),
                                                      child: const Text(
                                                        'Continue',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // Place order if no warnings
                                  _placeOrder();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3E6BE0),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Place Order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Place Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Placed!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Wait 1.5 seconds, then navigate to another screen
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.back(); // Close the dialog
      Get.off(() => const PaymentSuccessScreen());
    });
  }

  String generateOrderId() {
    return "FURN-${DateTime.now().millisecondsSinceEpoch}";
  }
}
