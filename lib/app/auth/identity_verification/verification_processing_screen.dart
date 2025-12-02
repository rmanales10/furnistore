import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:furnistore/app/auth/identity_verification/identity_verification_controller.dart';

class VerificationProcessingScreen extends StatefulWidget {
  final Map<String, dynamic> verificationData;

  const VerificationProcessingScreen({
    super.key,
    required this.verificationData,
  });

  @override
  State<VerificationProcessingScreen> createState() =>
      _VerificationProcessingScreenState();
}

class _VerificationProcessingScreenState
    extends State<VerificationProcessingScreen> {
  final _controller = Get.find<IdentityVerificationController>();

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  Future<void> _startVerification() async {
    // Wait a moment to show the processing screen
    await Future.delayed(const Duration(milliseconds: 500));

    final dateOfBirth = widget.verificationData['dateOfBirth'] as DateTime;
    final gender = widget.verificationData['gender'] as String;
    final idCardType = widget.verificationData['idCardType'] as String;
    final idCardNumber = widget.verificationData['idCardNumber'] as String;

    // Match faces first to get similarity score
    double similarityScore = 0.0;
    Map<String, dynamic>? matchResult;

    if (_controller.documentImage.value != null &&
        _controller.faceImage.value != null) {
      matchResult = await _controller.matchFaces(
        _controller.documentImage.value!,
        _controller.faceImage.value!,
      );
      similarityScore = (matchResult?['similarity'] as double?) ?? 0.0;
    }

    // Complete verification (this will save the data)
    // Note: completeVerification will call matchFaces again internally,
    // but we need the similarity score for the error screen
    final success = await _controller.completeVerification(
      dateOfBirth: dateOfBirth,
      gender: gender,
      idCardType: idCardType,
      idCardNumber: idCardNumber,
    );

    if (!mounted) return;

    if (success) {
      // Verification successful
      Navigator.pushReplacementNamed(
        context,
        '/identity-verification/success',
      );
    } else {
      // Verification failed - navigate to error screen with details
      Navigator.pushReplacementNamed(
        context,
        '/identity-verification/error',
        arguments: {
          'similarityScore': similarityScore,
          'verificationData': widget.verificationData,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated loading icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E6BE0).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        size: 50,
                        color: Color(0xFF3E6BE0),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Wait a moment',
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
                'We\'re verifying your identity',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E6BE0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
