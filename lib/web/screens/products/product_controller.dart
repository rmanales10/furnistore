import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList products = [].obs;

  Future<void> addProduct(Map<String, dynamic> product) async {
    await _firestore.collection('products').add(product);
  }

  // Fetch products from Firestore
  Future<void> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('seller_id', isEqualTo: _auth.currentUser?.uid)
          .get();

      products.value = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      // log('Successfully fetched ${products.length} products from Firestore');
    } catch (e) {
      // log('Error fetching products: $e');
    }
  }

  // Delete a product from Firestore and all orders containing it
  Future<void> deleteProduct(String productId) async {
    try {
      // First, find all orders that contain this product
      final ordersSnapshot = await _firestore.collection('orders').get();
      final ordersToDelete = <String>[];

      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final products = orderData['products'] as List<dynamic>?;

        if (products != null && products.isNotEmpty) {
          // Check if any product in the order matches the deleted product
          bool containsProduct = false;
          for (var product in products) {
            if (product is Map<String, dynamic>) {
              // Check both 'product_id' and 'id' fields
              final orderProductId = product['product_id'] ?? product['id'];
              if (orderProductId != null &&
                  orderProductId.toString() == productId) {
                containsProduct = true;
                break;
              }
            }
          }

          if (containsProduct) {
            // Use order_id if available, otherwise use document ID
            final orderId = orderData['order_id'] ?? orderDoc.id;
            ordersToDelete.add(orderDoc.id); // Use document ID for deletion
            log('🗑️ Found order containing deleted product: $orderId');
          }
        }
      }

      // Delete all orders containing this product
      if (ordersToDelete.isNotEmpty) {
        log('🗑️ Deleting ${ordersToDelete.length} order(s) containing product: $productId');
        for (var orderDocId in ordersToDelete) {
          try {
            await _firestore.collection('orders').doc(orderDocId).delete();
            log('✅ Deleted order: $orderDocId');
          } catch (e) {
            log('❌ Error deleting order $orderDocId: $e');
          }
        }
      } else {
        log('ℹ️ No orders found containing product: $productId');
      }

      // Now delete the product itself
      await _firestore.collection('products').doc(productId).delete();
      products.removeWhere((product) => product['id'] == productId);
      log('✅ Product $productId deleted successfully');
    } catch (e) {
      log('❌ Error deleting product: $e');
      rethrow;
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

      // log('Product $productId updated successfully with data: $updatedData');
    } catch (e) {
      // log('Error updating product: $e');
    }
  }
}
