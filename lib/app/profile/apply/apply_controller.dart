import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';
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
  bool isSuccess = false;
  Rx<Map<String, dynamic>?> sellerStatus = Rx<Map<String, dynamic>?>(null);

  Future<void> applyAsSeller(
      {required String storeName,
      required String ownersName,
      required String ownersEmail,
      required String businessDescription}) async {
    if (_auth.currentUser == null) {
      log('❌ User not logged in.');
      return;
    }
    final form = FormData({
      'upload_preset': uploadPreset,
      'file': MultipartFile(file.value!, filename: fileName.value),
    });

    final response = await _connect.post(
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
      form,
    );

    if (response.statusCode == 200) {
      log('✅ Upload successful!');
      log('🌐 URL: ${response.body['secure_url']}');
    } else {
      log('❌ Upload failed: ${response.statusCode}');
      log(response.bodyString.toString());
    }
    final user = _auth.currentUser;
    await _firestore.collection('sellersApplication').doc(user!.uid).set({
      'storeName': storeName,
      'ownerName': ownersName,
      'ownersEmail': ownersEmail,
      'businessDescription': businessDescription,
      'file': response.body['secure_url'],
      'status': 'Pending',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
    isSuccess = true;
  }

  Future<void> uploadFile() async {
    // Open the file picker
    final result = await FilePicker.platform.pickFiles();

    // If no file is selected
    if (result == null) {
      log('❌ No file selected.');
      return;
    }

    // Access file data
    Uint8List? fileBytes = result.files.first.bytes;
    String fileName = result.files.first.name;

    if (fileBytes == null) {
      log('❌ Failed to read file bytes.');
      return;
    }

    // Log or process the file
    log('✅ File selected: $fileName');
    log('📦 File size: ${fileBytes.length} bytes');

    // TODO: Upload fileBytes to server or cloud service
  }

  Future<void> getSellerStatus() async {
    final user = _auth.currentUser;
    final seller =
        await _firestore.collection('sellersApplication').doc(user!.uid).get();
    sellerStatus.value = seller.data();
  }
}
