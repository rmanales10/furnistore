import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerificationPromptScreen extends StatefulWidget {
  const EmailVerificationPromptScreen({super.key});

  @override
  State<EmailVerificationPromptScreen> createState() =>
      _EmailVerificationPromptScreenState();
}

class _EmailVerificationPromptScreenState
    extends State<EmailVerificationPromptScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isChecking = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = _auth.currentUser?.email;
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // Reload user to get latest email verification status
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        // Email is verified, navigate to identity verification
        if (mounted) {
          Get.offAllNamed('/verify-identity-prompt');
        }
      } else {
        // Email not verified yet
        Get.snackbar(
          'Email Not Verified',
          'Please check your email and click the verification link.',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check verification status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        Get.snackbar(
          'Success',
          'Verification email sent! Please check your inbox.',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6BE0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: Color(0xFF3E6BE0),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Please verify your email first',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Before proceeding to identity verification, please verify your email address.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_userEmail != null) ...[
                Text(
                  'We sent a verification email to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _userEmail!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E6BE0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 60),

              // Check Verification Button
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6BE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: _isChecking ? null : _checkEmailVerification,
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'I\'ve verified my email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Resend Email Button
              TextButton(
                onPressed: _resendVerificationEmail,
                child: Text(
                  'Resend verification email',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
