import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:furnistore/app/auth/identity_verification/identity_verification_controller.dart';
import 'package:get/get.dart';

// Border radius constant to ensure blur and border match exactly
const double _idCardBorderRadius = 12.0;

class DocumentCameraScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const DocumentCameraScreen({super.key, this.arguments});

  @override
  State<DocumentCameraScreen> createState() => _DocumentCameraScreenState();
}

class _DocumentCameraScreenState extends State<DocumentCameraScreen> {
  CameraController? _cameraController;
  final _controller = Get.put(IdentityVerificationController());
  bool _isInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        Get.snackbar('Error', 'Camera permission is required');
        Navigator.pop(context);
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          Get.snackbar('Error', 'No cameras available');
          Navigator.pop(context);
        }
        return;
      }

      _cameraController = CameraController(
        cameras.first,
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
      if (mounted) {
        Get.snackbar('Error', 'Failed to initialize camera: $e');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _captureDocument() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      // Store the captured image
      _controller.documentImage.value = imageBytes;

      if (mounted) {
        // Navigate to next screen
        Navigator.pushReplacementNamed(
          context,
          '/identity-verification/face-detection-instructions',
          arguments: widget.arguments,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to capture image: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.85;
    final cardHeight =
        cardWidth * 0.63; // ID card aspect ratio (85.6mm x 53.98mm ≈ 1.585:1)

    // Calculate center position (middle of screen)
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 3;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Blurred overlay outside the border (using ClipPath to exclude center area)
          Positioned.fill(
            child: ClipPath(
              clipper: IdCardClipper(
                centerX: centerX,
                centerY: centerY,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                borderRadius: _idCardBorderRadius,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // Overlay with ID card border (centered)
          Positioned.fill(
            child: CustomPaint(
              painter: IdCardBorderPainter(
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                screenWidth: screenSize.width,
                screenHeight: screenSize.height,
                centerX: centerX,
                centerY: centerY,
              ),
            ),
          ),

          // Instruction text
          Positioned(
            bottom: 300,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Position your ID card within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isCapturing ? Colors.grey : const Color(0xFF3E6BE0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: _isCapturing ? null : _captureDocument,
                child: _isCapturing
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
                        'Capture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for ID card border overlay
class IdCardBorderPainter extends CustomPainter {
  final double cardWidth;
  final double cardHeight;
  final double screenWidth;
  final double screenHeight;
  final double centerX;
  final double centerY;

  IdCardBorderPainter({
    required this.cardWidth,
    required this.cardHeight,
    required this.screenWidth,
    required this.screenHeight,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw ID card border (rounded rectangle) - centered
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cardWidth,
        height: cardHeight,
      ),
      const Radius.circular(_idCardBorderRadius),
    );

    canvas.drawRRect(rect, paint);

    // Draw corner indicators (small squares at corners)
    final cornerSize = 20.0;
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Top-left corner
    canvas.drawLine(
      Offset(centerX - cardWidth / 2, centerY - cardHeight / 2),
      Offset(centerX - cardWidth / 2 + cornerSize, centerY - cardHeight / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cardWidth / 2, centerY - cardHeight / 2),
      Offset(centerX - cardWidth / 2, centerY - cardHeight / 2 + cornerSize),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(centerX + cardWidth / 2, centerY - cardHeight / 2),
      Offset(centerX + cardWidth / 2 - cornerSize, centerY - cardHeight / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cardWidth / 2, centerY - cardHeight / 2),
      Offset(centerX + cardWidth / 2, centerY - cardHeight / 2 + cornerSize),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(centerX - cardWidth / 2, centerY + cardHeight / 2),
      Offset(centerX - cardWidth / 2 + cornerSize, centerY + cardHeight / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX - cardWidth / 2, centerY + cardHeight / 2),
      Offset(centerX - cardWidth / 2, centerY + cardHeight / 2 - cornerSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(centerX + cardWidth / 2, centerY + cardHeight / 2),
      Offset(centerX + cardWidth / 2 - cornerSize, centerY + cardHeight / 2),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(centerX + cardWidth / 2, centerY + cardHeight / 2),
      Offset(centerX + cardWidth / 2, centerY + cardHeight / 2 - cornerSize),
      cornerPaint,
    );

    // Draw semi-transparent overlay outside the card area
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Top overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenWidth, centerY - cardHeight / 2),
      overlayPaint,
    );

    // Bottom overlay
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        centerY + cardHeight / 2,
        screenWidth,
        screenHeight - (centerY + cardHeight / 2),
      ),
      overlayPaint,
    );

    // Left overlay
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        centerY - cardHeight / 2,
        centerX - cardWidth / 2,
        cardHeight,
      ),
      overlayPaint,
    );

    // Right overlay
    canvas.drawRect(
      Rect.fromLTWH(
        centerX + cardWidth / 2,
        centerY - cardHeight / 2,
        screenWidth - (centerX + cardWidth / 2),
        cardHeight,
      ),
      overlayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom clipper to exclude the ID card area from blur
class IdCardClipper extends CustomClipper<Path> {
  final double centerX;
  final double centerY;
  final double cardWidth;
  final double cardHeight;
  final double borderRadius;

  IdCardClipper({
    required this.centerX,
    required this.centerY,
    required this.cardWidth,
    required this.cardHeight,
    required this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    // Create a path that covers the entire screen
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Subtract the ID card area (center) from the path
    // Use exact same dimensions and radius as the border
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cardWidth,
        height: cardHeight,
      ),
      Radius.circular(borderRadius),
    );

    // Use PathOperation.difference to exclude the card area
    final cardPath = Path()..addRRect(cardRect);
    return Path.combine(PathOperation.difference, fullPath, cardPath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
