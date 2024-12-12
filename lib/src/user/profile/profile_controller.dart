import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;

  Future<void> getUserInfo() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (documentSnapshot.exists) {
        userInfo.value = documentSnapshot.data() as Map<String, dynamic>;
        // log('Data fetched successfully $userInfo');
      }
    } catch (e) {
      log('Error fetching data $e');
    }
  }

  Future<void> setProfileInfo(
      {required String name, required String image}) async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'name': name,
        'image': image,
      }, SetOptions(merge: true));

      log('Set profile info stored Successfully');
    } catch (e) {
      log('Error storing data $e');
    }
  }
}
