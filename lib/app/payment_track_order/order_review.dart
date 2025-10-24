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
  String selectedDeliveryOption = 'Base Fee'; // Default delivery option
  String paymentMethod = 'Cash on Delivery'; // Default payment method
  int additionalFee = 0;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Order Review',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address
              _buildSectionTitle('Delivery Address'),
              Obx(() {
                _orderController.getUserInfo();
                final userInfo = _orderController.userInfo;
                return _buildEditableRow(
                  '${userInfo['address'] ?? 'Please click edit to enter details '} \n${userInfo['town_city'] ?? ''} \n${userInfo['postcode'] ?? ''} \n${userInfo['phone_number']}',
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
                  return _buildEditableRow('${user['email'] ?? 'Not Set'}',
                      () => Get.to(() => const EditProfileScreen()));
                } else {
                  return _buildEditableRow('Loading user information...',
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
              _buildDropdownPaymentMethod(),
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
        _buildRadioOption('Base Fee', '50 for the first 5 km'),
        _buildRadioOption('Additional Fee', '20 per km beyond 5 km'),
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
            additionalFee = (value == 'Base Fee')
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

  Widget _buildDropdownPaymentMethod() {
    return DropdownButton<String>(
      value: paymentMethod,
      isExpanded: true,
      underline: Container(
        height: 1,
        color: Colors.grey,
      ),
      items: ['Cash on Delivery'].map((String method) {
        return DropdownMenuItem<String>(
          value: method,
          child: Text(
            method,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          paymentMethod = newValue!;
        });
      },
    );
  }

  Widget _buildPriceSummary(int subtotal, int additionalFee, int total) {
    return Column(
      children: [
        _buildPriceRow('Subtotal', subtotal),
        _buildPriceRow('Additional Fee', additionalFee),
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
              if (_orderController.userInfo['address'] == null) {
                return Get.dialog(AlertDialog(
                  backgroundColor: Colors.transparent,
                  content: Text(
                    'Please enter your details to proceed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(.2)),
                      child: Text(
                        'continue',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                  actionsAlignment: MainAxisAlignment.center,
                ));
              }
              Get.dialog(
                Dialog(
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
                                onPressed: () {
                                  _firestore.storeOrderData(
                                      date: DateTime.now(),
                                      modeOfPayment: paymentMethod,
                                      orderId: generateOrderId(),
                                      product: widget.productList,
                                      status: 'Pending',
                                      subTotal: subtotal.value,
                                      total: total,
                                      totalItems: totalItem.value,
                                      userId: _auth.currentUser!.uid,
                                      deliveryFee: additionalFee);
                                  _firestore.deleteCartForCheckout();
                                  Get.back();
                                  _showSuccessDialog(context);
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
