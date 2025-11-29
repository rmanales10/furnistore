import 'package:flutter/material.dart';
import 'package:furnistore/app/auth/identity_verification/identity_verification_controller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  final _controller = Get.put(IdentityVerificationController());

  Future<void> _captureDocument() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar('Error', 'Camera permission is required');
      return;
    }

    // Capture document image
    final success = await _controller.captureDocumentImage();

    if (success && mounted) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      Navigator.pushNamed(
        context,
        '/identity-verification/face-detection-instructions',
        arguments: args,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Mock camera view with document
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: Stack(
                children: [
                  // Mock document image
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mock document content
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'DRIVING LICENCE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '12345678ABDG/1345',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Scanning overlay border
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Instruction text
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Move your ID inside the border',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                color: const Color(0xFF3E6BE0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => TextButton(
                    onPressed: _controller.isProcessing.value
                        ? null
                        : _captureDocument,
                    child: _controller.isProcessing.value
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
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
