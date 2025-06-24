import 'package:flutter/material.dart';
import 'package:furnistore/src/web/screens/sellers/seller_controller.dart';
import 'package:furnistore/src/web/screens/sidebar.dart';
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seller Accounts",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Manage seller applications and accounts",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusDirectional.circular(15),
                border: Border.all(width: 1, color: Colors.grey)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar (inside container, outside padding)
                Container(
                  margin: EdgeInsets.only(left: 20),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                // Table content with padding
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table Header
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text('Store Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              flex: 3,
                              child: Text('Owner',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              flex: 2,
                              child: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              flex: 2,
                              child: Text('Action',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      Obx(() {
                        _controller.fetchSellers();
                        return Column(
                          children:
                              _controller.sellers.asMap().entries.map((entry) {
                            var seller = entry.value;
                            bool isApproved =
                                seller['status'].toLowerCase() == 'approved';
                            bool isPending =
                                seller['status'].toLowerCase() == 'pending';
                            bool isRejected =
                                seller['status'].toLowerCase() == 'rejected';
                            return Column(
                              children: [
                                Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child:
                                              Text(seller['storeName'] ?? '')),
                                      Expanded(
                                          flex: 3,
                                          child:
                                              Text(seller['ownerName'] ?? '')),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: isApproved || isPending
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.check,
                                                          color: Colors.green,
                                                          size: 18),
                                                      SizedBox(width: 4),
                                                      Text('Approved',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .green)),
                                                    ],
                                                  ),
                                                )
                                              : isRejected
                                                  ? Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.close,
                                                              color: Colors.red,
                                                              size: 18),
                                                          SizedBox(width: 4),
                                                          Text('Rejected',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.yellow[50],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .pending_actions,
                                                              color:
                                                                  Colors.yellow,
                                                              size: 18),
                                                          SizedBox(width: 4),
                                                          Text('Pending',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .yellow)),
                                                        ],
                                                      ),
                                                    ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              side: BorderSide(
                                                  color: Colors.grey.shade400),
                                              textStyle:
                                                  TextStyle(fontSize: 14),
                                            ),
                                            icon: Icon(
                                                Icons.remove_red_eye_outlined,
                                                size: 18,
                                                color: Colors.black),
                                            label: Text('View',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            onPressed: () =>
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Sidebar(
                                                                role: 'admin',
                                                                initialIndex: 3,
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
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
