import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/app/profile/edit_profile/profile_controller.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar in body
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageBytes != null
                                  ? MemoryImage(_imageBytes!)
                                  : (_controller.userInfo['image'] != null &&
                                          _controller.userInfo['image']
                                              .toString()
                                              .isNotEmpty
                                      ? _buildProfileImageFromBase64(_controller
                                          .userInfo['image']
                                          .toString())
                                      : const AssetImage(
                                              'assets/no_profile.webp')
                                          as ImageProvider),
                              child: _imageBytes == null &&
                                      (_controller.userInfo['image'] == null ||
                                          _controller.userInfo['image']
                                              .toString()
                                              .isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[400],
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF3E6BE0),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: pickImageAndProcess,
                                  icon: const Icon(Icons.edit),
                                  color: Colors.white,
                                  iconSize: 16,
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
                              backgroundColor: Color(0xFF3E6BE0),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImageAndProcess() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image to reduce size
        maxWidth: 1024, // Limit image dimensions
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        // Validate file extension
        final fileName = pickedFile.name.toLowerCase();
        final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
        final hasValidExtension =
            validExtensions.any((ext) => fileName.endsWith(ext));

        if (!hasValidExtension) {
          Get.snackbar(
            'Invalid File Type',
            'Please select an image file (JPG, PNG, or WEBP)',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          log("Invalid file type selected: $fileName");
          return;
        }

        Uint8List imageBytes;
        if (kIsWeb) {
          // For Web: Read image as bytes
          imageBytes = await pickedFile.readAsBytes();
          log("Image selected on Web: ${imageBytes.lengthInBytes} bytes");
        } else {
          // For Native: Use File
          final File nativeImageFile = File(pickedFile.path);
          imageBytes = await nativeImageFile.readAsBytes();
          log("Image selected on Native: ${nativeImageFile.path}");
        }

        // Validate file size (max 2MB)
        const maxSizeInBytes = 2 * 1024 * 1024; // 2MB
        if (imageBytes.length > maxSizeInBytes) {
          Get.snackbar(
            'File Too Large',
            'Please select an image smaller than 2MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          log("Image too large: ${imageBytes.lengthInBytes} bytes");
          return;
        }

        // Validate that it's actually an image by checking magic bytes
        if (!_isValidImage(imageBytes)) {
          Get.snackbar(
            'Invalid Image',
            'The selected file is not a valid image. Please try another file.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          log("Invalid image file detected");
          return;
        }

        setState(() {
          _imageBytes = imageBytes;
          base64Image = base64Encode(imageBytes);
        });
        log("✅ Image processed successfully: ${imageBytes.lengthInBytes} bytes");
      } else {
        log("No image selected.");
      }
    } catch (e) {
      log("Error picking image: $e");
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Validate image by checking magic bytes (file signature)
  bool _isValidImage(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // Check for common image file signatures
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) return true;
    // WEBP: Check for "RIFF" and "WEBP"
    if (bytes.length >= 12) {
      final header = String.fromCharCodes(bytes.sublist(0, 4));
      final webpHeader = String.fromCharCodes(bytes.sublist(8, 12));
      if (header == 'RIFF' && webpHeader == 'WEBP') return true;
    }

    return false;
  }

  void saveProfileInfo() {
    // Validate name
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your full name',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Validate image if a new one was selected
    String? imageToSave = base64Image ?? _controller.userInfo['image'];

    // If there's an existing image, validate it before saving
    if (imageToSave != null && imageToSave.isNotEmpty && base64Image == null) {
      // Only validate existing image if we're not replacing it
      // (base64Image is null means we're keeping the existing one)
      try {
        String cleanBase64 = imageToSave;
        if (imageToSave.contains(',')) {
          cleanBase64 = imageToSave.split(',').last;
        }
        final bytes = base64Decode(cleanBase64);
        if (!_isValidImage(bytes)) {
          // Existing image is invalid, clear it
          log("⚠️ Existing profile image is invalid, clearing it");
          imageToSave = null;
        }
      } catch (e) {
        // Existing image is corrupted, clear it
        log("⚠️ Existing profile image is corrupted, clearing it: $e");
        imageToSave = null;
      }
    }

    _controller.setProfileInfo(
      name: nameController.text.trim(),
      image: imageToSave ?? '',
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

  // Helper method to safely decode and create ImageProvider from base64
  ImageProvider _buildProfileImageFromBase64(String base64String) {
    try {
      // Validate base64 string
      if (base64String.isEmpty) {
        return const AssetImage('assets/no_profile.webp') as ImageProvider;
      }

      // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      // Decode base64
      final bytes = base64Decode(cleanBase64);

      // Validate that decoded bytes are actually an image
      if (!_isValidImage(bytes)) {
        log("⚠️ Invalid image data in profile, using default");
        return const AssetImage('assets/no_profile.webp') as ImageProvider;
      }

      return MemoryImage(bytes);
    } catch (e) {
      log("❌ Error decoding profile image: $e");
      // If decoding fails, return default image
      return const AssetImage('assets/no_profile.webp') as ImageProvider;
    }
  }
}
