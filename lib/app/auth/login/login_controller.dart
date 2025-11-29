import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  RxBool isSuccess = false.obs;

  Future<Map<String, dynamic>> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Check if email is verified
      if (user != null && !user.emailVerified) {
        // Sign out the user since email is not verified
        await _auth.signOut();
        log('❌ Email not verified for user: ${user.email}');
        return {
          'success': false,
          'error': 'email_not_verified',
          'message':
              'Please verify your email before signing in. A verification email has been sent to your email address.',
        };
      }

      final userId = user?.uid;

      // Set user status to online
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'status': 'online',
        });
      }
      isSuccess.value = true;
      return {
        'success': true,
        'message': 'Login successful',
      };
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code}');
      String errorMessage = 'Invalid email or password';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email address';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled';
      }
      isSuccess.value = false;
      return {
        'success': false,
        'error': e.code,
        'message': errorMessage,
      };
    } catch (e) {
      log('Login Error: $e');
      isSuccess.value = false;
      return {
        'success': false,
        'error': 'unknown',
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Check if user has verified their identity
  Future<bool> checkIdentityVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      final verificationDoc = await _firestore
          .collection('identityVerifications')
          .doc(user.uid)
          .get();

      if (!verificationDoc.exists) {
        return false;
      }

      final data = verificationDoc.data();
      final status = data?['status'] as String?;

      // Return true if status is 'approved'
      return status == 'approved';
    } catch (e) {
      log('Error checking identity verification: $e');
      return false;
    }
  }
}
