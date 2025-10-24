import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furnistore/app/encryptor/cryptograpy.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _connect = GetConnect();
  final isSuccess = false.obs;
  String? userId;

  Future<String> getCountry() async {
    try {
      final response = await _connect.get('https://ipwho.is/');
      if (response.statusCode == 200) {
        return response.body['country'];
      }
      return 'Unknown';
    } catch (e) {
      return 'Error';
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String status,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      userId = userCredential.user?.uid;
      log('User created successfully: $userId');
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'country': await getCountry(),
        'status': status,
        'phoneVerified': false, // Phone verification status
        'createdAt': FieldValue.serverTimestamp(),
        'password': encryptText(password),
      });
      log('User data saved successfully.');
      // No email verification - using phone verification instead
      isSuccess.value = true;
    } catch (e) {
      log('Error saving user data to Firestore: $e');
      isSuccess.value = false;
      rethrow;
    }
  }
}
