import 'package:flutter/material.dart';
import 'package:furnistore/src/web/auth_screen/login.dart';
import 'package:furnistore/src/web/screens/activity_log/activitylog.dart';
import 'package:furnistore/src/web/screens/dashboard/admin_dashboard.dart';
import 'package:furnistore/src/web/screens/dashboard/seller_dashboard.dart';
import 'package:furnistore/src/web/screens/orders/orders.dart';
import 'package:furnistore/src/web/screens/products/product.dart';
import 'package:furnistore/src/web/screens/products/products.dart';
import 'package:furnistore/src/web/screens/sellers/seller_screen.dart';
import 'package:furnistore/src/web/screens/sellers/store_profile.dart';

class Sidebar extends StatefulWidget {
  final String role;
  final int initialIndex;
  final String id;
  const Sidebar(
      {super.key, required this.role, this.initialIndex = 0, this.id = ''});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selectedIndex = 0;
  String docId = '';
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    docId = widget.id;
  }

  List<Widget> get _pages => [
        AdminDashboard(),
        SellerDashboard(),
        SellerScreen(),
        StoreProfile(id: docId),
        Product(),
        Orders(),
        ActivityLogScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header Section (moved from AppBar)
          Container(
            height: 90,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 30, right: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Image.asset(
                  'assets/image_3.png',
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                // const Icon(CupertinoIcons.bell, color: Colors.black),
                const SizedBox(width: 20),
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/no_profile.webp',
                        height: 50,
                        width: 50,
                      ), // Status dot color
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Admin",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "elsiemry@gmail.com",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Sidebar (now as a private widget method)
                _buildSidebar(context),

                // Main Content
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.white,
      child: widget.role == 'admin' ? adminSidebar() : sellerSidebar(),
    );
  }

  Widget adminSidebar() {
    return Column(
      children: [
        _sidebarItem(
          title: "Dashboard",
          icon: Icons.dashboard,
          isSelected: selectedIndex == 0,
          onTap: () => setState(() => selectedIndex = 0),
        ),
        _sidebarItem(
          title: "Sellers",
          icon: Icons.group,
          isSelected: selectedIndex == 2,
          onTap: () => setState(() => selectedIndex = 2),
        ),
        const Spacer(),
        _sidebarItem(
          title: "Logout",
          icon: Icons.logout,
          isSelected: false,
          onTap: () => _showLogoutConfirmation(context),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget sellerSidebar() {
    return Column(
      children: [
        _sidebarItem(
          title: "Dashboard",
          icon: Icons.dashboard,
          isSelected: selectedIndex == 0,
          onTap: () => setState(() => selectedIndex = 0),
        ),
        _sidebarItem(
          title: "Products",
          icon: Icons.category,
          isSelected: selectedIndex == 1,
          onTap: () => setState(() => selectedIndex = 1),
        ),
        _sidebarItem(
          title: "Orders",
          icon: Icons.shopping_cart,
          isSelected: selectedIndex == 2,
          onTap: () => setState(() => selectedIndex = 2),
        ),
        _sidebarItem(
          title: "Activity Log",
          icon: Icons.event_note_sharp,
          isSelected: selectedIndex == 3,
          onTap: () => setState(() => selectedIndex = 3),
        ),
        const Spacer(),
        _sidebarItem(
          title: "Logout",
          icon: Icons.logout,
          isSelected: false,
          onTap: () => _showLogoutConfirmation(context),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _sidebarItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout Confirmation"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyLogin(),
                        ),
                      ); // Navigate to the login screen
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Dashboard Content
