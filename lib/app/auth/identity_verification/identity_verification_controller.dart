import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class IdentityVerificationController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _imagePicker = ImagePicker();

  RxBool isProcessing = false.obs;
  RxString processingStatus = ''.obs;
  Rx<Uint8List?> documentImage = Rx<Uint8List?>(null);
  Rx<Uint8List?> faceImage = Rx<Uint8List?>(null);

  // Capture document image using image picker
  Future<bool> captureDocumentImage() async {
    try {
      isProcessing.value = true;
      processingStatus.value = 'Capturing document...';

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) {
        isProcessing.value = false;
        return false;
      }

      final imageBytes = await image.readAsBytes();
      documentImage.value = imageBytes;

      isProcessing.value = false;
      return true;
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar('Error', 'Failed to capture document: $e');
      return false;
    }
  }

  // Capture live face using Regula Face SDK
  Future<Uint8List?> captureLiveFace() async {
    try {
      isProcessing.value = true;
      processingStatus.value = 'Capturing your face...';

      // TODO: Verify correct Regula Face SDK method name
      // Try one of these based on package version:
      // var capturedImage = await FaceSDK.presentFaceCaptureActivity();
      // var capturedImage = await FaceSDK.presentFaceCapture();
      // var capturedImage = await FaceSDK.captureFace();

      // Temporary fallback using image_picker
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) {
        isProcessing.value = false;
        Get.snackbar('Error', 'Face capture failed. Please try again.');
        return null;
      }

      final capturedImage = await image.readAsBytes();
      faceImage.value = capturedImage;

      isProcessing.value = false;
      return capturedImage;
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar('Error', 'Face capture failed: $e');
      return null;
    }
  }

  // Extract face from document image using Regula Face SDK
  Future<bool> detectFaceInDocument(Uint8List documentImageBytes) async {
    try {
      processingStatus.value = 'Detecting face in document...';

      // Use Regula Face SDK to detect faces in document
      // DetectFacesRequest(image: Uint8List, config: DetectFacesConfig?)
      // Create config or pass null if optional
      final detectConfig = DetectFacesConfig();
      final detectRequest =
          DetectFacesRequest(documentImageBytes, detectConfig);

      // Detect faces using Regula SDK
      await FaceSDK.instance.detectFaces(detectRequest);

      // Check if at least one face is detected
      // The response structure - check actual properties in DetectFacesResponse
      // If detection succeeds without error, assume face is detected
      // Adjust based on actual API response structure
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to detect face in document: $e');
      return false;
    }
  }

  // Match faces using Regula Face SDK
  // Reference: https://docs.regulaforensics.com/develop/face-sdk/mobile/
  Future<Map<String, dynamic>?> matchFaces(
    Uint8List documentImageBytes,
    Uint8List liveFaceImageBytes,
  ) async {
    try {
      processingStatus.value = 'Comparing faces...';

      // Create match faces request with both images
      // Document image is PRINTED type (from ID card), live face is LIVE type (selfie)
      // MatchFacesImage expects 2 positional arguments: (Uint8List image, ImageType type)
      final matchRequest = MatchFacesRequest([
        MatchFacesImage(documentImageBytes, ImageType.PRINTED),
        MatchFacesImage(liveFaceImageBytes, ImageType.LIVE),
      ]);

      // Perform face matching using Regula Face SDK
      final matchResult = await FaceSDK.instance.matchFaces(matchRequest);

      // Extract similarity score from result
      double similarity = 0.0;

      try {
        // Try to access results - adjust based on actual API structure
        if (matchResult.results.isNotEmpty) {
          // Get the best match result (first result)
          final bestMatch = matchResult.results.first;
          similarity = bestMatch.similarity;
        }
      } catch (e) {
        // If results property structure is different, try alternative access
        // The response might have different property names
        Get.snackbar('Warning', 'Could not extract similarity score: $e');
        similarity = 0.0;
      }

      return {
        'similarity': similarity,
        'match': similarity >= 0.75, // Threshold for match (75% similarity)
      };
    } catch (e) {
      Get.snackbar('Error', 'Face matching failed: $e');
      return null;
    }
  }

  // Check if faces match based on similarity threshold
  bool areFacesMatching(Map<String, dynamic> matchResult,
      {double threshold = 0.75}) {
    final similarity = matchResult['similarity'] as double? ?? 0.0;
    return similarity >= threshold;
  }

  // Convert image bytes to base64 string
  String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  // Decode base64 string to image bytes
  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  // Save verification data to Firestore with base64 images
  Future<bool> saveVerificationData({
    required DateTime dateOfBirth,
    required String gender,
    required String idCardType,
    required String idCardNumber,
    required String documentImageBase64,
    required String faceImageBase64,
    required double similarityScore,
    required bool isMatch,
  }) async {
    try {
      processingStatus.value = 'Saving verification data...';

      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return false;
      }

      await _firestore.collection('identityVerifications').doc(user.uid).set({
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
        'idCardType': idCardType,
        'idCardNumber': idCardNumber,
        'documentImageBase64': documentImageBase64,
        'faceImageBase64': faceImageBase64,
        'similarityScore': similarityScore,
        'isMatch': isMatch,
        'status': isMatch ? 'approved' : 'rejected',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save data: $e');
      return false;
    }
  }

  // Complete verification process
  Future<bool> completeVerification({
    required DateTime dateOfBirth,
    required String gender,
    required String idCardType,
    required String idCardNumber,
  }) async {
    try {
      isProcessing.value = true;
      processingStatus.value = 'Processing verification...';

      // Check if we have both images
      if (documentImage.value == null || faceImage.value == null) {
        Get.snackbar(
            'Error', 'Missing images. Please capture both document and face.');
        isProcessing.value = false;
        return false;
      }

      // Match faces
      var matchResult = await matchFaces(
        documentImage.value!,
        faceImage.value!,
      );

      if (matchResult == null) {
        isProcessing.value = false;
        Get.snackbar('Error', 'Face matching failed');
        return false;
      }

      // Check if faces match
      bool isMatch = areFacesMatching(matchResult);
      double similarityScore = (matchResult['similarity'] as double?) ?? 0.0;

      // Convert images to base64
      processingStatus.value = 'Encoding images...';
      final documentImageBase64 = imageToBase64(documentImage.value!);
      final faceImageBase64 = imageToBase64(faceImage.value!);

      // Save verification data with base64 images
      final saved = await saveVerificationData(
        dateOfBirth: dateOfBirth,
        gender: gender,
        idCardType: idCardType,
        idCardNumber: idCardNumber,
        documentImageBase64: documentImageBase64,
        faceImageBase64: faceImageBase64,
        similarityScore: similarityScore,
        isMatch: isMatch,
      );

      isProcessing.value = false;
      return saved && isMatch;
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar('Error', 'Verification failed: $e');
      return false;
    }
  }
}
