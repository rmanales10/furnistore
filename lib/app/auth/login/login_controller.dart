import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  RxBool isSuccess = false.obs;

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;

      // Set user status to online
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'status': 'online',
        });
      }
      isSuccess.value = true;
      return;
    } on FirebaseAuthException catch (e) {
      log(e.code);
      isSuccess.value = false;
    } catch (e) {
      log(e.toString());
      isSuccess.value = false;
    }
  }
}
