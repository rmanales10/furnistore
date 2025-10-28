import 'package:flutter/material.dart';
import 'package:furnistore/app/auth/login/login.dart';
import 'package:furnistore/app/payment_track_order/order_screen.dart';
import 'package:furnistore/app/profile/apply/apply.dart';
import 'package:furnistore/app/profile/apply/apply_controller.dart';
import 'package:furnistore/app/profile/apply/seller_status.dart';
import 'package:furnistore/app/profile/terms.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ApplyController controller = Get.put(ApplyController());
  @override
  void initState() {
    super.initState();
    controller.getSellerStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Profile Settings',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Personal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildListTile(() {
              Navigator.pushNamed(context, '/editprof');
            }, 'Profile'),
            const Divider(),
            _buildListTile(() {
              Navigator.pushNamed(context, '/adrress');
            }, 'Delivery Address'),
            const Divider(),
            _buildListTile(() {
              Get.to(() => OrdersScreen());
            }, 'My Orders'),
            const Divider(),
            _buildListTile(() {
              Get.to(() => controller.sellerStatus.value?['status'] != null
                  ? SellerStatusScreen()
                  : ApplyAsSellerScreen());
            }, 'Apply as a Seller'),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildListTile(() {
              Navigator.pushNamed(context, '/about');
            }, 'About FurniStore'),
            const Divider(),
            _buildListTile(() {
              Get.to(() => Terms());
            }, 'Terms and Conditions'),
            const Divider(),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E6BE0),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(VoidCallback onTap, String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: onTap,
    );
  }

  Future<void> _logoutUser() async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;

      // Update user's status to offline
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'status': 'offline',
        });
      }

      // Sign out the user
      await _firebaseAuth.signOut(); // FirebaseAuth instance used for sign-out
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          title: const Text(
            'Are you sure you want to Logout?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('No'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close the dialog
                        await _logoutUser(); // Logout user
                        Get.offAll(() =>
                            const LoginScreen()); // Navigate to LoginScreen
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
