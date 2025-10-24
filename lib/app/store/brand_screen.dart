import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furnistore/app/firebase_service/firestore_service.dart';
import 'package:furnistore/app/add_to_cart_review_rates/cart/add_to_cart.dart';
import 'package:get/get.dart';

class BrandScreen extends StatefulWidget {
  final String? sellerId;
  final String? sellerName;

  const BrandScreen({super.key, this.sellerId, this.sellerName});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  String selectedValue = 'All Products';
  final _firestore = Get.put(FirestoreService());
  final _auth = FirebaseAuth.instance;
  RxList<Map<String, dynamic>> filteredProducts =
      RxList<Map<String, dynamic>>();
  String? storeLogoBase64;

  String _getInitials(String storeName) {
    if (storeName.isEmpty) return '?';

    final words = storeName.trim().split(' ');
    if (words.length == 1) {
      // Single word - take first 2 characters
      return storeName
          .substring(0, storeName.length > 2 ? 2 : storeName.length)
          .toUpperCase();
    } else {
      // Multiple words - take first character of each word (max 2)
      final initials =
          words.take(2).map((word) => word.isNotEmpty ? word[0] : '').join('');
      return initials.toUpperCase();
    }
  }

  Widget _buildStoreLogo(String? storeLogoBase64, String storeName) {
    if (storeLogoBase64 == null || storeLogoBase64.isEmpty) {
      // Fallback to initials if no logo
      final initials = _getInitials(storeName);
      return Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    try {
      // Decode the Base64 string to bytes
      final bytes = base64Decode(storeLogoBase64);

      return ClipOval(
        child: Image.memory(
          bytes,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to initials if image fails to load
            final initials = _getInitials(storeName);
            return Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      // Fallback to initials if Base64 decoding fails
      final initials = _getInitials(storeName);
      return Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _firestore.getAllProduct();
    if (widget.sellerId != null) {
      // Filter products by seller
      print('🔍 Filtering products for seller: ${widget.sellerId}');
      print('📦 Total products available: ${_firestore.allProducts.length}');

      // Debug: Print all seller IDs in products
      print('🔍 All seller IDs in products:');
      for (var product in _firestore.allProducts) {
        print(
            '  - Product: ${product['name']} | Seller ID: ${product['seller_id']}');
      }

      final sellerProducts = _firestore.allProducts
          .where((product) => product['seller_id'] == widget.sellerId)
          .toList();

      print('✅ Found ${sellerProducts.length} products for this seller');
      filteredProducts.value = sellerProducts;

      // Fetch store logo
      _fetchStoreLogo();
    } else {
      filteredProducts.value = _firestore.allProducts;
    }
  }

  Future<void> _fetchStoreLogo() async {
    if (widget.sellerId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('sellersApplication')
          .doc(widget.sellerId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          storeLogoBase64 = data['storeLogoBase64'];
        });
      }
    } catch (e) {
      print('Error fetching store logo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 70),
            Row(
              children: [
                IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded)),
                SizedBox(width: 15),
                Text(
                  widget.sellerName ?? 'Brands',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 40),
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: _buildStoreLogo(
                        storeLogoBase64, widget.sellerName ?? ''),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.sellerName ?? 'Unknown Store',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      Obx(() => Text(
                            '${filteredProducts.length} Products',
                            style: TextStyle(fontSize: 14),
                          )),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Products',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                underline: SizedBox(),
                items: [
                  'All Products',
                  'Chair',
                  'Table',
                  'Sofa',
                  'Bed',
                  'Lamp',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });

                  // Filter products based on selected category
                  if (newValue == 'All Products') {
                    if (widget.sellerId != null) {
                      filteredProducts.value = _firestore.allProducts
                          .where((product) =>
                              product['seller_id'] == widget.sellerId)
                          .toList();
                    } else {
                      filteredProducts.value = _firestore.allProducts;
                    }
                  } else {
                    if (widget.sellerId != null) {
                      filteredProducts.value = _firestore.allProducts
                          .where((product) =>
                              product['seller_id'] == widget.sellerId &&
                              product['category']?.toLowerCase() ==
                                  newValue!.toLowerCase())
                          .toList();
                    } else {
                      filteredProducts.value = _firestore.allProducts
                          .where((product) =>
                              product['category']?.toLowerCase() ==
                              newValue!.toLowerCase())
                          .toList();
                    }
                  }
                },
              ),
            ),
            SizedBox(height: 40),
            Obx(() {
              // Listen to filtered products
              if (filteredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.sellerId != null
                              ? 'No products available for this seller'
                              : 'No products available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.sellerId != null
                              ? 'This seller hasn\'t added any products yet'
                              : 'Try refreshing or check back later',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                padding: const EdgeInsets.all(16),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  final productName = product['name'] ?? 'Unnamed Product';
                  final productPrice = product['price'] ?? 0;
                  final productDescription =
                      product['description'] ?? 'No description';
                  final productImage = product['image'] ?? '';
                  final productId = product['id'] ?? '';

                  Uint8List imageBytes;
                  try {
                    imageBytes = base64Decode(productImage);
                  } catch (e) {
                    imageBytes = Uint8List(0);
                  }

                  return _buildProductCard(context, productName, productPrice,
                      imageBytes, productDescription, productId, () {
                    // Navigate to product details page
                    Get.to(() => ProductDetailsScreen(
                          nameProduct: productName,
                          description: productDescription,
                          price: productPrice,
                          imageBytes: imageBytes,
                          productId: productId,
                        ));
                  }, () {
                    // Add to cart functionality
                    _firestore.insertCart(
                      productId: productId,
                      quantity: 1,
                      userId: _auth.currentUser!.uid,
                    );
                  }, size);
                },
              );
            }),
          ],
        ),
      ),
    ));
  }

  Widget _buildProductCard(
    BuildContext context,
    String name,
    int price,
    Uint8List imageBytes,
    String description,
    String productId,
    VoidCallback onCardTap,
    VoidCallback onAddToCart,
    Size size,
  ) {
    return GestureDetector(
      onTap: onCardTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        color: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Stack(
          children: [
            // Clickable indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 12,
                  color: Colors.blue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.memory(
                      imageBytes,
                      height: size.height * 0.1,
                      width: size.width * 0.25,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.pesoSign,
                        size: 12,
                      ),
                      Text(
                        ' $price',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3E6BE0),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
