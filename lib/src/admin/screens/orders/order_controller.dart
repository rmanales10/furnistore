import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  Future<void> getOrders() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('orders').get();

      orders.value = querySnapshot.docs.map((doc) {
        return {
          'date': doc['date'],
          'delivery_fee': doc['delivery_fee'],
          'mode_of_payment': doc['mode_of_payment'],
          'order_id': doc['order_id'],
          'products': doc['products'],
          'status': doc['status'],
          'sub_total': doc['sub_total'],
          'total': doc['total'],
          'total_items': doc['total_items'],
          'user_id': doc['user_id'],
        };
      }).toList();
      // log('Success $orders');
    } catch (e) {
      // log('Error fetching orders: $e');
    }
  }

  RxMap<String, dynamic> orderInfo = <String, dynamic>{}.obs;

  Future<void> getOrderInfo({required String orderId}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('order_id', isEqualTo: orderId)
          .get();

      // Make sure the order exists
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;

        // Assign the fields to the orderInfo observable map
        orderInfo.value = {
          'date': doc['date'],
          'delivery_fee': doc['delivery_fee'],
          'mode_of_payment': doc['mode_of_payment'],
          'order_id': doc['order_id'],
          'products': doc['products'],
          'status': doc['status'],
          'sub_total': doc['sub_total'],
          'total': doc['total'],
          'total_items': doc['total_items'],
          'user_id': doc['user_id'],
        };
        // log('Success $orderInfo');
      } else {
        // log('Order with ID $orderId not found.');
      }
    } catch (e) {
      // log('Error fetching orders: $e');
    }
  }

  RxList<Map<String, dynamic>> allProducts = <Map<String, dynamic>>[].obs;

  Future<void> getAllProducts({required String orderId}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('order_id', isEqualTo: orderId)
          .get();

      // Since 'products' is a list of maps in each document, you need to handle it appropriately
      if (querySnapshot.docs.isNotEmpty) {
        final orderDoc = querySnapshot.docs.first;
        List<dynamic> products =
            orderDoc['products']; // Get the 'products' list from the document

        // Convert the list of dynamic products into a list of maps
        allProducts.value = products.cast<Map<String, dynamic>>();
      }

      // log('Success quantityAndProductId $allProducts');
    } catch (e) {
      // log('Error $e');
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

  RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  Future<void> getUserInfo({required String userId}) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (documentSnapshot.exists) {
        userInfo.value = documentSnapshot.data() as Map<String, dynamic>;
      }
      // log('Sucess userInfo : $userInfo');
    } catch (e) {
      // log('Error $e');
    }
  }

  RxString orderStatus = ''.obs;
  Future<void> updateStatus(
      {required String orderId, required String status}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('order_id', isEqualTo: orderId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Use the first document ID if you expect only one match.
        String docId = querySnapshot.docs.first.id;

        await _firestore
            .collection('orders')
            .doc(docId)
            .set({'status': status}, SetOptions(merge: true));

        DocumentSnapshot documentSnapshot =
            await _firestore.collection('orders').doc(docId).get();
        orderStatus.value = documentSnapshot.get('status');

        // log('docId : $docId status : $status ');
      } else {
        // log('No documents found for orderId: $orderId');
      }
    } catch (e) {
      // log('Error $e');
    }
  }
}
