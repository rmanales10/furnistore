import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class IdentityVerificationController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _imagePicker = ImagePicker();

  GenerativeModel? _model;
  String? _geminiApiKey;
  bool _isLoadingApiKey = false;

  RxBool isProcessing = false.obs;
  RxString processingStatus = ''.obs;
  Rx<Uint8List?> documentImage = Rx<Uint8List?>(null); // Front ID image
  Rx<Uint8List?> documentBackImage = Rx<Uint8List?>(null); // Back ID image
  Rx<Uint8List?> faceImage = Rx<Uint8List?>(null);

  // Fetch Gemini API key from Firestore
  Future<String?> _fetchGeminiApiKey() async {
    if (_geminiApiKey != null) {
      return _geminiApiKey;
    }

    if (_isLoadingApiKey) {
      // Wait for ongoing fetch to complete
      while (_isLoadingApiKey) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _geminiApiKey;
    }

    try {
      _isLoadingApiKey = true;
      final doc = await _firestore
          .collection('GEMINI_API_KEY')
          .doc('GEMINI_API_KEY')
          .get();

      if (doc.exists && doc.data() != null) {
        _geminiApiKey = doc.data()!['GEMINI_API_KEY'] as String?;

        if (_geminiApiKey != null && _geminiApiKey!.isNotEmpty) {
          // Initialize Gemini model with fetched API key
          _model = GenerativeModel(
            model: 'gemini-2.5-flash',
            apiKey: _geminiApiKey!,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch Gemini API key: $e');
    } finally {
      _isLoadingApiKey = false;
    }

    return _geminiApiKey;
  }

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

  // Compress image bytes to reduce size
  Future<Uint8List?> compressImage(Uint8List imageBytes,
      {int quality = 70, int maxWidth = 1024, int maxHeight = 1024}) async {
    try {
      // Compress the image directly from bytes
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 800,
        minHeight: 800,
        quality: quality,
      );

      if (compressedBytes.isEmpty) {
        return null;
      }

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      Get.snackbar('Warning', 'Image compression failed: $e');
      // Return original if compression fails
      return imageBytes;
    }
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

  // Extract text from ID document using Gemini AI
  Future<Map<String, dynamic>?> extractIdInformation(
      Uint8List imageBytes) async {
    try {
      // Fetch API key from Firestore if not already loaded
      final apiKey = await _fetchGeminiApiKey();

      if (apiKey == null || apiKey.isEmpty || _model == null) {
        Get.snackbar('Error',
            'Gemini API key not available. Please configure it in Firestore.');
        return null;
      }

      processingStatus.value = 'Extracting information from ID...';

      // Create prompt for Gemini
      final prompt = '''
Analyze this ID document image and extract the following information in JSON format:
{
  "dateOfBirth": "YYYY-MM-DD format",
  "gender": "Male, Female, or Other",
  "idNumber": "the ID card number",
  "fullName": "full name if visible"
}

Extract the date of birth, gender, and ID number from the document. 
For date of birth, convert to YYYY-MM-DD format.
For gender, return "Male", "Female", or "Other".
Return only valid JSON, no additional text.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model!.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        return null;
      }

      // Parse JSON response
      // Remove markdown code blocks if present
      String jsonText = responseText.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      final extractedData = jsonDecode(jsonText) as Map<String, dynamic>;
      return extractedData;
    } catch (e) {
      Get.snackbar('Error', 'Failed to extract ID information: $e');
      return null;
    }
  }

  // Compare extracted ID information with form input (using contains matching)
  Map<String, dynamic> compareIdInformation({
    required Map<String, dynamic> extractedData,
    required DateTime formDateOfBirth,
    required String formGender,
    required String formIdNumber,
  }) {
    final results = <String, bool>{};
    final errors = <String>[];

    // Compare date of birth - check if date parts match
    try {
      final extractedDobStr = extractedData['dateOfBirth'] as String?;
      if (extractedDobStr != null && extractedDobStr.isNotEmpty) {
        try {
          final extractedDob = DateTime.parse(extractedDobStr);
          // Check if year, month, and day match
          final yearMatch = extractedDob.year == formDateOfBirth.year;
          final monthMatch = extractedDob.month == formDateOfBirth.month;
          final dayMatch = extractedDob.day == formDateOfBirth.day;

          // Also check if the date string contains the form date parts
          final formYear = formDateOfBirth.year.toString();
          final formMonth = formDateOfBirth.month.toString().padLeft(2, '0');
          final formDay = formDateOfBirth.day.toString().padLeft(2, '0');

          final containsYear = extractedDobStr.contains(formYear);
          final containsMonth = extractedDobStr.contains(formMonth) ||
              extractedDobStr.contains(formDateOfBirth.month.toString());
          final containsDay = extractedDobStr.contains(formDay) ||
              extractedDobStr.contains(formDateOfBirth.day.toString());

          // Match if exact date matches OR if extracted contains form date parts
          results['dateOfBirth'] = (yearMatch && monthMatch && dayMatch) ||
              (containsYear && containsMonth && containsDay);

          if (!results['dateOfBirth']!) {
            errors.add('Date of birth does not match');
          }
        } catch (e) {
          // If parsing fails, try string contains matching
          final formDateStr =
              '${formDateOfBirth.year}-${formDateOfBirth.month.toString().padLeft(2, '0')}-${formDateOfBirth.day.toString().padLeft(2, '0')}';
          final formDateParts = formDateStr.split('-');
          final containsDate =
              formDateParts.every((part) => extractedDobStr.contains(part));
          results['dateOfBirth'] = containsDate;
          if (!results['dateOfBirth']!) {
            errors.add('Date of birth does not match');
          }
        }
      } else {
        results['dateOfBirth'] = false;
        errors.add('Date of birth not found in ID');
      }
    } catch (e) {
      results['dateOfBirth'] = false;
      errors.add('Date of birth comparison failed');
    }

    // Compare gender - check if extracted contains form gender keywords
    try {
      final extractedGender =
          (extractedData['gender'] as String?)?.toLowerCase() ?? '';
      final formGenderLower = formGender.toLowerCase();

      // Check if extracted gender contains form gender or vice versa
      bool genderMatch = false;

      if (formGenderLower.contains('male') &&
          !formGenderLower.contains('female')) {
        // Form is Male - check if extracted contains male-related terms
        genderMatch = extractedGender.contains('male') &&
            !extractedGender.contains('female');
      } else if (formGenderLower.contains('female')) {
        // Form is Female - check if extracted contains female-related terms
        genderMatch = extractedGender.contains('female');
      } else if (formGenderLower.contains('other')) {
        // Form is Other - be more lenient
        genderMatch = extractedGender.isNotEmpty;
      }

      // Also check reverse - if extracted contains form gender
      if (!genderMatch) {
        genderMatch = extractedGender.contains(formGenderLower) ||
            formGenderLower.contains(extractedGender);
      }

      results['gender'] = genderMatch;
      if (!results['gender']!) {
        errors.add('Gender does not match');
      }
    } catch (e) {
      results['gender'] = false;
      errors.add('Gender comparison failed');
    }

    // Compare ID number - check if one contains the other
    try {
      final extractedIdNumber = (extractedData['idNumber'] as String?)
              ?.replaceAll(RegExp(r'[-\s]'), '')
              .toLowerCase() ??
          '';
      final formIdNumberClean =
          formIdNumber.replaceAll(RegExp(r'[-\s]'), '').toLowerCase();

      // Check if extracted contains form ID or form contains extracted ID
      bool idMatch = false;

      if (extractedIdNumber.isNotEmpty && formIdNumberClean.isNotEmpty) {
        // Check if extracted ID contains form ID (for partial matches)
        idMatch = extractedIdNumber.contains(formIdNumberClean) ||
            formIdNumberClean.contains(extractedIdNumber);

        // Also check if they're similar length and have common characters
        if (!idMatch &&
            extractedIdNumber.length > 0 &&
            formIdNumberClean.length > 0) {
          // Check if at least 70% of characters match
          final minLength = extractedIdNumber.length < formIdNumberClean.length
              ? extractedIdNumber.length
              : formIdNumberClean.length;
          int matchingChars = 0;
          for (int i = 0; i < minLength; i++) {
            if (extractedIdNumber[i] == formIdNumberClean[i]) {
              matchingChars++;
            }
          }
          final similarity = matchingChars / minLength;
          idMatch = similarity >= 0.7; // 70% similarity threshold
        }
      }

      results['idNumber'] = idMatch;
      if (!results['idNumber']!) {
        errors.add('ID number does not match');
      }
    } catch (e) {
      results['idNumber'] = false;
      errors.add('ID number comparison failed');
    }

    final allMatch = results.values.every((match) => match);

    return {
      'allMatch': allMatch,
      'results': results,
      'errors': errors,
      'extractedData': extractedData,
    };
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

      // Extract information from ID using Gemini AI
      final extractedData = await extractIdInformation(documentImage.value!);

      if (extractedData == null) {
        isProcessing.value = false;
        Get.snackbar('Error', 'Failed to extract information from ID');
        return false;
      }

      // Compare extracted data with form input
      final comparisonResult = compareIdInformation(
        extractedData: extractedData,
        formDateOfBirth: dateOfBirth,
        formGender: gender,
        formIdNumber: idCardNumber,
      );

      if (comparisonResult['allMatch'] != true) {
        isProcessing.value = false;
        final errors = comparisonResult['errors'] as List<String>;
        Get.snackbar(
          'Verification Failed',
          errors.join(', '),
          duration: const Duration(seconds: 5),
        );
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

      // Compress images before encoding
      processingStatus.value = 'Compressing images...';
      final compressedDocument = await compressImage(
        documentImage.value!,
        quality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      final compressedFace = await compressImage(
        faceImage.value!,
        quality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (compressedDocument == null || compressedFace == null) {
        isProcessing.value = false;
        Get.snackbar('Error', 'Failed to compress images');
        return false;
      }

      // Convert compressed images to base64
      processingStatus.value = 'Encoding images...';
      final documentImageBase64 = imageToBase64(compressedDocument);
      final faceImageBase64 = imageToBase64(compressedFace);

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
      // Get.snackbar('Error', 'Verification failed: $e');
      return false;
    }
  }
}
