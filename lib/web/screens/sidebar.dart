import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  String? storeLogoBase64;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    docId = widget.id;
    user = _auth.currentUser;
    if (widget.role == 'seller') {
      _fetchStoreLogo();
    }
  }

  Future<void> _fetchStoreLogo() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('sellersApplication')
          .doc(user!.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          storeLogoBase64 = data['storeLogoBase64'];
        });
      }
    } catch (e) {
      print('Error fetching store logo: $e');
    }
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
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.role == 'admin' ? "Admin" : "Seller",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(width: 8),
              widget.role == 'seller' &&
                      storeLogoBase64 != null &&
                      storeLogoBase64!.isNotEmpty
                  ? _buildSellerLogoWithMenu(18, true)
                  : CircleAvatar(
                      backgroundColor: Color(0xFF3E6BE0),
                      radius: 18,
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
            ],
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
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/image_3.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                ),
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
              widget.role == 'seller' &&
                      storeLogoBase64 != null &&
                      storeLogoBase64!.isNotEmpty
                  ? _buildSellerLogoWithMenu(isTablet ? 30 : 40, false)
                  : Icon(Icons.person,
                      color: Colors.grey, size: isTablet ? 30 : 40),
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

  Widget _buildSellerLogo(double size) {
    if (storeLogoBase64 == null || storeLogoBase64!.isEmpty) {
      return Icon(Icons.person, color: Colors.grey, size: size);
    }

    try {
      final bytes = base64Decode(storeLogoBase64!);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, color: Colors.grey, size: size);
            },
          ),
        ),
      );
    } catch (e) {
      print('Error decoding store logo: $e');
      return Icon(Icons.person, color: Colors.grey, size: size);
    }
  }

  Widget _buildSellerLogoWithMenu(double size, bool isCircle) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      onSelected: (value) {
        if (value == 'change_logo') {
          _changeStoreLogo();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'change_logo',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: Colors.black87),
              SizedBox(width: 8),
              Text('Change Store Logo'),
            ],
          ),
        ),
      ],
      child: isCircle
          ? CircleAvatar(
              radius: size,
              backgroundColor: Colors.grey.shade200,
              child: _buildSellerLogo(size * 2),
            )
          : _buildSellerLogo(size),
    );
  }

  Future<void> _changeStoreLogo() async {
    if (user == null) return;

    try {
      // Use file picker for web
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.single;

      if (pickedFile.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to read image file. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bytes = pickedFile.bytes!;
      final fileName = pickedFile.name;

      // Validate file extension
      final fileExtension = fileName.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only JPG, PNG, GIF, and WebP images are allowed.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check file size (max 2MB)
      if (bytes.length > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo size too large. Maximum 2MB allowed.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Convert to Base64 and update
      final base64String = base64Encode(bytes);
      await _updateStoreLogo(base64String);
    } catch (e) {
      print('Error picking store logo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick store logo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStoreLogo(String base64String) async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('sellersApplication')
          .doc(user!.uid)
          .update({
        'storeLogoBase64': base64String,
        'updatedAt': DateTime.now(),
      });

      setState(() {
        storeLogoBase64 = base64String;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Store logo updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating store logo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update store logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
