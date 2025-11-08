import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList orders = [].obs;
  RxMap orderInfo = {}.obs;
  RxString orderStatus = ''.obs;
  RxMap userInfo = {}.obs;

  Future<void> getOrders() async {
    try {
      // Get current seller's user ID
      final sellerId = currentUser?.uid;
      if (sellerId == null) {
        log('No seller user ID found');
        orders.value = [];
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
        orders.value = [];
        return;
      }

      // Fetch all orders
      QuerySnapshot querySnapshot = await _firestore.collection('orders').get();

      // Filter orders that contain at least one product from this seller
      final filteredOrders = <Map<String, dynamic>>[];

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
            filteredOrders.add({
              ...orderData,
            });
          }
        }
      }

      orders.value = filteredOrders;
      log('Successfully fetched ${filteredOrders.length} orders for seller: $sellerId');
    } catch (e) {
      log('Error fetching orders: $e');
      orders.value = [];
    }
  }

  Future<void> getOrderInfo({required String orderId}) async {
    if (orderId.isEmpty) {
      return;
    }

    try {
      final snapshot = await _firestore.collection('orders').doc(orderId).get();
      orderInfo.value = snapshot.data() ?? {};
      // log('Success $orderInfo');
    } catch (e) {
      // log('Error fetching orders: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();

      // Remove the order from the local state as well
      orders.removeWhere((order) => order['order_id'] == orderId);
    } catch (e) {
      // log('Error deleting order: $e');
    }
  }

  Future<void> getUserInfo({required String userId}) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();

      userInfo.value = snapshot.data() ?? {};

      log('Sucess userInfo : $userInfo');
    } catch (e) {
      log('Error $e');
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Update local order info
      if (orderInfo.isNotEmpty) {
        orderInfo['status'] = newStatus;
        orderInfo.refresh();
      }

      // Update local orders list
      int index = orders.indexWhere((order) => order['order_id'] == orderId);
      if (index != -1) {
        orders[index]['status'] = newStatus;
        orders.refresh();
      }

      log('Order status updated to: $newStatus');
    } catch (e) {
      log('Error updating order status: $e');
      rethrow;
    }
  }
}
