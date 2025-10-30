import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/web/screens/dashboard/admin_dashboard.dart';
import 'package:furnistore/web/screens/dashboard/seller_dashboard.dart';
import 'package:furnistore/web/screens/orders/orders.dart';
import 'package:furnistore/web/screens/orders/orders_information.dart';
import 'package:furnistore/web/screens/products/add_product.dart';
import 'package:furnistore/web/screens/products/products.dart';
import 'package:furnistore/web/screens/sellers/seller_screen.dart';
import 'package:furnistore/web/screens/sellers/store_profile.dart';

class Sidebar extends StatefulWidget {
  final String role;
  final int initialIndex;
  final String id;
  final String orderId;
  const Sidebar(
      {super.key,
      this.role = '',
      this.initialIndex = 0,
      this.id = '',
      this.orderId = ''});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final _auth = FirebaseAuth.instance;
  User? user;
  int selectedIndex = 0;
  String docId = '';

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    docId = widget.id;
    user = _auth.currentUser;
  }

  List<Widget> get _pages => [
        AdminDashboard(),
        SellerDashboard(),
        SellerScreen(),
        StoreProfile(id: docId),
        ProductPage(),
        Orders(),
        AddProductPage(),
        OrdersInformation(orderId: widget.orderId),
      ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final bool isTablet = MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: isMobile ? _buildMobileAppBar(context) : null,
      drawer: isMobile ? _buildDrawer(context) : null,
      body: Column(
        children: [
          // Header Section for desktop/tablet
          if (!isMobile) _buildHeader(context, isTablet),

          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Sidebar for desktop/tablet only
                if (!isMobile) _buildSidebar(context, isTablet),

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

  // Mobile AppBar with hamburger menu
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Image.asset(
        'assets/image_3.png',
        height: 40,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFF3E6BE0),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // Mobile Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF3E6BE0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Color(0xFF3E6BE0)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.role == 'admin' ? "Admin" : "Seller",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.role == 'admin'
                  ? _adminDrawerItems()
                  : _sellerDrawerItems(),
            ),
            Divider(),
            _drawerItem(
              title: "Logout",
              icon: Icons.logout,
              isSelected: false,
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showLogoutConfirmation(context);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _adminDrawerItems() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _drawerItem(
          title: "Dashboard",
          icon: Icons.dashboard,
          isSelected: selectedIndex == 0,
          onTap: () {
            setState(() => selectedIndex = 0);
            Navigator.pop(context); // Close drawer
          },
        ),
        _drawerItem(
          title: "Sellers",
          icon: Icons.group,
          isSelected: selectedIndex == 2,
          onTap: () {
            setState(() => selectedIndex = 2);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _sellerDrawerItems() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _drawerItem(
          title: "Dashboard",
          icon: Icons.dashboard,
          isSelected: selectedIndex == 1,
          onTap: () {
            setState(() => selectedIndex = 1);
            Navigator.pop(context);
          },
        ),
        _drawerItem(
          title: "Products",
          icon: Icons.category,
          isSelected: selectedIndex == 4,
          onTap: () {
            setState(() => selectedIndex = 4);
            Navigator.pop(context);
          },
        ),
        _drawerItem(
          title: "Orders",
          icon: Icons.shopping_cart,
          isSelected: selectedIndex == 5,
          onTap: () {
            setState(() => selectedIndex = 5);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _drawerItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? const Color(0xFF3E6BE0) : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF3E6BE0) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Color(0xFF3E6BE0).withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Container(
      height: isTablet ? 70 : 90,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 30,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(
            'assets/image_3.png',
            height: isTablet ? 50 : 70,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey, size: isTablet ? 30 : 40),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.role == 'admin' ? "Admin" : "Seller",
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: isTablet ? 10 : 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isTablet) {
    return Container(
      width: isTablet ? 180 : 200,
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
          isSelected: selectedIndex == 1,
          onTap: () => setState(() => selectedIndex = 1),
        ),
        _sidebarItem(
          title: "Products",
          icon: Icons.category,
          isSelected: selectedIndex == 4,
          onTap: () => setState(() => selectedIndex = 4),
        ),
        _sidebarItem(
          title: "Orders",
          icon: Icons.shopping_cart,
          isSelected: selectedIndex == 5,
          onTap: () => setState(() => selectedIndex = 5),
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
      leading: Icon(icon,
          color: isSelected ? const Color(0xFF3E6BE0) : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF3E6BE0) : Colors.black,
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
                      color: const Color(0xFF3E6BE0),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      _auth.signOut();
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/');
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
