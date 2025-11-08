import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  RxInt totalUsers = 0.obs;
  var totalRevenue = 0.0.obs;
  var totalOrders = 0.obs;
  RxInt totalSellers = 0.obs;
  RxList<int> monthlyUserCounts = List<int>.filled(12, 0).obs;

  Future<void> fetchDataFromFirestore() async {
    try {
      // Get current seller's user ID
      final sellerId = currentUser?.uid;
      if (sellerId == null) {
        log('No seller user ID found');
        totalRevenue.value = 0.0;
        totalOrders.value = 0;
        return;
      }

      // First, get all product IDs that belong to this seller
      final productsSnapshot = await _firestore
          .collection('products')
          .where('seller_id', isEqualTo: sellerId)
          .get();

      final sellerProductIds = productsSnapshot.docs
          .map((doc) => doc.id)
          .toSet(); // Use Set for faster lookup

      if (sellerProductIds.isEmpty) {
        log('No products found for seller: $sellerId');
        totalRevenue.value = 0.0;
        totalOrders.value = 0;
        return;
      }

      // Fetch all orders
      QuerySnapshot querySnapshot = await _firestore.collection('orders').get();

      var revenue = 0.0;
      int orderCount = 0;

      // Filter orders that contain at least one product from this seller
      for (var doc in querySnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final products = orderData['products'] as List<dynamic>?;

        if (products != null && products.isNotEmpty) {
          // Check if any product in the order belongs to this seller
          bool hasSellerProduct = false;
          for (var product in products) {
            if (product is Map<String, dynamic>) {
              // Check both 'product_id' and 'id' fields
              final productId = product['product_id'] ?? product['id'];
              if (productId != null &&
                  sellerProductIds.contains(productId.toString())) {
                hasSellerProduct = true;
                break;
              }
            }
          }

          if (hasSellerProduct) {
            revenue += (orderData['total'] ?? 0).toDouble();
            orderCount++;
          }
        }
      }

      totalRevenue.value = revenue;
      totalOrders.value = orderCount;
      log('Seller dashboard - Revenue: $revenue, Orders: $orderCount');
    } catch (e) {
      log("Failed to fetch data: $e");
      totalRevenue.value = 0.0;
      totalOrders.value = 0;
    }
  }

  Future<void> fetchTotalUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      totalUsers.value = querySnapshot.size;
    } catch (e) {
      log("Failed to fetch data: $e");
    }
  }

  Future<void> fetchTotalSellers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('sellersApplication')
          .where('status', isEqualTo: 'Approved')
          .get();
      totalSellers.value = querySnapshot.size;
    } catch (e) {
      log("Failed to fetch data: $e");
    }
  }

  Future<void> fetchMonthlyUserCounts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      List<int> counts = List.filled(12, 0);
      DateTime now = DateTime.now();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] != null) {
          DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
          if (createdAt.year == now.year) {
            counts[createdAt.month - 1]++;
          }
        }
      }
      monthlyUserCounts.value = counts;
    } catch (e) {
      log("Failed to fetch monthly user counts: $e");
    }
  }
}
