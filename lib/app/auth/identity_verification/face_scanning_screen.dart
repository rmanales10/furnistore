import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:furnistore/app/auth/identity_verification/identity_verification_controller.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class FaceScanningScreen extends StatefulWidget {
  const FaceScanningScreen({super.key});

  @override
  State<FaceScanningScreen> createState() => _FaceScanningScreenState();
}

class _FaceScanningScreenState extends State<FaceScanningScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final _controller = Get.put(IdentityVerificationController());
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _hasCaptured = false;

  // Face detection
  FaceDetector? _faceDetector;
  bool _isFaceDetected = false;
  Timer? _captureTimer;
  bool _isProcessingFrame = false;

  // Animation for pulsing border
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
    _initializeCamera();
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
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

      // Initialize face detector
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableLandmarks: false,
          enableClassification: false,
          enableTracking: false,
          minFaceSize: 0.1,
        ),
      );

      // Start processing camera frames for face detection
      await _startFaceDetection();

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

  Future<void> _captureFace() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    // Stop image stream before capturing
    await _cameraController!.stopImageStream();
    _captureTimer?.cancel();
    _captureTimer = null;

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      // Store the captured image
      _controller.faceImage.value = imageBytes;

      setState(() {
        _hasCaptured = true;
      });

      // Complete verification process
      await _completeVerification();
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to capture image: $e');
        setState(() {
          _isCapturing = false;
        });
        // Restart image stream if capture failed
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          await _startFaceDetection();
        }
      }
    }
  }

  Future<void> _startFaceDetection() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    await _cameraController!.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame ||
        _isCapturing ||
        _hasCaptured ||
        _faceDetector == null) {
      return;
    }

    _isProcessingFrame = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);

      if (!mounted) {
        _isProcessingFrame = false;
        return;
      }

      // Check if face is detected and positioned well
      final hasValidFace = faces.isNotEmpty;

      setState(() {
        if (hasValidFace) {
          if (!_isFaceDetected) {
            // Face just detected, start timer and stop pulse animation
            _isFaceDetected = true;
            _pulseController.stop();
            _startCaptureTimer();
          }
        } else {
          // Face lost, reset and restart pulse animation
          _isFaceDetected = false;
          _captureTimer?.cancel();
          _captureTimer = null;
          if (!_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          }
        }
      });
    } catch (e) {
      // Silently handle errors to avoid spam
    } finally {
      _isProcessingFrame = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      // Combine all planes into a single byte array
      final allBytes = <int>[];
      for (final Plane plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }
      final bytes = Uint8List.fromList(allBytes);

      final imageRotation = InputImageRotation.rotation0deg;

      // Determine format based on camera image format
      InputImageFormat format = InputImageFormat.nv21;
      if (image.format.group == ImageFormatGroup.yuv420) {
        format = InputImageFormat.nv21;
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        format = InputImageFormat.bgra8888;
      }

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      return null;
    }
  }

  void _startCaptureTimer() {
    _captureTimer?.cancel();
    _captureTimer = Timer(const Duration(seconds: 2), () {
      if (_isFaceDetected && !_isCapturing && !_hasCaptured && mounted) {
        _captureFace();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _captureTimer?.cancel();
    _faceDetector?.close();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _completeVerification() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      Get.snackbar('Error', 'Missing verification data');
      return;
    }

    final dateOfBirth = args['dateOfBirth'] as DateTime;
    final gender = args['gender'] as String;
    final idCardType = args['idCardType'] as String;
    final idCardNumber = args['idCardNumber'] as String;

    // Complete verification
    final success = await _controller.completeVerification(
      dateOfBirth: dateOfBirth,
      gender: gender,
      idCardType: idCardType,
      idCardNumber: idCardNumber,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(
          context,
          '/identity-verification/success',
        );
      } else {
        Get.snackbar(
          'Verification Failed',
          'Face verification did not match. Please try again.',
          duration: const Duration(seconds: 5),
        );
        Navigator.pop(context);
      }
    }
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
    final circleSize = 250.0;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 3;

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
      body: Stack(
        children: [
          // Full screen camera preview (background) - mirrored for front camera
          Positioned.fill(
            child: Transform.flip(
              flipX: true, // Mirror horizontally for front camera
              child: CameraPreview(_cameraController!),
            ),
          ),

          // Blurred overlay outside the circle - fully blurred
          Positioned.fill(
            child: ClipPath(
              clipper: FaceCircleClipper(
                centerX: centerX,
                centerY: centerY,
                radius: circleSize / 2,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 20, sigmaY: 20), // Increased blur intensity
                child: Container(
                  color: Colors.black
                      .withOpacity(0.5), // Darker overlay for better contrast
                ),
              ),
            ),
          ),

          // Border overlay matching the clear circle area
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: FaceCircleBorderPainter(
                    centerX: centerX,
                    centerY: centerY,
                    radius: circleSize / 2,
                    isFaceDetected: _isFaceDetected,
                    pulseOpacity: _isFaceDetected ? 1.0 : _pulseAnimation.value,
                  ),
                );
              },
            ),
          ),

          // Face detection success indicator (positioned at circle center)
          if (_hasCaptured)
            Positioned(
              left: centerX - circleSize / 2,
              top: centerY - circleSize / 2,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

          // Main content overlay
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Face Liveness',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Guide instructions
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white.withOpacity(0.9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Position your face within the border',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Make sure your face is centered and fully visible',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
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
                    const SizedBox(height: 16),
                    // Status message with icon
                    Obx(() {
                      final statusText =
                          _controller.processingStatus.value.isNotEmpty
                              ? _controller.processingStatus.value
                              : _isFaceDetected
                                  ? 'Face detected! Capturing in 2 seconds...'
                                  : 'Align your face with the border';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _isFaceDetected
                              ? Colors.green.withOpacity(0.2)
                              : Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isFaceDetected
                                ? Colors.green.withOpacity(0.5)
                                : Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isFaceDetected ? Icons.check_circle : Icons.face,
                              color: _isFaceDetected
                                  ? Colors.green
                                  : Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _isFaceDetected
                                      ? Colors.green
                                      : Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper to exclude the face circle area from blur
class FaceCircleClipper extends CustomClipper<Path> {
  final double centerX;
  final double centerY;
  final double radius;

  FaceCircleClipper({
    required this.centerX,
    required this.centerY,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    // Create a path that covers the entire screen
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Subtract the circle area from the path
    final circlePath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: radius,
        ),
      );

    // Use PathOperation.difference to exclude the circle area
    return Path.combine(PathOperation.difference, fullPath, circlePath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom painter to draw border around the clear circle area
class FaceCircleBorderPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double radius;
  final bool isFaceDetected;
  final double pulseOpacity;

  FaceCircleBorderPainter({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.isFaceDetected,
    required this.pulseOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isFaceDetected) {
      // Green border when face detected
      final paint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );

      // Add glow effect when face is detected
      final glowPaint = Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        glowPaint,
      );
    } else {
      // Pulsing white border when no face detected
      final paint = Paint()
        ..color = Colors.white.withOpacity(pulseOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );

      // Outer pulse ring
      final pulsePaint = Paint()
        ..color = Colors.white.withOpacity(pulseOpacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(
        Offset(centerX, centerY),
        radius + 5,
        pulsePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FaceCircleBorderPainter oldDelegate) {
    return oldDelegate.isFaceDetected != isFaceDetected ||
        oldDelegate.pulseOpacity != pulseOpacity;
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
