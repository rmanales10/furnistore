import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  // Fetch products from Firestore
  Future<void> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();

      products.value = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'], // Ensure Firestore has this field.
          'category': doc['category'],
          'description': doc['description'],
        };
      }).toList();

      log('Successfully fetched ${products.length} products from Firestore');
    } catch (e) {
      log('Error fetching products: $e');
    }
  }

  // Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      products.removeWhere((product) => product['id'] == productId);
      log('Product $productId deleted successfully');
    } catch (e) {
      log('Error deleting product: $e');
    }
  }

  // Update a product in Firestore
  Future<void> updateProduct(
      String productId, Map<String, dynamic> updatedData) async {
    try {
      // Update the product document in Firestore
      await _firestore
          .collection('products')
          .doc(productId)
          .update(updatedData);

      // Update the local list of products
      int index = products.indexWhere((product) => product['id'] == productId);
      if (index != -1) {
        products[index] = {
          ...products[index],
          ...updatedData,
        };
        products.refresh(); // Notify observers about the update
      }

      log('Product $productId updated successfully with data: $updatedData');
    } catch (e) {
      log('Error updating product: $e');
    }
  }
}
