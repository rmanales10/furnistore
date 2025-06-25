import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  RxBool isSuccess = false.obs;
  RxString role = ''.obs;

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isSuccess.value = true;
      final user = _auth.currentUser;
      final userDoc = await _firestore.collection('users').doc(user!.uid).get();
      final userData = userDoc.data();
      if (userData?['role'] == 'admin') {
        role.value = 'admin';
        return;
      } else if (userData?['role'] == 'seller') {
        role.value = 'seller';
        return;
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
