import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furnistore/src/user/firebase_service/auth_service.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final _auth = Get.put(AuthService());
  final _firestore = FirebaseFirestore.instance;

  RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  Future<void> getUserInfo() async {
    try {
      // Fetch the document
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        userInfo.value = documentSnapshot.data() as Map<String, dynamic>;
      } else {
        log('User document does not exist.');
      }
    } catch (e) {
      log('Error fetching user info: $e');
    }
  }

  RxList<Map<String, dynamic>> orderStatus = <Map<String, dynamic>>[].obs;

  Future<void> getOrderStatus() async {
    // Fetch orders from Firestore
    QuerySnapshot querySnapshot = await _firestore
        .collection('orders')
        .where('user_id', isEqualTo: _auth.currentUser!.uid)
        .get();

    // Map orders to `orderStatus`
    orderStatus.value = querySnapshot.docs
        .map((doc) => {
              'status': doc['status'], // Order status
              'date': doc['date'], // Order date
              'order_id': doc['order_id'], // Order ID
              'total_items': doc['total_items'], // Total number of items
              'products': doc['products'], // List of products in the order
            })
        .toList();
  }

  RxMap<String, dynamic> productList = <String, dynamic>{}.obs;
  Future<void> getProductList({required String orderId}) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('orders').doc(orderId).get();
      if (documentSnapshot.exists) {
        productList.value = documentSnapshot.data() as Map<String, dynamic>;
      }
      // log('Success $productList');
    } catch (e) {
      log('Error $e');
    }
  }

  Future<void> submitReviews({
    required String productId,
    required String comment,
    required int ratings,
  }) async {
    await _firestore.collection('products').doc(productId).update({
      'reviews': FieldValue.arrayUnion([
        {
          'user_id': _auth.currentUser!.uid,
          'comment': comment,
          'ratings': ratings,
        }
      ]),
    });
  }
}
