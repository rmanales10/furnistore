import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:furnistore/src/web/screens/products/product_controller.dart';
import 'package:furnistore/src/web/screens/sidebar.dart';
import 'package:get/get.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductController productController = Get.put(ProductController());
  int? editingIndex; // Track the index of the row being edited
  final Map<int, Map<String, dynamic>> editedProducts =
      {}; // Store edited product details

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Products",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: const Color(0xFF3E6BE0),
                          borderRadius: BorderRadius.circular(5)),
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Sidebar(
                                      initialIndex: 7,
                                    ))),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    productController.fetchProducts();
                    if (productController.products.isEmpty) {
                      return const Center(
                        child: Text('No products available'),
                      );
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.only(
                                left: 100, top: 15, bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text('Product',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Stock',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Price',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Action',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Table rows
                          ...List.generate(productController.products.length,
                              (index) {
                            var product = productController.products[index];
                            Uint8List imageBytes =
                                base64Decode(product['image']);
                            bool isEditing = editingIndex == index;

                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.only(left: 100),
                                  child: Row(
                                    children: [
                                      // Product image and name
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Image.memory(imageBytes,
                                                width: 50,
                                                height: 50,
                                                gaplessPlayback: true,
                                                fit: BoxFit.cover),
                                            const SizedBox(width: 10),
                                            isEditing
                                                ? SizedBox(
                                                    width: 100,
                                                    child: TextFormField(
                                                      initialValue:
                                                          editedProducts[index]
                                                                  ?['name'] ??
                                                              product['name'],
                                                      onChanged: (value) {
                                                        editedProducts[
                                                                index] ??=
                                                            Map.from(product);
                                                        editedProducts[index]![
                                                            'name'] = value;
                                                      },
                                                    ),
                                                  )
                                                : Text(product['name']),
                                          ],
                                        ),
                                      ),

                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${product['stock'] ?? '0'}',
                                        ),
                                      ),
                                      // Price
                                      Expanded(
                                        flex: 2,
                                        child: isEditing
                                            ? SizedBox(
                                                width: 100,
                                                child: TextFormField(
                                                  initialValue:
                                                      editedProducts[index]
                                                                  ?['price']
                                                              ?.toString() ??
                                                          product['price']
                                                              .toString(),
                                                  onChanged: (value) {
                                                    editedProducts[index] ??=
                                                        Map.from(product);
                                                    editedProducts[index]![
                                                            'price'] =
                                                        double.tryParse(
                                                                value) ??
                                                            0.0;
                                                  },
                                                ),
                                              )
                                            : Text('₱ ${product['price']}'),
                                      ),
                                      // Actions
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            isEditing
                                                ? IconButton(
                                                    icon: const Icon(Icons.save,
                                                        color: Colors.green),
                                                    onPressed: () {
                                                      if (editedProducts[
                                                              index] !=
                                                          null) {
                                                        productController
                                                            .updateProduct(
                                                                product['id'],
                                                                editedProducts[
                                                                    index]!);
                                                      }
                                                      setState(() {
                                                        editingIndex = null;
                                                      });
                                                    },
                                                  )
                                                : IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    onPressed: () {
                                                      setState(() {
                                                        editingIndex = index;
                                                        editedProducts[index] =
                                                            Map.from(product);
                                                      });
                                                    },
                                                  ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                productController.deleteProduct(
                                                    product['id']);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
