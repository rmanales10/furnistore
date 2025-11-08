import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furnistore/web/screens/products/product_controller.dart';
import 'package:furnistore/web/screens/sidebar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:furnistore/services/meshy_ai_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  final _productController = Get.put(ProductController());
  String? base64Image;
  String? generated3DModelUrl;
  Map<String, String>? allModelUrls;
  String? thumbnailUrl;
  List<Map<String, String>>? textureUrls;
  bool isGenerating3D = false;
  int? generationProgress;
  String? generationStatus;
  String? currentTaskId;

  final List<String> _categories = [
    'Chair',
    'Table',
    'Lamp',
    'Sofa',
    'Bed',
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Chair':
        return Icons.chair;
      case 'Table':
        return Icons.table_bar;
      case 'Lamp':
        return Icons.lightbulb_outline;
      case 'Sofa':
        return Icons.weekend;
      case 'Bed':
        return Icons.bed;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plain white header
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : (isTablet ? 24 : 32),
                  isMobile ? 20 : (isTablet ? 30 : 40),
                  isMobile ? 16 : (isTablet ? 24 : 32),
                  isMobile ? 20 : (isTablet ? 24 : 32),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Sidebar(
                                                initialIndex: 4,
                                              ))),
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      size: 18, color: Colors.black87),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Create Product',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: Color(0xFF667EEA), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'AI-Powered',
                                  style: TextStyle(
                                    color: Color(0xFF667EEA),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Sidebar(
                                            initialIndex: 4,
                                          ))),
                              icon: Icon(Icons.arrow_back_ios_new,
                                  size: isTablet ? 18 : 20,
                                  color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Create Product',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 24 : 28,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: Color(0xFF667EEA),
                                    size: isTablet ? 14 : 16),
                                SizedBox(width: isTablet ? 6 : 8),
                                Text(
                                  'AI-Powered',
                                  style: TextStyle(
                                    color: Color(0xFF667EEA),
                                    fontWeight: FontWeight.w600,
                                    fontSize: isTablet ? 11 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Main Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
              ),
              child: isMobile
                  ? Column(
                      children: [
                        // Basic Information Card
                        _buildBasicInfoCard(isMobile, isTablet),
                        SizedBox(height: 16),
                        // Price & Categories Card
                        _buildPriceCategoriesCard(isMobile, isTablet),
                        SizedBox(height: 16),
                        // Product Image Card
                        _buildProductImageCard(isMobile, isTablet),
                        SizedBox(height: 16),
                        // 3D Model Card
                        _build3DModelCard(isMobile, isTablet),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column - Basic Information & Price & Categories
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              // Basic Information Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Basic Information',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _nameController,
                                      cursorColor: const Color(0xFF667EEA),
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText: 'Enter product name',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade500),
                                        prefixIcon: const Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xFF667EEA)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF667EEA),
                                              width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _descController,
                                      minLines: 4,
                                      maxLines: 6,
                                      cursorColor: const Color(0xFF667EEA),
                                      style: const TextStyle(fontSize: 16),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Describe your product in detail...',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade500),
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.only(bottom: 60),
                                          child: Icon(
                                              Icons.description_outlined,
                                              color: Color(0xFF667EEA)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF667EEA),
                                              width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Price & Categories Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Price & Categories',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _stockController,
                                      cursorColor: const Color(0xFF667EEA),
                                      style: const TextStyle(fontSize: 16),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Enter stock quantity',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade500),
                                        prefixIcon: const Icon(Icons.inventory,
                                            color: Color(0xFF667EEA)),
                                        suffixText: 'units',
                                        suffixStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF667EEA),
                                              width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _priceController,
                                      cursorColor: const Color(0xFF667EEA),
                                      style: const TextStyle(fontSize: 16),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d{0,2}')),
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Enter price',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade500),
                                        prefixIcon: const Icon(
                                            Icons.attach_money,
                                            color: Color(0xFF667EEA)),
                                        prefixText: '₱ ',
                                        prefixStyle: const TextStyle(
                                            color: Color(0xFF667EEA),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF667EEA),
                                              width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: _selectedCategory,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                      items: _categories
                                          .map((cat) => DropdownMenuItem(
                                                value: cat,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      _getCategoryIcon(cat),
                                                      color: const Color(
                                                          0xFF667EEA),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(cat),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedCategory = val;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Choose product category',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade500),
                                        prefixIcon: const Icon(
                                            Icons.category_outlined,
                                            color: Color(0xFF667EEA)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF667EEA),
                                              width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                        suffixIcon: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Color(0xFF667EEA)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column - Product Image & 3D Model
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              // Product Image Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border:
                                      Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF667EEA)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: Color(0xFF667EEA),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Product Image',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: base64Image == null
                                              ? const Color(0xFFF8FAFC)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: base64Image == null
                                                ? Colors.grey.shade300
                                                : const Color(0xFF667EEA)
                                                    .withOpacity(0.3),
                                            width: 2,
                                          ),
                                          boxShadow: base64Image != null
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF667EEA)
                                                            .withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: base64Image == null
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.cloud_upload_outlined,
                                                    size: 48,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Upload Image',
                                                    style: TextStyle(
                                                      color: Color(0xFF667EEA),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child: Image.memory(
                                                  base64Decode(base64Image!),
                                                  fit: BoxFit.cover,
                                                  width: 120,
                                                  height: 120,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: SizedBox(
                                        width: 250,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            final ImagePicker picker =
                                                ImagePicker();
                                            final XFile? pickedImage =
                                                await picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);

                                            if (pickedImage != null) {
                                              final bytes = await pickedImage
                                                  .readAsBytes();
                                              final base64Image =
                                                  base64Encode(bytes);

                                              setState(() {
                                                this.base64Image = base64Image;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF667EEA),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 20),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 2,
                                          ),
                                          icon: const Icon(Icons.upload_file,
                                              size: 18),
                                          label: const Text(
                                            'Upload Image',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Manual check status button
                                    if (currentTaskId != null &&
                                        !isGenerating3D) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: 250,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            print(
                                                '🔍 Manually checking status for task: $currentTaskId');
                                            final status = await MeshyAIService
                                                .getTaskStatus(currentTaskId!);
                                            if (status != null) {
                                              setState(() {
                                                generationStatus =
                                                    status['status'];
                                                generationProgress =
                                                    status['progress'];
                                              });

                                              if (MeshyAIService
                                                  .isTaskCompleted(status)) {
                                                if (status['status'] ==
                                                    'SUCCEEDED') {
                                                  final modelUrl =
                                                      MeshyAIService
                                                          .getModelUrl(status);
                                                  final allUrls = MeshyAIService
                                                      .getAllModelUrls(status);
                                                  final thumbnail =
                                                      MeshyAIService
                                                          .getThumbnailUrl(
                                                              status);

                                                  setState(() {
                                                    generated3DModelUrl =
                                                        modelUrl;
                                                    allModelUrls = allUrls;
                                                    thumbnailUrl = thumbnail;
                                                  });
                                                }
                                              }

                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title:
                                                      const Text('Task Status'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Status: ${status['status']}'),
                                                      Text(
                                                          'Progress: ${status['progress']}%'),
                                                      if (status['status'] ==
                                                          'SUCCEEDED') ...[
                                                        const SizedBox(
                                                            height: 8),
                                                        const Text(
                                                            '✅ 3D model is ready!'),
                                                      ],
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            side: BorderSide(
                                                color: Colors.grey.shade400),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Check Status',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // 3D Model Generation Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border:
                                      Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF667EEA),
                                                Color(0xFF764BA2)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          '3D Model Generation',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667EEA)
                                            .withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF667EEA)
                                              .withOpacity(0.1),
                                        ),
                                      ),
                                      child: const Text(
                                        'Upload a product image and we\'ll generate a 3D model using AI',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF667EEA),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: base64Image != null &&
                                                  !isGenerating3D
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF667EEA),
                                                    Color(0xFF764BA2)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                          color: base64Image == null ||
                                                  isGenerating3D
                                              ? const Color(0xFFF8FAFC)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: base64Image != null &&
                                                    !isGenerating3D
                                                ? const Color(0xFF667EEA)
                                                    .withOpacity(0.3)
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: base64Image != null &&
                                                  !isGenerating3D
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF667EEA)
                                                            .withOpacity(0.2),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: isGenerating3D
                                            ? const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 32,
                                                    height: 32,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Color(
                                                                  0xFF667EEA)),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Generating...',
                                                    style: TextStyle(
                                                      color: Color(0xFF667EEA),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    base64Image != null
                                                        ? Icons.auto_awesome
                                                        : Icons
                                                            .auto_awesome_outlined,
                                                    size: 48,
                                                    color: base64Image != null
                                                        ? Colors.white
                                                        : Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    base64Image != null
                                                        ? 'Ready to Generate'
                                                        : 'Upload Image First',
                                                    style: TextStyle(
                                                      color: base64Image != null
                                                          ? Colors.white
                                                          : Colors
                                                              .grey.shade500,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: SizedBox(
                                        width: 250,
                                        child: ElevatedButton(
                                          onPressed: (base64Image != null &&
                                                  !isGenerating3D)
                                              ? () {
                                                  _generate3DModel();
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                (base64Image != null &&
                                                        !isGenerating3D)
                                                    ? const Color(0xFF3B82F6)
                                                    : Colors.grey.shade300,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: isGenerating3D
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        value: generationProgress !=
                                                                null
                                                            ? generationProgress! /
                                                                100
                                                            : null,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                            'Generating...'),
                                                        if (generationProgress !=
                                                            null)
                                                          Text(
                                                            '$generationProgress%',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                        if (currentTaskId !=
                                                            null)
                                                          Text(
                                                            'ID: ${currentTaskId!.substring(0, 8)}...',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        10),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  base64Image != null
                                                      ? (generated3DModelUrl !=
                                                              null
                                                          ? (allModelUrls !=
                                                                      null &&
                                                                  allModelUrls!
                                                                      .isNotEmpty
                                                              ? '3D Model Ready (${allModelUrls!.length} formats)'
                                                              : '3D Model Ready')
                                                          : 'Generate 3D Model')
                                                      : 'Upload Image First',
                                                  style: TextStyle(
                                                    color: (base64Image !=
                                                                null &&
                                                            !isGenerating3D)
                                                        ? Colors.white
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            // Enhanced Footer Buttons
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : (isTablet ? 24 : 32)),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: isMobile
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.grey.shade600, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'All fields are required',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _nameController.clear();
                                  _descController.clear();
                                  _stockController.clear();
                                  _priceController.clear();
                                  setState(() {
                                    _selectedCategory = null;
                                    base64Image = null;
                                    generated3DModelUrl = null;
                                    allModelUrls = null;
                                    thumbnailUrl = null;
                                    textureUrls = null;
                                    isGenerating3D = false;
                                    generationProgress = null;
                                    generationStatus = null;
                                    currentTaskId = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Clear',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667EEA),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                ),
                                onPressed: addProduct,
                                icon: const Icon(Icons.save, size: 16),
                                label: const Text('Create Product',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.grey.shade600, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'All fields are required to create a product',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _nameController.clear();
                                _descController.clear();
                                _stockController.clear();
                                _priceController.clear();
                                setState(() {
                                  _selectedCategory = null;
                                  base64Image = null;
                                  generated3DModelUrl = null;
                                  allModelUrls = null;
                                  thumbnailUrl = null;
                                  textureUrls = null;
                                  isGenerating3D = false;
                                  generationProgress = null;
                                  generationStatus = null;
                                  currentTaskId = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text('Clear All',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667EEA),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                              ),
                              onPressed: addProduct,
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('Create Product',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _generate3DModel() async {
    if (base64Image == null) return;

    // Show cost confirmation dialog
    final estimatedCost = MeshyAIService.getEstimatedCost();
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('3D Model Generation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'This will generate a 3D model from your product image using AI.'),
            const SizedBox(height: 16),
            Text(
              'Estimated Cost: $estimatedCost credits',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Features included:\n• High-quality 3D model\n• PBR materials\n• Multiple formats (GLB, OBJ, etc.)\n• Thumbnail preview',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Do you want to proceed?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    setState(() {
      isGenerating3D = true;
    });

    try {
      // Test API connection first
      print('🧪 Testing Meshy AI API connection...');
      final isConnected = await MeshyAIService.testConnection();

      if (!isConnected) {
        throw Exception(
            'Unable to connect to Meshy AI API. Please check your internet connection and API key.');
      }

      print('✅ API connection successful, starting 3D generation...');

      // Start 3D generation
      final taskId = await MeshyAIService.generate3DModel(base64Image!);
      currentTaskId = taskId;

      print('🎯 Task created with ID: $taskId');
      print(
          '💡 You can check the status manually or wait for automatic polling...');

      // Poll for completion
      await _pollFor3DModelCompletion(taskId);
    } catch (e) {
      setState(() {
        isGenerating3D = false;
        currentTaskId = null;
      });

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('3D Generation Failed'),
          content: Text('Failed to generate 3D model: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pollFor3DModelCompletion(String taskId) async {
    while (isGenerating3D) {
      try {
        final statusResponse =
            await MeshyAIService.checkGenerationStatus(taskId);

        // Update progress and status
        setState(() {
          generationProgress = MeshyAIService.getProgress(statusResponse);
          generationStatus = statusResponse['status'];
        });

        if (MeshyAIService.isFailed(statusResponse)) {
          throw Exception(
              '3D generation failed: ${statusResponse['error'] ?? 'Unknown error'}');
        }

        if (statusResponse['status'] == 'SUCCEEDED') {
          final modelUrl = MeshyAIService.getModelUrl(statusResponse);
          if (modelUrl != null) {
            // Get all model URLs, thumbnail, and texture URLs
            final allUrls = MeshyAIService.getAllModelUrls(statusResponse);
            final thumbnail = MeshyAIService.getThumbnailUrl(statusResponse);
            final textures = MeshyAIService.getTextureUrls(statusResponse);

            setState(() {
              generated3DModelUrl = modelUrl;
              allModelUrls = allUrls;
              thumbnailUrl = thumbnail;
              textureUrls = textures;
              isGenerating3D = false;
              generationProgress = 100;
              generationStatus = 'SUCCEEDED';
            });

            // Show success dialog with more details

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('3D Model Generated Successfully!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Your 3D model has been successfully generated!'),
                    if (allModelUrls != null && allModelUrls!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Available formats:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...allModelUrls!.keys
                          .map((format) => Text('• $format: Available')),
                    ],
                    if (thumbnailUrl != null) ...[
                      const SizedBox(height: 8),
                      const Text('Thumbnail preview is also available.'),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            break;
          }
        }

        // Wait 3 seconds before checking again (reduced from 5 for better UX)
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        setState(() {
          isGenerating3D = false;
          generationProgress = null;
          generationStatus = 'FAILED';
        });
        rethrow;
      }
    }
  }

  // Helper method builders for mobile layout
  Widget _buildBasicInfoCard(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          TextField(
            controller: _nameController,
            cursorColor: const Color(0xFF667EEA),
            style: TextStyle(fontSize: isMobile ? 14 : 16),
            decoration: InputDecoration(
              hintText: 'Enter product name',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFF667EEA)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          TextField(
            controller: _descController,
            minLines: 4,
            maxLines: 6,
            cursorColor: const Color(0xFF667EEA),
            style: TextStyle(fontSize: isMobile ? 14 : 16),
            decoration: InputDecoration(
              hintText: 'Describe your product in detail...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 60),
                child:
                    Icon(Icons.description_outlined, color: Color(0xFF667EEA)),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCategoriesCard(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price & Categories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          TextField(
            controller: _stockController,
            cursorColor: const Color(0xFF667EEA),
            style: TextStyle(fontSize: isMobile ? 14 : 16),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              hintText: 'Enter stock quantity',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.inventory, color: Color(0xFF667EEA)),
              suffixText: 'units',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            cursorColor: const Color(0xFF667EEA),
            style: TextStyle(fontSize: isMobile ? 14 : 16),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: 'Enter price',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon:
                  const Icon(Icons.attach_money, color: Color(0xFF667EEA)),
              prefixText: '₱ ',
              prefixStyle: const TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            style:
                TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.black87),
            items: _categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(cat),
                              color: const Color(0xFF667EEA), size: 20),
                          const SizedBox(width: 12),
                          Text(cat),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val),
            decoration: InputDecoration(
              hintText: 'Choose product category',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon:
                  const Icon(Icons.category_outlined, color: Color(0xFF667EEA)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF667EEA), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImageCard(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Image',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Center(
            child: Container(
              width: isMobile ? 100 : 120,
              height: isMobile ? 100 : 120,
              decoration: BoxDecoration(
                color: base64Image == null
                    ? const Color(0xFFF8FAFC)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: base64Image == null
                      ? Colors.grey.shade300
                      : const Color(0xFF667EEA).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: base64Image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: isMobile ? 36 : 48,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Upload',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(base64Decode(base64Image!),
                          fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 250,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    final bytes = await pickedImage.readAsBytes();
                    setState(() => base64Image = base64Encode(bytes));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12 : 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.upload_file, size: isMobile ? 16 : 18),
                label: Text('Upload Image',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 13 : 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DModelCard(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3D Model Generation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Upload a product image and we\'ll generate a 3D model using AI',
              style: TextStyle(
                  fontSize: isMobile ? 12 : 13, color: const Color(0xFF667EEA)),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Center(
            child: Container(
              width: isMobile ? 100 : 120,
              height: isMobile ? 100 : 120,
              decoration: BoxDecoration(
                gradient: base64Image != null && !isGenerating3D
                    ? const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)])
                    : null,
                color: base64Image == null || isGenerating3D
                    ? const Color(0xFFF8FAFC)
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: isGenerating3D
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3)),
                        SizedBox(height: 8),
                        Text('Generating...', style: TextStyle(fontSize: 12)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          base64Image != null
                              ? Icons.auto_awesome
                              : Icons.auto_awesome_outlined,
                          size: isMobile ? 36 : 48,
                          color: base64Image != null
                              ? Colors.white
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          base64Image != null ? 'Ready' : 'Upload First',
                          style: TextStyle(
                            color: base64Image != null
                                ? Colors.white
                                : Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 250,
              child: ElevatedButton(
                onPressed: (base64Image != null && !isGenerating3D)
                    ? _generate3DModel
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (base64Image != null && !isGenerating3D)
                      ? const Color(0xFF3B82F6)
                      : Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  generated3DModelUrl != null
                      ? '3D Model Ready'
                      : 'Generate 3D Model',
                  style: TextStyle(
                    color: (base64Image != null && !isGenerating3D)
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addProduct() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_stockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter stock quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a product image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final product = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'category': _selectedCategory,
        'image': base64Image,
        // 3D Model Information
        'model_3d': {
          'primary_url': generated3DModelUrl, // Main GLB URL
          'model_urls': allModelUrls, // All available formats (GLB, OBJ, etc.)
          'thumbnail_url': thumbnailUrl, // Thumbnail preview
          'texture_urls': textureUrls, // PBR texture maps
          'generation_status': generationStatus, // SUCCEEDED, FAILED, etc.
          'generated_at':
              generated3DModelUrl != null ? FieldValue.serverTimestamp() : null,
        },
        'seller_id': _auth.currentUser?.uid,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _productController.addProduct(product);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to Products page (index 4 in sidebar)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Sidebar(initialIndex: 4),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating product: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
