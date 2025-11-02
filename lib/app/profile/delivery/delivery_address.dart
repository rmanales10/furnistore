import 'package:flutter/material.dart';
import 'package:furnistore/app/profile/delivery/delivery_address_controller.dart';

import 'package:get/get.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _controller = Get.put(DeliveryAddressController());

  // Removed the .obs
  final address = TextEditingController();
  final townCity = TextEditingController();
  final postcode = TextEditingController();
  final phoneNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDelivery();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.deliveryAddress.isEmpty) {
      _controller.getDeliveryAddress();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar in body
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Text(
                    'Profile Settings',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Country Field
                    const Text('Country',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('Philippines',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    const SizedBox(height: 16),

                    const Text('Address',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildTextField(address),

                    const Text('Town / City',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildTextField(townCity),

                    const Text('Postcode',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildTextField(postcode),

                    const Text('Phone Number',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildTextField(phoneNumber),

                    const SizedBox(
                        height: 20), // Add extra space before the button

                    // Save Changes Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          saveChanges();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3E6BE0),
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a text field
  Widget _buildTextField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller:
            controller, // Using the controller directly, not controller.value
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void saveChanges() async {
    // Set updated delivery address in the controller
    await _controller.setDeliveryAddress(
        address: address.text,
        townCity: townCity.text,
        postcode: postcode.text,
        phoneNumber: phoneNumber.text);
    Get.snackbar('Success', 'Delivery address saved successfully!');
  }

  Future<void> initDelivery() async {
    await _controller.getDeliveryAddress();
    // Initialize the TextEditingControllers with user info from the controller
    setState(() {
      address.text = _controller.deliveryAddress['address'] ?? '';
      townCity.text = _controller.deliveryAddress['town_city'] ?? '';
      postcode.text = _controller.deliveryAddress['postcode'] ?? '';
      phoneNumber.text = _controller.deliveryAddress['phone_number'] ?? '';
    });
  }
}
