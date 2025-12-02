import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Onboard1 extends StatefulWidget {
  const Onboard1({super.key});

  @override
  State<Onboard1> createState() => _Onboard1State();
}

class _Onboard1State extends State<Onboard1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is already logged in
    User? user = _auth.currentUser;
    if (user != null) {
      // Reload user to get latest email verification status
      await user.reload();
      user = _auth.currentUser;

      // First check if email is verified
      if (user != null && !user.emailVerified) {
        // Email not verified, navigate to email verification prompt
        Get.offAllNamed('/email-verification-prompt');
        return;
      }

      // Email is verified, check identity verification status
      final hasVerified = await _checkIdentityVerificationStatus(user!.uid);
      if (!hasVerified) {
        // User is not verified, navigate to identity verification prompt
        Get.offAllNamed('/verify-identity-prompt');
      } else {
        // User is verified, navigate to home
        Get.offAllNamed('/home');
      }
    } else {
      // User is not logged in, navigate to onboarding
      if (mounted) {
        Navigator.pushNamed(context, '/2');
      }
    }
  }

  Future<bool> _checkIdentityVerificationStatus(String userId) async {
    try {
      final verificationDoc = await _firestore
          .collection('identityVerifications')
          .doc(userId)
          .get();

      if (!verificationDoc.exists) {
        return false;
      }

      final data = verificationDoc.data();
      final status = data?['status'] as String?;

      // Return true if status is 'approved'
      return status == 'approved';
    } catch (e) {
      // If there's an error, assume not verified
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 75,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image_3.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
