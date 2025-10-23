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
      QuerySnapshot querySnapshot = await _firestore.collection('orders').get();

      orders.value = querySnapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      // log('Success $orders');
    } catch (e) {
      // log('Error fetching orders: $e');
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
