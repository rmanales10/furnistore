import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnistore/app/profile/apply/apply_controller.dart';
import 'package:furnistore/app/profile/apply/seller_status.dart';
import 'package:get/get.dart';

class ApplyAsSellerScreen extends StatefulWidget {
  const ApplyAsSellerScreen({super.key});

  @override
  State<ApplyAsSellerScreen> createState() => _ApplyAsSellerScreenState();
}

class _ApplyAsSellerScreenState extends State<ApplyAsSellerScreen> {
  final ApplyController controller = Get.put(ApplyController());
  final storeName = TextEditingController();
  final ownersName = TextEditingController();
  final ownersEmail = TextEditingController();
  final businessDescription = TextEditingController();
  bool isSubmitting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Apply as a Seller',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Fill out the form below to apply as a seller.\nYour application will be reviewed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                            label: 'Store Name',
                            hint: 'Enter your store name',
                            controller: storeName),
                        const SizedBox(height: 20),
                        _buildStoreLogoField(context),
                        const SizedBox(height: 20),
                        _buildTextField(
                            label: "Owner's Name",
                            hint: 'Enter your name',
                            controller: ownersName),
                        const SizedBox(height: 20),
                        _buildTextField(
                            label: 'Email/Contact',
                            hint: 'Enter email or phone number',
                            controller: ownersEmail),
                        const SizedBox(height: 20),
                        _buildTextField(
                            label: 'Business Description',
                            hint: 'Describe your business',
                            maxLines: 2,
                            controller: businessDescription),
                        const SizedBox(height: 20),
                        _buildFileUploadField(context),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isSubmitting = true;
                              });
                              await _submitApplication();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B5EDF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Submit Application',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required String hint,
      int maxLines = 1,
      required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey[400], fontFamily: 'Poppins'),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreLogoField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Store Logo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload your store logo (JPG, PNG - Max 2MB)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Obx(() {
            final hasLogo = controller.storeLogoBase64.value.isNotEmpty;
            return GestureDetector(
              onTap: () async {
                await controller.pickStoreLogo();
              },
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasLogo ? Colors.blue : Colors.grey[300]!,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasLogo
                          ? Image.memory(
                              base64Decode(controller.storeLogoBase64.value),
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.add_photo_alternate,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  if (hasLogo)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3E6BE0),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await controller.pickStoreLogo();
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final hasLogo = controller.storeLogoFileName.value.isNotEmpty;
          if (hasLogo) {
            return Column(
              children: [
                Text(
                  'Logo Selected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.storeLogoFileName.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await controller.pickStoreLogo();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Change Logo',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3E6BE0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  ),
                ),
              ],
            );
          } else {
            return Text(
              'Tap to upload store logo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            );
          }
        }),
      ],
    );
  }

  Widget _buildFileUploadField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Valid ID or Business Permit',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Supported formats: JPG, PNG, PDF, DOC, DOCX (Max 10MB)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasFile = controller.fileName.value.isNotEmpty;
          return GestureDetector(
            onTap: () async {
              await controller.uploadFile();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: hasFile ? Colors.green[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFile ? Colors.green : Colors.grey[300]!,
                  width: hasFile ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    hasFile ? Icons.check_circle : Icons.cloud_upload,
                    color: hasFile ? Colors.green : Colors.grey[600],
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasFile ? 'File Selected' : 'Tap to Upload File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: hasFile ? Colors.green[700] : Colors.grey[700],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (hasFile) ...[
                    const SizedBox(height: 8),
                    Text(
                      controller.fileName.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        await controller.uploadFile();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text(
                        'Change File',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3E6BE0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _submitApplication() async {
    if (controller.fileName.value.isEmpty ||
        storeName.text.isEmpty ||
        ownersName.text.isEmpty ||
        ownersEmail.text.isEmpty ||
        businessDescription.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all the fields');
      setState(() {
        isSubmitting = false;
      });
      return;
    }
    await controller.applyAsSeller(
        storeName: storeName.text,
        ownersName: ownersName.text,
        ownersEmail: ownersEmail.text,
        businessDescription: businessDescription.text);

    if (controller.isSuccess) {
      Get.to(() => SellerStatusScreen());
    } else {
      Get.snackbar('Error', 'Application submission failed');
    }
    setState(() {
      isSubmitting = false;
    });
    storeName.clear();
    ownersName.clear();
    ownersEmail.clear();
    businessDescription.clear();
    controller.fileName.value = '';
    controller.file.value = null;
    controller.storeLogoBase64.value = '';
    controller.storeLogoFileName.value = '';
  }

  @override
  void dispose() {
    storeName.dispose();
    ownersName.dispose();
    ownersEmail.dispose();
    businessDescription.dispose();
    controller.fileName.value = '';
    controller.file.value = null;
    controller.storeLogoBase64.value = '';
    controller.storeLogoFileName.value = '';
    super.dispose();
  }
}
