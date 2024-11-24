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
    QuerySnapshot querySnapshot = await _firestore
        .collection('orders')
        .where('user_id', isEqualTo: _auth.currentUser!.uid)
        .get();

    orderStatus.value = querySnapshot.docs
        .map((doc) => {
              'status': doc['status'],
              'date': doc['date'],
            })
        .toList();
  }
}
