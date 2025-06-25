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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
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
                      icon: Icon(Icons.arrow_back_ios_new_outlined)),
                  Text(
                    "Store Profile",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileRow('Store Name', seller['storeName']),
                      _profileRow('Owner Name', seller['ownerName']),
                      _profileRow('Email / Contact', seller['ownersEmail']),
                      _profileRow('Business Description',
                          seller['businessDescription']),
                      _profileRow(
                        'Status',
                        _statusSwitch(seller['status']),
                      ),
                      _profileRow(
                        'Uploaded Document',
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon:
                              Icon(Icons.insert_drive_file_outlined, size: 18),
                          label: Text('View ID/Permit'),
                          onPressed: () {
                            launchUrl(Uri.parse(seller['file']));
                          },
                        ),
                      ),
                      _profileRow(
                          'Date Applied',
                          seller['updatedAt'] != null
                              ? DateFormat('MMMM d, yyyy')
                                  .format(seller['updatedAt'].toDate())
                              : 'N/A'),
                      _profileRow(
                        'Store Logo',
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blue[50],
                          child: Text('F',
                              style:
                                  TextStyle(fontSize: 22, color: Colors.blue)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: Colors.grey, size: 22),
                          SizedBox(width: 8),
                          Text('Admin Controls',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: TextStyle(fontSize: 15),
                              ),
                              icon: Icon(Icons.check, size: 18),
                              label: Text('Approved'),
                              onPressed:
                                  seller['status'].toLowerCase() == 'pending' ||
                                          seller['status'].toLowerCase() ==
                                              'rejected'
                                      ? () async {
                                          await _controller.updateSellerStatus(
                                              widget.id, 'Approved', '');
                                        }
                                      : null, // Disabled
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                foregroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                textStyle: TextStyle(fontSize: 15),
                              ),
                              icon: Icon(Icons.close, size: 18),
                              label: Text('Reject Application'),
                              onPressed:
                                  seller['status'].toLowerCase() == 'pending' ||
                                          seller['status'].toLowerCase() ==
                                              'approved'
                                      ? () async {
                                          _showRejectDialog(context, widget.id);
                                        }
                                      : null,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: BorderSide(color: Colors.red.shade200),
                                textStyle: TextStyle(fontSize: 15),
                              ),
                              icon: Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red),
                              label: Text('Delete Seller',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {},
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

  Widget _statusSwitch(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Text(status, style: TextStyle(color: Colors.black)),
            ],
          ),
        );
      case 'rejected':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, color: Colors.red, size: 18),
              SizedBox(width: 6),
              Text(status, style: TextStyle(color: Colors.black)),
            ],
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pending_actions, color: Colors.yellow, size: 18),
              SizedBox(width: 6),
              Text(status, style: TextStyle(color: Colors.black)),
            ],
          ),
        );
    }
  }

  Widget _profileRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          SizedBox(
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
