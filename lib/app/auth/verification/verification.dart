import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/app/auth/login/login.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Handle back navigation
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Verify your email address!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Email Text
            Text(
              widget.email.toString(),
              style: const TextStyle(
                color: Color(0xFF3E6BE0), // Using the specified color
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description Text
            Text(
              'Congratulations! Your Account Awaits: Verify Your Email to Start the Experience a world of Unrivaled Offers.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 45),

            // Continue Button
            Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF3E6BE0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  // Reload user to check verification status
                  await _auth.currentUser?.reload();
                  final user = _auth.currentUser;

                  if (user != null && user.emailVerified) {
                    // Email verified, navigate to identity verification
                    Navigator.pushReplacementNamed(
                      context,
                      '/verify-identity-prompt',
                    );
                  } else {
                    // Email not verified, go back to login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Resend Email
            TextButton(
              onPressed: () async {
                await _auth.currentUser?.sendEmailVerification();
                Get.snackbar('Success', 'Email sent successfully');
              },
              child: const Text(
                'Resend Email',
                style: TextStyle(
                  color: Color(0xFF3E6BE0), // Using the specified color
                  decoration: TextDecoration.underline, // Underline the text
                  decorationColor: Color(0xFF3E6BE0), // Underline color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
