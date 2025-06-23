import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furnistore/src/app/firebase_service/auth_service.dart';
import 'package:furnistore/src/app/firebase_service/firestore_service.dart';
import 'package:get/get.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  String selectedValue = 'All Products';
  final _firestore = Get.put(FirestoreService());
  RxList<Map<String, dynamic>> filteredProducts =
      RxList<Map<String, dynamic>>();
  final _auth = Get.put(AuthService());

  @override
  void initState() {
    super.initState();
    _firestore.getAllProduct();
    filteredProducts.value = _firestore.allProducts;
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
                  'Brands',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 40),
            Container(
              height: 90,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'W',
                    style: TextStyle(fontSize: 40),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wilkris',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '265 Products',
                        style: TextStyle(fontSize: 20),
                      ),
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
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                  'Chairs',
                  'Tables',
                  'Sofas',
                  'Beds',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
              ),
            ),
            SizedBox(height: 40),
            Obx(() {
              // Listen to filtered products
              if (filteredProducts.isEmpty) {
                return const Center(child: Text('Products not Available'));
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
    VoidCallback onTap,
    Size size,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 10,
        color: Colors.white,
        child: Stack(
          children: [
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
                  ),
                  const SizedBox(height: 5),
                 Row(children: [ Icon(FontAwesomeIcons.pesoSign,size: 12,),Text(
                  ' $price',
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),],)
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
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
