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
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            await controller.uploadFile();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.file_present, color: Colors.grey[700]),
                const SizedBox(width: 10),
                Obx(() {
                  return Text(
                    controller.fileName.value.isEmpty
                        ? 'Upload File'
                        : controller.fileName.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontFamily: 'Poppins',
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
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
  }

  @override
  void dispose() {
    storeName.dispose();
    ownersName.dispose();
    ownersEmail.dispose();
    businessDescription.dispose();
    controller.fileName.value = '';
    controller.file.value = null;
    super.dispose();
  }
}
