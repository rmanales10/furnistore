import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  /// Create a new user with email and password and save user details to Firestore.
  Future<void> createEmailAndPassword({
    required String name,
    required String email,
    required String phoneNumber,
    required String password, required String idNumber, required String ipAddress,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'timestamp': DateTime.now(),
      });

      // Send email verification
      await verifyEmail();
      log('User created and verification email sent.');
    } catch (e) {
      log('Error in createEmailAndPassword: $e');
    }
  }

  /// Log in the user using email and password and check email verification.
  Future<bool> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      User? user = userCredential.user;

      // Check if email is verified
      if (user != null && user.emailVerified) {
        log('Login successful and email verified.');
        return true;
      } else {
        Get.snackbar('Error', 'Email not verified!');
        return false;
      }
    } catch (e) {
      log('Error : $e');
      Get.snackbar('Error', 'Wrong Email or Password!');
      return false;
    }
  }

  /// Send a verification email to the user.
  Future<void> verifyEmail() async {
    try {
      User? user = _auth.currentUser; // Get the current user
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(); // Send the verification email
        log('Verification email sent.');
      } else {
        log('User is null or email already verified.');
      }
    } catch (e) {
      log('Error in verifyEmail: $e');
    }
  }

  /// Resend the verification email if the user is not verified.
  Future<void> resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        log('Verification email resent.');
      } else {
        log('User is null or email already verified.');
      }
    } catch (e) {
      log('Error in resendVerificationEmail: $e');
    }
  }

  /// Check if the current user's email is verified.
  Future<bool> isEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload(); // Refresh the user's state
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      log('Error in isEmailVerified: $e');
      return false;
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log('Successfully reset $email');
    } catch (e) {
      log('Error $e');
    }
  }

  /// Sign out the currently logged-in user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      log('User signed out.');
    } catch (e) {
      log('Error in signOut: $e');
    }
  }
}
