import 'package:flutter/material.dart';
import 'package:furnistore/web/screens/sellers/seller_controller.dart';
import 'package:furnistore/web/screens/sidebar.dart';
import 'package:get/get.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _controller = Get.put(SellerController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 100),
        vertical: isMobile ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seller Accounts",
            style: TextStyle(
              fontSize: isMobile ? 24 : (isTablet ? 26 : 30),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Manage seller applications and accounts",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusDirectional.circular(15),
                border: Border.all(width: 1, color: Colors.grey)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  margin: EdgeInsets.only(left: isMobile ? 12 : 20),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: isMobile ? 16 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search Sellers',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : (isTablet ? 40 : 100),
                    vertical: isMobile ? 12 : 20,
                  ),
                  child: Obx(() {
                    _controller.fetchSellers();

                    if (isMobile) {
                      // Mobile Card View
                      return Column(
                        children: _controller.sellers.map((seller) {
                          return _buildSellerCard(seller, context);
                        }).toList(),
                      );
                    } else {
                      // Desktop/Tablet Table View
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table Header
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Store Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 13 : 14))),
                              Expanded(
                                  flex: 3,
                                  child: Text('Owner',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 13 : 14))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 13 : 14))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Action',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 13 : 14))),
                            ],
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          Column(
                            children: _controller.sellers
                                .asMap()
                                .entries
                                .map((entry) {
                              var seller = entry.value;
                              bool isApproved =
                                  seller['status'].toLowerCase() == 'approved';

                              bool isRejected =
                                  seller['status'].toLowerCase() == 'rejected';
                              return Column(
                                children: [
                                  Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                        vertical: isTablet ? 12 : 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                seller['storeName'] ?? '',
                                                style: TextStyle(
                                                    fontSize:
                                                        isTablet ? 13 : 14))),
                                        Expanded(
                                            flex: 3,
                                            child: Text(
                                                seller['ownerName'] ?? '',
                                                style: TextStyle(
                                                    fontSize:
                                                        isTablet ? 13 : 14))),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _buildStatusBadge(isApproved,
                                                isRejected, isTablet),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        isTablet ? 10 : 12,
                                                    vertical: 6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                side: BorderSide(
                                                    color:
                                                        Colors.grey.shade400),
                                                textStyle: TextStyle(
                                                    fontSize:
                                                        isTablet ? 12 : 14),
                                              ),
                                              icon: Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: isTablet ? 16 : 18,
                                                  color: Colors.black),
                                              label: Text('View',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          isTablet ? 12 : 14)),
                                              onPressed: () =>
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Sidebar(
                                                                  role: 'admin',
                                                                  initialIndex:
                                                                      3,
                                                                  id: seller[
                                                                      'id']))),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSellerCard(dynamic seller, BuildContext context) {
    bool isApproved = seller['status'].toLowerCase() == 'approved';
    bool isRejected = seller['status'].toLowerCase() == 'rejected';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller['storeName'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        seller['ownerName'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(isApproved, isRejected, false),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                icon: Icon(Icons.remove_red_eye_outlined,
                    size: 18, color: Colors.black),
                label:
                    Text('View Details', style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Sidebar(
                            role: 'admin', initialIndex: 3, id: seller['id']))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isApproved, bool isRejected, bool isTablet) {
    if (isApproved) {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: isTablet ? 10 : 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.green, size: isTablet ? 16 : 18),
            SizedBox(width: 4),
            Text('Approved',
                style: TextStyle(
                    color: Colors.green, fontSize: isTablet ? 12 : 14)),
          ],
        ),
      );
    } else if (isRejected) {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: isTablet ? 10 : 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, color: Colors.red, size: isTablet ? 16 : 18),
            SizedBox(width: 4),
            Text('Rejected',
                style:
                    TextStyle(color: Colors.red, fontSize: isTablet ? 12 : 14)),
          ],
        ),
      );
    } else {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: isTablet ? 10 : 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.yellow[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pending_actions,
                color: Colors.yellow, size: isTablet ? 16 : 18),
            SizedBox(width: 4),
            Text('Pending',
                style: TextStyle(
                    color: Colors.yellow, fontSize: isTablet ? 12 : 14)),
          ],
        ),
      );
    }
  }
}
