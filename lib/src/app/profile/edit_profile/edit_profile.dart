import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/src/app/profile/edit_profile/profile_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController _controller = Get.put(ProfileController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? base64Image;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Profile Picture with Edit Icon

                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (_controller.userInfo['image'] != null
                              ? MemoryImage(
                                  base64Decode(_controller.userInfo['image']))
                              : const AssetImage('assets/no_profile.webp')
                                  as ImageProvider),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: pickImageAndProcess,
                          icon: const Icon(Icons.edit),
                          color: Colors.white,
                          iconSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Form Fields
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey[100],
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: false,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey[100],
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                // Save Changes Button
                Center(
                  child: ElevatedButton(
                    onPressed: saveProfileInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> pickImageAndProcess() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          // For Web: Read image as bytes
          final Uint8List webImageBytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = webImageBytes;
            base64Image = base64Encode(webImageBytes);
          });
          log("Image selected on Web: ${webImageBytes.lengthInBytes} bytes");
        } else {
          // For Native: Use File
          final File nativeImageFile = File(pickedFile.path);
          final Uint8List nativeImageBytes =
              await nativeImageFile.readAsBytes();
          setState(() {
            _imageBytes = nativeImageBytes;
            base64Image = base64Encode(nativeImageBytes);
          });
          log("Image selected on Native: ${nativeImageFile.path}");
        }
      } else {
        log("No image selected.");
      }
    } catch (e) {
      log("Error picking image: $e");
    }
  }

  void saveProfileInfo() {
    _controller.setProfileInfo(
      name: nameController.text,
      image: base64Image ?? _controller.userInfo['image'],
    );

    Get.back(closeOverlays: true);
    Get.snackbar('Success', 'Profile saved successfully!');
    _controller.getUserInfo();
  }

  @override
  void dispose() {
    // Dispose the controller to avoid memory leaks
    nameController.dispose();
    super.dispose();
  }

  Future<void> initProfile() async {
    await _controller.getUserInfo();
    setState(() {
      nameController.text = _controller.userInfo['name'] ?? 'Default';
      emailController.text = _controller.userInfo['email'] ?? 'Default';
    });
  }
}
