import 'package:flutter/material.dart';
import 'dart:async';

class FaceScanningScreen extends StatefulWidget {
  const FaceScanningScreen({super.key});

  @override
  State<FaceScanningScreen> createState() => _FaceScanningScreenState();
}

class _FaceScanningScreenState extends State<FaceScanningScreen> {
  bool _isScanning = true;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    // Simulate scanning process
    _scanTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        // Navigate to success screen after scanning
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        Navigator.pushReplacementNamed(
          context,
          '/identity-verification/success',
          arguments: args,
        );
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock camera view with face
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: Stack(
                children: [
                  // Mock face image
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Face icon
                          Center(
                            child: Icon(
                              Icons.face,
                              size: 120,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Face detection overlay (dots and lines)
                          if (_isScanning)
                            CustomPaint(
                              size: const Size(250, 250),
                              painter: FaceDetectionOverlayPainter(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Top bar with close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Title
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Face detection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Text(
                  _isScanning ? 'Scanning your face' : 'Face detected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please keep your face centered on the screen and facing forward',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for face detection overlay
class FaceDetectionOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw face detection points and lines
    final center = Offset(size.width / 2, size.height / 2);

    // Draw dots for face landmarks
    final dots = [
      Offset(center.dx - 40, center.dy - 30), // Left eye
      Offset(center.dx + 40, center.dy - 30), // Right eye
      Offset(center.dx, center.dy), // Nose
      Offset(center.dx - 30, center.dy + 30), // Left mouth
      Offset(center.dx + 30, center.dy + 30), // Right mouth
    ];

    for (var dot in dots) {
      canvas.drawCircle(dot, 4, paint);
    }

    // Draw lines connecting key points
    canvas.drawLine(dots[0], dots[1], paint); // Eye line
    canvas.drawLine(dots[1], dots[2], paint); // Right eye to nose
    canvas.drawLine(dots[2], dots[0], paint); // Nose to left eye
    canvas.drawLine(dots[3], dots[4], paint); // Mouth line
    canvas.drawLine(dots[2], dots[3], paint); // Nose to left mouth
    canvas.drawLine(dots[2], dots[4], paint); // Nose to right mouth
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
