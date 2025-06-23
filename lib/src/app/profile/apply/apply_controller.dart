import 'dart:io';
import 'dart:developer';
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
  Rx<File?> file = Rx<File?>(null);
  RxString fileName = RxString('');
  bool isSuccess = false;

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
      'status': 'pending',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
    isSuccess = true;
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      log('❌ No file selected.');
      return;
    }

    file.value = File(result.files.single.path!);
    fileName.value = result.files.single.name;
  }
}
