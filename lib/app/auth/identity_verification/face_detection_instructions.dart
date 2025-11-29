import 'dart:math' as math;
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceDetectionInstructionsScreen extends StatefulWidget {
  const FaceDetectionInstructionsScreen({super.key});

  @override
  State<FaceDetectionInstructionsScreen> createState() =>
      _FaceDetectionInstructionsScreenState();
}

class _FaceDetectionInstructionsScreenState
    extends State<FaceDetectionInstructionsScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return;
      }

      // Use front camera for face detection
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Handle error silently or show message
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Life face detection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan your face to verify your identity.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            // Face detection camera preview with round border
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Camera preview (clipped to circle, mirrored, actual size)
                  ClipOval(
                    child: _isInitialized && _cameraController != null
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(
                                math.pi), // Mirror horizontally
                            child: SizedBox(
                              width: 250,
                              height: 250,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _cameraController!.value.aspectRatio *
                                      250,
                                  height: 250,
                                  child: CameraPreview(_cameraController!),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 250,
                            height: 250,
                            color: Colors.grey[100],
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Hexagonal outline
                                CustomPaint(
                                  size: const Size(200, 200),
                                  painter: HexagonPainter(),
                                ),
                                // Face icon with wavy line
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.face,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: 80,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                      child: CustomPaint(
                                        painter: WavyLinePainter(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Hexagonal overlay on top (only when camera is active)
                  if (_isInitialized && _cameraController != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HexagonOverlayPainter(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Status indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusIndicator(
                  icon: Icons.check_circle,
                  text: 'Uncovered face',
                  color: Colors.green,
                ),
                const SizedBox(width: 30),
                _buildStatusIndicator(
                  icon: Icons.wb_sunny,
                  text: 'Good lighting',
                  color: Colors.orange,
                ),
              ],
            ),
            const Spacer(),
            // Start Verification Button
            Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF3E6BE0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/identity-verification/face-scanning',
                    arguments: args,
                  );
                },
                child: const Text(
                  'Start Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We will automatically detect the face',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

// Custom painter for hexagonal overlay on camera preview
class HexagonOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3.5; // Slightly smaller to fit inside circle

    // Create a simple hexagon shape
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for hexagonal outline
class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Create a simple hexagon shape
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for wavy line
class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x < size.width; x += 5) {
      final y = size.height / 2 + 2 * math.sin(x / 10);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
