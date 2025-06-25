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

  // Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      products.removeWhere((product) => product['id'] == productId);
      // log('Product $productId deleted successfully');
    } catch (e) {
      // log('Error deleting product: $e');
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
