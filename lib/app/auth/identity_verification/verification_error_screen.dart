import 'package:flutter/material.dart';

class VerificationErrorScreen extends StatelessWidget {
  const VerificationErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final similarityScore = (args?['similarityScore'] as double?) ?? 0.0;
    final verificationData = args?['verificationData'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Error Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Verification Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'We couldn\'t verify your identity. Please check that your face matches the photo on your ID and that all ID information matches what you entered.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (similarityScore > 0)
                Text(
                  'Similarity: ${(similarityScore * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),

              // Guidance Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Please follow these guidelines:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuidelineItem(
                      icon: Icons.credit_card,
                      text: 'Match ID information',
                      subtext: 'ID must match your entered details',
                    ),
                    const SizedBox(height: 10),
                    _buildGuidelineItem(
                      icon: Icons.visibility,
                      text: 'Clear, readable ID',
                      subtext: 'Capture both sides clearly',
                    ),
                    const SizedBox(height: 10),
                    _buildGuidelineItem(
                      icon: Icons.face,
                      text: 'Face clearly visible',
                      subtext: 'Remove glasses, masks, or coverings',
                    ),
                    const SizedBox(height: 10),
                    _buildGuidelineItem(
                      icon: Icons.wb_sunny,
                      text: 'Good lighting',
                      subtext: 'Face light source, avoid shadows',
                    ),
                    const SizedBox(height: 10),
                    _buildGuidelineItem(
                      icon: Icons.center_focus_strong,
                      text: 'Look at camera',
                      subtext: 'Head straight, eyes open',
                    ),
                    const SizedBox(height: 10),
                    _buildGuidelineItem(
                      icon: Icons.photo_camera,
                      text: 'Same appearance as ID',
                      subtext: 'Similar look, no heavy makeup',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Try Again Button
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6BE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    // Navigate back to face scanning screen
                    Navigator.pushReplacementNamed(
                      context,
                      '/identity-verification/face-scanning',
                      arguments: verificationData,
                    );
                  },
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Form Button
              TextButton(
                onPressed: () {
                  // Navigate back to form to start over
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/identity-verification/form',
                    (route) => false,
                  );
                },
                child: Text(
                  'Start Over',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String text,
    required String subtext,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue[700],
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
