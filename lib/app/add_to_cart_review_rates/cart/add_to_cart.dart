import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furnistore/app/add_to_cart_review_rates/cart/model_viewer_screen.dart';
import 'package:furnistore/app/add_to_cart_review_rates/reviews/reviews_rating.dart';
import 'package:furnistore/app/add_to_cart_review_rates/reviews/reviews_controller.dart';
import 'package:furnistore/app/firebase_service/firestore_service.dart';
import 'package:furnistore/services/glb_file_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ProductDetailsScreen extends StatefulWidget {
  String nameProduct;
  String description;
  int price;
  Uint8List imageBytes;
  String productId;
  ProductDetailsScreen(
      {super.key,
      required this.nameProduct,
      required this.description,
      required this.price,
      required this.imageBytes,
      required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _counter = 1.obs;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final _firestore = Get.put(FirestoreService());
  final _auth = FirebaseAuth.instance;
  final _reviewsController = Get.put(ReviewsController());

  // GLB cache related variables
  bool _isGlbCached = false;
  bool _isDownloading = false;
  bool _isGlbReady = false;
  String? _glbUrl;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Define the scale animation
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize GLB cache check
    _initializeGlbCache();
  }

  Future<void> _initializeGlbCache() async {
    await _checkGlbCacheStatus();
  }

  Future<void> _checkGlbCacheStatus() async {
    try {
      // Get product data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final model3d = (data['model_3d'] ?? {}) as Map<String, dynamic>;
        final modelUrls = (model3d['model_urls'] ?? {}) as Map<String, dynamic>;

        // Get GLB URL
        _glbUrl = (modelUrls['glb'] ?? model3d['primary_url']) as String?;

        if (_glbUrl != null && _glbUrl!.isNotEmpty) {
          // Check if GLB is cached
          final isCached = await GlbFileService.isGlbCached(_glbUrl!);

          if (mounted) {
            setState(() {
              _isGlbCached = isCached;
              _isGlbReady = isCached; // GLB is ready if it's cached
            });
          }
        } else {
          // No GLB URL available
          if (mounted) {
            setState(() {
              _isGlbReady = false;
              _isGlbCached = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error checking GLB cache status: $e');
    }
  }

  Future<void> _downloadGlb() async {
    if (_glbUrl == null || _isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // Download and cache the GLB file
      final localPath = await GlbFileService.getOrDownloadGlb(_glbUrl!);

      if (localPath != null) {
        setState(() {
          _isGlbCached = true;
          _isGlbReady = true;
          _isDownloading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '3D model downloaded successfully! You can now view it in AR.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to download GLB file');
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download 3D model: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _refreshCacheStatus() async {
    await _checkGlbCacheStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart() async {
    // Trigger the animation
    await _animationController.forward();
    _animationController.reverse();

    // Show snackbar notification
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.nameProduct} added to cart!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCacheStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Obx(() {
              _reviewsController.getAllReviews(productId: widget.productId);
              final List<Map<String, dynamic>> review =
                  List<Map<String, dynamic>>.from(
                      _reviewsController.allReviews['reviews'] ?? []);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Image.memory(
                        widget.imageBytes,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Title, Price, and Rating

                  Row(
                    children: [
                      Text(
                        widget.nameProduct,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      // View in AR button with download icon
                      Row(
                        children: [
                          // Download icon (only show if not ready)
                          if (!_isGlbReady && _glbUrl != null) ...[
                            Tooltip(
                              message: _isDownloading
                                  ? 'Downloading 3D model...'
                                  : 'Download 3D model for offline viewing',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isDownloading
                                      ? Colors.orange
                                      : Colors.grey[600],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  onPressed:
                                      _isDownloading ? null : _downloadGlb,
                                  icon: _isDownloading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.download,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // View in AR button
                          Tooltip(
                            message: _isGlbReady
                                ? (_isGlbCached
                                    ? 'View 3D model (cached - fast loading)'
                                    : 'View 3D model in AR')
                                : 'Download 3D model first to view in AR',
                            child: ElevatedButton(
                              onPressed: _isGlbReady
                                  ? () => Get.to(() => ModelViewerScreen(
                                        productId: widget.productId,
                                        glbUrl: _glbUrl,
                                      ))
                                  : null, // Disable button if not ready
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isGlbReady
                                    ? const Color(0xFF3E6BE0)
                                    : Colors.grey[400],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isGlbReady
                                        ? 'View in AR'
                                        : 'Download First',
                                    style: TextStyle(
                                      color: _isGlbReady
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_isGlbCached && _isGlbReady) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.offline_pin,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Text(
                    '₱ ${widget.price}',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(${review.length} Reviews)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product Description
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews (${review.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                          onTap: () => Get.to(() => ReviewsScreen(
                                productId: widget.productId,
                              )),
                          child: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quantity Selector and Add to Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() => Row(
                              children: [
                                IconButton(
                                  onPressed: () => _counter.value <= 1
                                      ? null
                                      : _counter.value--,
                                  icon: const Icon(Icons.remove, size: 18),
                                ),
                                Text(
                                  _counter.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: () => _counter.value++,
                                  icon: const Icon(Icons.add, size: 18),
                                ),
                              ],
                            )),
                      ),

                      // Add to Cart Button with Animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton(
                          onPressed: () {
                            _addToCart();
                            _firestore.insertCart(
                                productId: widget.productId,
                                quantity: _counter.value,
                                userId: _auth.currentUser!.uid);
                            // _firestore.insertCart(productId: widget.productId, quantity: _counter.value, userId: userId)
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16), // Adjust button size
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
