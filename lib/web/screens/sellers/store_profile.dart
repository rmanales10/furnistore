import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnistore/web/screens/sellers/seller_controller.dart';
import 'package:furnistore/web/screens/sidebar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreProfile extends StatefulWidget {
  final String id;
  const StoreProfile({super.key, required this.id});

  @override
  State<StoreProfile> createState() => _StoreProfileState();
}

class _StoreProfileState extends State<StoreProfile> {
  final _controller = Get.put(SellerController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : (isTablet ? 24 : 100),
          vertical: isMobile ? 16 : 20,
        ),
        child: Obx(() {
          _controller.fetchSellersStatus(widget.id);

          final seller = _controller.sellersStatus;
          if (seller.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Sidebar(
                                    role: 'admin',
                                    initialIndex: 2,
                                  ))),
                      icon: Icon(Icons.arrow_back_ios_new_outlined,
                          size: isMobile ? 18 : 24)),
                  SizedBox(width: isMobile ? 4 : 0),
                  Expanded(
                    child: Text(
                      "Store Profile",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : (isTablet ? 26 : 30),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 15),
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                  boxShadow: isMobile
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isTablet ? 24 : 40),
                    vertical: isMobile ? 20 : 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Store Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      _profileRow('Store Name', seller['storeName'], isMobile),
                      if (isMobile) Divider(height: 20),
                      _profileRow('Owner Name', seller['ownerName'], isMobile),
                      if (isMobile) Divider(height: 20),
                      _profileRow(
                          'Email / Contact', seller['ownersEmail'], isMobile),
                      if (isMobile) Divider(height: 20),
                      _profileRow('Business Description',
                          seller['businessDescription'], isMobile),
                      if (isMobile) Divider(height: 20),
                      _profileRow(
                        'Status',
                        _statusSwitch(seller['status']),
                        isMobile,
                      ),
                      if (isMobile) Divider(height: 20),
                      _profileRow(
                        'Uploaded Document',
                        SizedBox(
                          width: isMobile ? double.infinity : null,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: isMobile ? 12 : 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(Icons.insert_drive_file_outlined,
                                size: 18),
                            label: Text('View ID/Permit',
                                style: TextStyle(fontSize: 14)),
                            onPressed: () {
                              launchUrl(Uri.parse(seller['file']));
                            },
                          ),
                        ),
                        isMobile,
                      ),
                      if (isMobile) Divider(height: 20),
                      _profileRow(
                          'Date Applied',
                          seller['updatedAt'] != null
                              ? DateFormat('MMMM d, yyyy')
                                  .format(seller['updatedAt'].toDate())
                              : 'N/A',
                          isMobile),
                      if (isMobile) Divider(height: 20),
                      _profileRow(
                        'Store Logo',
                        _buildStoreLogo(seller['storeLogoBase64']),
                        isMobile,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 20 : 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 15),
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                  boxShadow: isMobile
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isTablet ? 24 : 30),
                    vertical: isMobile ? 20 : 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings,
                              color: Colors.grey.shade700,
                              size: isMobile ? 20 : 22),
                          SizedBox(width: isMobile ? 8 : 8),
                          Text('Admin Controls',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 16 : 18)),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      textStyle: TextStyle(fontSize: 13),
                                    ),
                                    icon: Icon(Icons.check, size: 16),
                                    label: Text('Approved'),
                                    onPressed: seller['status'].toLowerCase() ==
                                                'pending' ||
                                            seller['status'].toLowerCase() ==
                                                'rejected'
                                        ? () async {
                                            await _controller
                                                .updateSellerStatus(
                                                    widget.id, 'Approved', '');
                                          }
                                        : null,
                                  ),
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade100,
                                      foregroundColor: Colors.red,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      textStyle: TextStyle(fontSize: 13),
                                    ),
                                    icon: Icon(Icons.close, size: 16),
                                    label: Text('Reject Application'),
                                    onPressed: seller['status'].toLowerCase() ==
                                                'pending' ||
                                            seller['status'].toLowerCase() ==
                                                'approved'
                                        ? () async {
                                            _showRejectDialog(
                                                context, widget.id);
                                          }
                                        : null,
                                  ),
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: BorderSide(
                                          color: Colors.red.shade200),
                                      textStyle: TextStyle(fontSize: 13),
                                    ),
                                    icon: Icon(Icons.delete_outline,
                                        size: 16, color: Colors.red),
                                    label: Text('Delete Seller',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      _showDeleteDialog(context, widget.id);
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      textStyle: TextStyle(
                                          fontSize: isTablet ? 13 : 15),
                                    ),
                                    icon: Icon(Icons.check,
                                        size: isTablet ? 16 : 18),
                                    label: Text('Approved'),
                                    onPressed: seller['status'].toLowerCase() ==
                                                'pending' ||
                                            seller['status'].toLowerCase() ==
                                                'rejected'
                                        ? () async {
                                            await _controller
                                                .updateSellerStatus(
                                                    widget.id, 'Approved', '');
                                          }
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade100,
                                      foregroundColor: Colors.red,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      textStyle: TextStyle(
                                          fontSize: isTablet ? 13 : 15),
                                    ),
                                    icon: Icon(Icons.close,
                                        size: isTablet ? 16 : 18),
                                    label: Text('Reject Application'),
                                    onPressed: seller['status'].toLowerCase() ==
                                                'pending' ||
                                            seller['status'].toLowerCase() ==
                                                'approved'
                                        ? () async {
                                            _showRejectDialog(
                                                context, widget.id);
                                          }
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: BorderSide(
                                          color: Colors.red.shade200),
                                      textStyle: TextStyle(
                                          fontSize: isTablet ? 13 : 15),
                                    ),
                                    icon: Icon(Icons.delete_outline,
                                        size: isTablet ? 16 : 18,
                                        color: Colors.red),
                                    label: Text('Delete Seller',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      _showDeleteDialog(context, widget.id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String id) {
    final TextEditingController reasonController = TextEditingController();
    bool notifyByEmail = true;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    radius: 24,
                    child: Icon(Icons.close, color: Colors.red, size: 28),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reject Seller Application',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Please provide a reason for rejecting this application.'),
                  SizedBox(height: 18),
                  Text('Reason for Rejection',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      hintText: 'Enter reason...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: notifyByEmail,
                        onChanged: (val) =>
                            setState(() => notifyByEmail = val ?? true),
                      ),
                      Expanded(
                          child: Text(
                              'Notify the seller via email about this reason')),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _controller.updateSellerStatus(
                        id, 'Rejected', reasonController.text);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Reject Seller',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade100,
                radius: 24,
                child: Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 28),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Seller',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this seller?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action will:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.red.shade900),
                    ),
                    SizedBox(height: 8),
                    _deleteBulletPoint(
                        '• Delete all products listed by this seller'),
                    _deleteBulletPoint('• Remove seller application'),
                    _deleteBulletPoint('• Revoke seller access'),
                    SizedBox(height: 8),
                    Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.red.shade900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(100, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Show loading dialog
                Navigator.of(context).pop(); // Close confirmation dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Deleting seller...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                // Delete seller
                final success = await _controller.deleteSeller(id);

                // Close loading dialog
                Navigator.of(context).pop();

                // Show result and navigate
                if (success) {
                  // Navigate back to sellers list first
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Sidebar(
                        role: 'admin',
                        initialIndex: 2, // SellerScreen index
                      ),
                    ),
                    (route) => false, // Remove all previous routes
                  );

                  // Show success message after navigation
                  Future.delayed(Duration(milliseconds: 300), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Seller deleted successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed to delete seller. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(100, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete Seller',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _deleteBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.red.shade900),
      ),
    );
  }

  Widget _statusSwitch(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Colors.green, size: 16),
              SizedBox(width: 6),
              Text(status,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      case 'rejected':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, color: Colors.red, size: 16),
              SizedBox(width: 6),
              Text(status,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pending_actions, color: Colors.orange, size: 16),
              SizedBox(width: 6),
              Text(status,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
    }
  }

  Widget _buildStoreLogo(String? storeLogoBase64) {
    if (storeLogoBase64 == null || storeLogoBase64.isEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.blue[50],
        child: Text('F', style: TextStyle(fontSize: 22, color: Colors.blue)),
      );
    }

    try {
      // Decode the Base64 string to bytes
      final bytes = base64Decode(storeLogoBase64);

      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.memory(
            gaplessPlayback: true,
            bytes,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to default avatar if image fails to load
              return CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue[50],
                child: Text('F',
                    style: TextStyle(fontSize: 22, color: Colors.blue)),
              );
            },
          ),
        ),
      );
    } catch (e) {
      // Fallback to default avatar if Base64 decoding fails
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.blue[50],
        child: Text('F', style: TextStyle(fontSize: 22, color: Colors.blue)),
      );
    }
  }

  Widget _profileRow(String label, dynamic value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 6),
                value is Widget
                    ? value
                    : Text(
                        value,
                        style: TextStyle(fontSize: 14),
                      ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: value is Widget
                      ? value
                      : Text(
                          value,
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
    );
  }
}
