import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:furnistore/src/admin/screens/products/add_product.dart';
import 'package:furnistore/src/admin/screens/products/product_controller.dart';
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
      body: Column(
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 9, 66, 113),
                        borderRadius: BorderRadius.circular(5)),
                    child: TextButton(
                      onPressed: () => Get.to(() => const AddProduct()),
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
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            Colors.grey.withOpacity(.5)),
                        border: TableBorder(
                            borderRadius: BorderRadius.circular(12)),
                        dividerThickness: 0,
                        columnSpacing: 20.0,
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Product',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text('Category',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Price',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Action',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: List<DataRow>.generate(
                          productController.products.length,
                          (index) {
                            var product = productController.products[index];
                            Uint8List imageBytes =
                                base64Decode(product['image']);
                            bool isEditing = editingIndex == index;

                            return DataRow(cells: [
                              DataCell(Row(
                                children: [
                                  Image.memory(
                                    imageBytes,
                                    width: 40,
                                    height: 40,
                                    gaplessPlayback: true,
                                  ),
                                  const SizedBox(width: 10),
                                  isEditing
                                      ? SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            initialValue: editedProducts[index]
                                                    ?['name'] ??
                                                product['name'],
                                            onChanged: (value) {
                                              editedProducts[index] ??=
                                                  Map.from(product);
                                              editedProducts[index]!['name'] =
                                                  value;
                                            },
                                          ),
                                        )
                                      : Text(product['name']),
                                ],
                              )),
                              DataCell(Row(
                                children: [Text('${product['category']}')],
                              )),
                              DataCell(isEditing
                                  ? SizedBox(
                                      width: 100,
                                      child: TextFormField(
                                        initialValue: editedProducts[index]
                                                    ?['price']
                                                ?.toString() ??
                                            product['price'].toString(),
                                        onChanged: (value) {
                                          editedProducts[index] ??=
                                              Map.from(product);
                                          editedProducts[index]!['price'] =
                                              double.tryParse(value) ?? 0.0;
                                        },
                                      ),
                                    )
                                  : Text('₱ ${product['price']}')),
                              DataCell(Row(
                                children: [
                                  isEditing
                                      ? IconButton(
                                          icon: const Icon(Icons.save,
                                              color: Colors.green),
                                          onPressed: () {
                                            // Save the updated product
                                            if (editedProducts[index] != null) {
                                              productController.updateProduct(
                                                  product['id'],
                                                  editedProducts[index]!);
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
                                              editedProducts[index] = Map.from(
                                                  product); // Initialize edited product details
                                            });
                                          },
                                        ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      productController
                                          .deleteProduct(product['id']);
                                    },
                                  ),
                                ],
                              )),
                            ]);
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
