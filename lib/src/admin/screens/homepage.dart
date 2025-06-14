import 'package:flutter/material.dart';
import 'package:furnistore/src/admin/auth_screen/login.dart';
import 'package:furnistore/src/admin/screens/activity_log/activitylog.dart';
import 'package:furnistore/src/admin/screens/dashboard/dashboard.dart';
import 'package:furnistore/src/admin/screens/orders/orders.dart';
import 'package:furnistore/src/admin/screens/products/products.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final revenues = [
    5000,
    2500,
    1750,
    2250,
    4000,
    4500,
    1500,
    2000,
    1250,
    5000,
    3750,
    2750
  ];

  final profitMargins = [
    20.0,
    10.0,
    16.0,
    12.0,
    18.0,
    10.0,
    8.0,
    14.0,
    16.0,
    20.0,
    9.0,
    7.0
  ];

  int selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardContent(),
    const ProductPage(),
    const Orders(),
    ActivityLogScreen(),
    const Center(
        child: Text("Other Content")), // Placeholder for additional pages
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 120, // Set height for AppBar
          titleSpacing: 0, // Remove default spacing
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(
                left: 30, right: 100), // Add 100px padding on both sides
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
                ]),
          )),
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          // Main Content
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}

// Sidebar Widget
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          SidebarItem(
            title: "Dashboard",
            icon: Icons.dashboard,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          SidebarItem(
            title: "Products",
            icon: Icons.category,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          SidebarItem(
            title: "Orders",
            icon: Icons.shopping_cart,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          SidebarItem(
            title: "Activity Log",
            icon: Icons.event_note_sharp,
            isSelected: selectedIndex == 3,
            onTap: () => onItemSelected(3),
          ),
          const Spacer(),
          SidebarItem(
            title: "Logout",
            icon: Icons.logout,
            isSelected: false,
            onTap: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Show Logout Confirmation Dialog
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

// Sidebar Item Widget
class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

// Dashboard Content

