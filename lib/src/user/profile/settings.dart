import 'package:flutter/material.dart';
import 'package:furnistore/src/user/firebase_service/auth_service.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/login.dart';
import 'package:get/get.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _auth = Get.put(AuthService());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Personal Section
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

            // Profile Tile
            _buildListTile(() {
              Navigator.pushNamed(
                  context, '/editprof'); // Navigate to Edit Profile Screen
            }, 'Profile'),
            const Divider(),

            // Delivery Address Tile
            _buildListTile(() {
              Navigator.pushNamed(
                  context, '/adrress'); // Navigate to Delivery Address
            }, 'Delivery Address'),
            const Divider(),

            // My Orders Tile
            _buildListTile(() {
              Navigator.pushNamed(context, '/track'); // Navigate to My Orders
            }, 'My Orders'),
            const Divider(),

            // Account Section
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

            // About FurniStore Tile
            _buildListTile(() {
              Navigator.pushNamed(
                  context, '/about'); // Navigate to About FurniStore
            }, 'About FurniStore'),
            const Divider(),

            const Spacer(),

            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

  // Helper method for list tiles
  Widget _buildListTile(VoidCallback onTap, String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: onTap, // Use the passed onTap function
    );
  }

  // Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 40), // Controls the overall width
          title: const Text(
            'Are you sure you want to Logout?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween, // Aligns buttons
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('No'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _auth.signOut();
                        Get.offAll(() => LoginScreen());
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
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
