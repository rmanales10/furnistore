import 'dart:developer';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ApplyController extends GetxController {
  final _connect = GetConnect();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final String cloudName = 'duedhyux7'; // e.g. 'demo'
  final String uploadPreset = 'FurniStore';
  Rx<Uint8List?> file = Rx<Uint8List?>(null);
  RxString fileName = RxString('');
  // Store logo variables
  RxString storeLogoBase64 = RxString('');
  RxString storeLogoFileName = RxString('');
  bool isSuccess = false;
  Rx<Map<String, dynamic>?> sellerStatus = Rx<Map<String, dynamic>?>(null);

  Future<void> applyAsSeller(
      {required String storeName,
      required String ownersName,
      required String ownersEmail,
      required String businessDescription}) async {
    try {
      if (_auth.currentUser == null) {
        log('❌ User not logged in.');
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      if (file.value == null) {
        log('❌ No file selected.');
        Get.snackbar('Error', 'Please select a file to upload');
        return;
      }

      log('📤 Uploading file to Cloudinary...');
      final form = FormData({
        'upload_preset': uploadPreset,
        'file': MultipartFile(file.value!, filename: fileName.value),
      });

      final response = await _connect.post(
        'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
        form,
      );

      String fileUrl = '';
      if (response.statusCode == 200) {
        log('✅ Upload successful!');
        log('🌐 URL: ${response.body['secure_url']}');
        fileUrl = response.body['secure_url'];
      } else {
        log('❌ Upload failed: ${response.statusCode}');
        log(response.bodyString.toString());
        Get.snackbar('Error', 'File upload failed. Please try again.');
        return;
      }

      log('💾 Saving application to Firestore...');
      final user = _auth.currentUser;
      await _firestore.collection('sellersApplication').doc(user!.uid).set({
        'storeName': storeName,
        'ownerName': ownersName,
        'ownersEmail': ownersEmail,
        'businessDescription': businessDescription,
        'file': fileUrl,
        'storeLogoBase64': storeLogoBase64.value,
        'storeLogoFileName': storeLogoFileName.value,
        'status': 'Pending',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      log('✅ Application submitted successfully!');
      isSuccess = true;
    } catch (e) {
      log('❌ Error submitting application: $e');
      Get.snackbar('Error', 'Failed to submit application: $e');
      isSuccess = false;
    }
  }

  Future<void> uploadFile() async {
    try {
      log('📁 Starting file picker...');

      // Try different file picker configurations
      FilePickerResult? result;

      // First try with custom file types
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
          allowMultiple: false,
          withData: true, // This ensures we get file bytes
        );
      } catch (e) {
        log('⚠️ Custom file picker failed, trying general file picker: $e');

        // Fallback to general file picker
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          withData: true,
        );
      }

      // If no file is selected
      if (result == null || result.files.isEmpty) {
        log('❌ No file selected.');
        Get.snackbar('Error', 'No file selected');
        return;
      }

      final pickedFile = result.files.first;
      log('📄 File picked: ${pickedFile.name}');
      log('📊 File size: ${pickedFile.size} bytes');

      // Access file data
      Uint8List? fileBytes = pickedFile.bytes;
      String selectedFileName = pickedFile.name;

      // If bytes are null, try to read from path (for some platforms)
      if (fileBytes == null && pickedFile.path != null) {
        log('⚠️ File bytes null, trying to read from path: ${pickedFile.path}');
        try {
          final file = File(pickedFile.path!);
          if (await file.exists()) {
            fileBytes = await file.readAsBytes();
            log('✅ Successfully read file from path');
          }
        } catch (e) {
          log('❌ Failed to read file from path: $e');
        }
      }

      if (fileBytes == null) {
        log('❌ Failed to read file bytes.');
        Get.snackbar('Error',
            'Failed to read file. Please try a different file or format.');
        return;
      }

      // Validate file extension
      final fileExtension = selectedFileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'];
      if (!allowedExtensions.contains(fileExtension)) {
        Get.snackbar('Error',
            'File type not supported. Please select JPG, PNG, PDF, DOC, or DOCX files.');
        return;
      }

      // Check file size (max 10MB)
      if (fileBytes.length > 10 * 1024 * 1024) {
        Get.snackbar('Error', 'File size too large. Maximum 10MB allowed.');
        return;
      }

      // Update reactive variables
      file.value = fileBytes;
      fileName.value = selectedFileName;

      // Log or process the file
      log('✅ File selected successfully: $selectedFileName');
      log('📦 File size: ${fileBytes.length} bytes');
      log('🔤 File extension: $fileExtension');

      Get.snackbar('Success', 'File selected: $selectedFileName');
    } catch (e) {
      log('❌ Error picking file: $e');
      Get.snackbar('Error',
          'Failed to pick file. Please try again or select a different file.');
    }
  }

  // Alternative file picker method for better compatibility
  Future<void> uploadFileAlternative() async {
    try {
      log('📁 Starting alternative file picker...');

      // Try image picker first (for photos)
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );

        if (result != null && result.files.isNotEmpty) {
          final pickedFile = result.files.first;
          if (pickedFile.bytes != null) {
            file.value = pickedFile.bytes;
            fileName.value = pickedFile.name;
            Get.snackbar('Success', 'Image selected: ${pickedFile.name}');
            return;
          }
        }
      } catch (e) {
        log('⚠️ Image picker failed: $e');
      }

      // Try document picker
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          allowMultiple: false,
          withData: true,
        );

        if (result != null && result.files.isNotEmpty) {
          final pickedFile = result.files.first;
          if (pickedFile.bytes != null) {
            file.value = pickedFile.bytes;
            fileName.value = pickedFile.name;
            Get.snackbar('Success', 'Document selected: ${pickedFile.name}');
            return;
          }
        }
      } catch (e) {
        log('⚠️ Document picker failed: $e');
      }

      // Fallback to any file type
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.bytes != null) {
          file.value = pickedFile.bytes;
          fileName.value = pickedFile.name;
          Get.snackbar('Success', 'File selected: ${pickedFile.name}');
        } else {
          Get.snackbar('Error', 'Could not read file data');
        }
      } else {
        Get.snackbar('Info', 'No file selected');
      }
    } catch (e) {
      log('❌ Alternative file picker error: $e');
      Get.snackbar('Error', 'File selection failed: $e');
    }
  }

  Future<void> pickStoreLogo() async {
    try {
      log('🖼️ Starting store logo picker...');

      // Use image picker for store logo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      // If no file is selected
      if (result == null || result.files.isEmpty) {
        log('❌ No logo selected.');
        Get.snackbar('Info', 'No logo selected');
        return;
      }

      final pickedFile = result.files.first;
      log('🖼️ Logo picked: ${pickedFile.name}');
      log('📊 Logo size: ${pickedFile.size} bytes');

      // Access file data
      Uint8List? fileBytes = pickedFile.bytes;
      String selectedFileName = pickedFile.name;

      // If bytes are null, try to read from path (for some platforms)
      if (fileBytes == null && pickedFile.path != null) {
        log('⚠️ Logo bytes null, trying to read from path: ${pickedFile.path}');
        try {
          final file = File(pickedFile.path!);
          if (await file.exists()) {
            fileBytes = await file.readAsBytes();
            log('✅ Successfully read logo from path');
          }
        } catch (e) {
          log('❌ Failed to read logo from path: $e');
        }
      }

      if (fileBytes == null) {
        log('❌ Failed to read logo bytes.');
        Get.snackbar(
            'Error', 'Failed to read logo. Please try a different image.');
        return;
      }

      // Validate file extension (only images for logo)
      final fileExtension = selectedFileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png'];
      if (!allowedExtensions.contains(fileExtension)) {
        Get.snackbar(
            'Error', 'Only JPG and PNG images are allowed for store logo.');
        return;
      }

      // Check file size (max 2MB for logo to keep Base64 reasonable)
      if (fileBytes.length > 2 * 1024 * 1024) {
        Get.snackbar('Error', 'Logo size too large. Maximum 2MB allowed.');
        return;
      }

      // Convert to Base64
      String base64String = base64Encode(fileBytes);

      // Update reactive variables
      storeLogoBase64.value = base64String;
      storeLogoFileName.value = selectedFileName;

      // Log success
      log('✅ Store logo selected successfully: $selectedFileName');
      log('📦 Logo size: ${fileBytes.length} bytes');
      log('🔤 Logo extension: $fileExtension');
      log('📝 Base64 length: ${base64String.length} characters');

      Get.snackbar('Success', 'Store logo selected: $selectedFileName');
    } catch (e) {
      log('❌ Error picking store logo: $e');
      Get.snackbar('Error', 'Failed to pick store logo. Please try again.');
    }
  }

  Future<void> getSellerStatus() async {
    final user = _auth.currentUser;
    final seller =
        await _firestore.collection('sellersApplication').doc(user!.uid).get();
    sellerStatus.value = seller.data();
  }
}
