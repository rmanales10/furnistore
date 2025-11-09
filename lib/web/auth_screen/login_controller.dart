import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  RxBool isSuccess = false.obs;
  RxString role = ''.obs;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Check if email is verified (except for admin and seller roles)
      if (user != null && !user.emailVerified) {
        // Check user role first
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data();
        final userRole = userData?['role'] ?? 'user';

        // Allow admin and seller to login without email verification
        if (userRole != 'admin' && userRole != 'seller') {
          // Sign out the user since email is not verified
          await _auth.signOut();
          log('❌ Email not verified for user: ${user.email}');
          return {
            'success': false,
            'error': 'email_not_verified',
            'message': 'Please verify your email before signing in.',
          };
        }
      }

      isSuccess.value = true;
      final userDoc = await _firestore.collection('users').doc(user!.uid).get();
      final userData = userDoc.data();
      if (userData?['role'] == 'admin') {
        role.value = 'admin';
        return {
          'success': true,
          'role': 'admin',
        };
      } else if (userData?['role'] == 'seller') {
        role.value = 'seller';
        return {
          'success': true,
          'role': 'seller',
        };
      }
      return {
        'success': false,
        'error': 'unauthorized',
        'message': 'You are not authorized to access this page',
      };
    } catch (e) {
      log('Login Error: $e');
      String errorMessage = 'Invalid email or password';
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = 'No account found with this email address';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'This account has been disabled';
        }
      }
      return {
        'success': false,
        'error': 'login_failed',
        'message': errorMessage,
      };
    }
  }
}
