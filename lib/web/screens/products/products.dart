import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:furnistore/web/screens/products/product_controller.dart';
import 'package:furnistore/web/screens/sidebar.dart';
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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    productController.fetchProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await productController.fetchProducts();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : (isTablet ? 30 : 30),
            vertical: isMobile ? 16 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Products",
                    style: TextStyle(
                      fontSize: isMobile ? 24 : (isTablet ? 26 : 30),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Refresh button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: _isRefreshing
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF3E6BE0)),
                              ),
                            )
                          : Icon(Icons.refresh, size: 18),
                      color: const Color(0xFF3E6BE0),
                      onPressed: _isRefreshing ? null : _refreshProducts,
                      tooltip: 'Refresh products',
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 30)),
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
                      child: SizedBox(
                        width: isMobile ? double.infinity : null,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Sidebar(
                                        initialIndex: 6,
                                      ))),
                          icon: Icon(Icons.add, size: isMobile ? 18 : 20),
                          label: Text(
                            'Add Product',
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E6BE0),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 20,
                              vertical: isMobile ? 12 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    Obx(() {
                      if (productController.products.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 32 : 48),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: isMobile ? 48 : 64,
                                    color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No products available',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (isMobile) {
                        // Mobile Card Layout
                        return Column(
                          children: List.generate(
                            productController.products.length,
                            (index) => _buildProductCard(
                              index,
                              productController.products[index],
                              isMobile,
                            ),
                          ),
                        );
                      } else {
                        // Desktop/Tablet Table Layout
                        return _buildProductTable(isTablet);
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(int index, dynamic product, bool isMobile) {
    Uint8List imageBytes = base64Decode(product['image']);
    bool isEditing = editingIndex == index;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    imageBytes,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isEditing
                          ? TextFormField(
                              initialValue: editedProducts[index]?['name'] ??
                                  product['name'],
                              decoration: InputDecoration(
                                labelText: 'Product Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (value) {
                                editedProducts[index] ??= Map.from(product);
                                editedProducts[index]!['name'] = value;
                              },
                            )
                          : Text(
                              product['name'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                isEditing
                                    ? TextFormField(
                                        initialValue: editedProducts[index]
                                                    ?['stock']
                                                ?.toString() ??
                                            product['stock'].toString(),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(fontSize: 14),
                                        onChanged: (value) {
                                          editedProducts[index] ??=
                                              Map.from(product);
                                          editedProducts[index]!['stock'] =
                                              int.tryParse(value) ?? 0;
                                        },
                                      )
                                    : Text(
                                        '${product['stock'] ?? '0'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                isEditing
                                    ? TextFormField(
                                        initialValue: editedProducts[index]
                                                    ?['price']
                                                ?.toString() ??
                                            product['price'].toString(),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(fontSize: 14),
                                        onChanged: (value) {
                                          editedProducts[index] ??=
                                              Map.from(product);
                                          editedProducts[index]!['price'] =
                                              double.tryParse(value) ?? 0.0;
                                        },
                                      )
                                    : Text(
                                        '₱${product['price'] ?? 0}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3E6BE0),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: isEditing
                      ? ElevatedButton.icon(
                          icon: Icon(Icons.save, size: 18),
                          label: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (editedProducts[index] != null) {
                              productController.updateProduct(
                                  product['id'], editedProducts[index]!);
                            }
                            setState(() {
                              editingIndex = null;
                            });
                          },
                        )
                      : OutlinedButton.icon(
                          icon: Icon(Icons.edit, size: 18),
                          label: Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              editingIndex = index;
                              editedProducts[index] = Map.from(product);
                            });
                          },
                        ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete, size: 18),
                    label: Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context, product['id']);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.only(
              left: isTablet ? 40 : 100,
              top: 15,
              bottom: 15,
              right: 16,
            ),
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
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 13 : 14))),
                Expanded(
                    flex: 2,
                    child: Text('Stock',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 13 : 14))),
                Expanded(
                    flex: 2,
                    child: Text('Price',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 13 : 14))),
                Expanded(
                    flex: 2,
                    child: Text('Action',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 13 : 14))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Table rows
          ...List.generate(productController.products.length, (index) {
            var product = productController.products[index];
            Uint8List imageBytes = base64Decode(product['image']);
            bool isEditing = editingIndex == index;

            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding:
                      EdgeInsets.only(left: isTablet ? 40 : 100, right: 16),
                  child: Row(
                    children: [
                      // Product image and name
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(imageBytes,
                                  width: isTablet ? 45 : 50,
                                  height: isTablet ? 45 : 50,
                                  gaplessPlayback: true,
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: isEditing
                                  ? TextFormField(
                                      initialValue: editedProducts[index]
                                              ?['name'] ??
                                          product['name'],
                                      style: TextStyle(
                                          fontSize: isTablet ? 13 : 14),
                                      onChanged: (value) {
                                        editedProducts[index] ??=
                                            Map.from(product);
                                        editedProducts[index]!['name'] = value;
                                      },
                                    )
                                  : Text(
                                      product['name'] ?? '',
                                      style: TextStyle(
                                          fontSize: isTablet ? 13 : 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                      ),

                      // Stock
                      Expanded(
                        flex: 2,
                        child: isEditing
                            ? SizedBox(
                                width: isTablet ? 80 : 100,
                                child: TextFormField(
                                  initialValue: editedProducts[index]?['stock']
                                          ?.toString() ??
                                      product['stock'].toString(),
                                  keyboardType: TextInputType.number,
                                  style:
                                      TextStyle(fontSize: isTablet ? 13 : 14),
                                  onChanged: (value) {
                                    editedProducts[index] ??= Map.from(product);
                                    editedProducts[index]!['stock'] =
                                        int.tryParse(value) ?? 0;
                                  },
                                ),
                              )
                            : Text(
                                '${product['stock'] ?? '0'}',
                                style: TextStyle(fontSize: isTablet ? 13 : 14),
                              ),
                      ),
                      // Price
                      Expanded(
                        flex: 2,
                        child: isEditing
                            ? SizedBox(
                                width: isTablet ? 80 : 100,
                                child: TextFormField(
                                  initialValue: editedProducts[index]?['price']
                                          ?.toString() ??
                                      product['price'].toString(),
                                  style:
                                      TextStyle(fontSize: isTablet ? 13 : 14),
                                  onChanged: (value) {
                                    editedProducts[index] ??= Map.from(product);
                                    editedProducts[index]!['price'] =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              )
                            : Text('₱ ${product['price'] ?? 0}',
                                style: TextStyle(fontSize: isTablet ? 13 : 14)),
                      ),
                      // Actions
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            isEditing
                                ? IconButton(
                                    icon: Icon(Icons.save,
                                        color: Colors.green,
                                        size: isTablet ? 20 : 24),
                                    onPressed: () {
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
                                    icon: Icon(Icons.edit,
                                        color: Colors.blue,
                                        size: isTablet ? 20 : 24),
                                    onPressed: () {
                                      setState(() {
                                        editingIndex = index;
                                        editedProducts[index] =
                                            Map.from(product);
                                      });
                                    },
                                  ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red, size: isTablet ? 20 : 24),
                              onPressed: () {
                                _showDeleteConfirmation(context, product['id']);
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
  }

  void _showDeleteConfirmation(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                productController.deleteProduct(productId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
