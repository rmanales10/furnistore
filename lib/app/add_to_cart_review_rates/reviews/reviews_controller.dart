import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ReviewsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  RxMap<String, dynamic> allReviews = <String, dynamic>{}.obs;
  Future<void> getAllReviews({required String productId}) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('products').doc(productId).get();
      if (documentSnapshot.exists) {
        allReviews.value = documentSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log('Error $e');
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
    } catch (e) {
      log('Error $e');
    }
  }
}
