import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furnistore/src/user/firebase_service/auth_service.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = Get.put(AuthService());

  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  Future<void> getProduct({required String category}) async {
    try {
      // Fetch data from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      // Map the data to the products list
      products.value = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'category': doc['category'],
          'description': doc['description'],
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'],
        };
      }).toList();

      log('Successfully fetched products: ${products.length} items');
    } catch (e) {
      // Log the error message
      log('Error fetching products: $e');
    }
  }

  Future<void> insertCart({
    required String productId,
    required int quantity,
    required String userId,
  }) async {
    try {
      // Check if the product already exists in the cart for the user
      QuerySnapshot cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .where('product_id', isEqualTo: productId)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        // If the product exists, update the quantity
        DocumentSnapshot existingCartItem = cartSnapshot.docs.first;
        int existingQuantity = existingCartItem['quantity'];

        await existingCartItem.reference.update({
          'quantity': existingQuantity + quantity, // Increment quantity
        });
        log('Cart item quantity updated.');
      } else {
        // If the product does not exist, add it as a new item
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .add({
          'product_id': productId,
          'quantity': quantity,
        });
        log('New cart item added.');
      }
    } catch (e) {
      log('Error in insertCart: $e');
    }
  }

  RxList<Map<String, dynamic>> carts = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> productsCart = <Map<String, dynamic>>[].obs;

  Future<void> getUserCart({required String userId}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    carts.value = querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'product_id': doc['product_id'],
              'quantity': doc['quantity'],
            })
        .toList();
  }

  Future<void> getProductCart({required String productId}) async {
    try {
      // Fetch data from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('product_id', isEqualTo: productId)
          .get();

      // Map the data to the products list
      productsCart.value = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'category': doc['category'],
          'description': doc['description'],
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'],
        };
      }).toList();

      log('Successfully fetched products: ${products.length} items');
    } catch (e) {
      log('Error fetching products: $e');
    }
  }

  Future<void> updateCartQuantity(String cartId, int quantity) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .doc(cartId)
          .update({'quantity': quantity});
    } catch (e) {
      log('Error updating cart quantity: $e');
    }
  }

  Future<void> deleteCartItem(String cartId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .doc(cartId)
          .delete();
    } catch (e) {
      log('Error deleting cart item: $e');
    }
  }

  Future<void> getProductsInCart(List<dynamic> productIds) async {
    try {
      if (productIds.isNotEmpty) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();

        productsCart.value = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'category': doc['category'],
            'description': doc['description'],
            'name': doc['name'],
            'price': doc['price'],
            'image': doc['image'],
          };
        }).toList();
      }
    } catch (e) {
      log('Error fetching products: $e');
    }
  }

  Future<void> storeOrderData({
    required DateTime date,
    required String modeOfPayment,
    required String orderId,
    required List<Map<String, dynamic>> product,
    required String status,
    required int subTotal,
    required int total,
    required int totalItems,
    required String userId,
    required int deliveryFee,
  }) async {
    try {
      // Prepare the data map
      Map<String, dynamic> orderData = {
        'date': date,
        'mode_of_payment': modeOfPayment,
        'order_id': orderId,
        'products': product,
        'status': status,
        'sub_total': subTotal,
        'total': total,
        'total_items': totalItems,
        'user_id': userId,
        'delivery_fee': deliveryFee,
      };

      await _firestore.collection('orders').doc(orderId).set(orderData);

      log("Order data stored successfully.");
    } catch (e) {
      log("Failed to store order data: $e");
    }
  }

  RxList<Map<String, dynamic>> userCartInfo = <Map<String, dynamic>>[].obs;

  Future<void> getUserCartInfo() async {
    try {
      QuerySnapshot queryDocumentSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .get();

      userCartInfo.value = queryDocumentSnapshot.docs
          .map((doc) => {
                'product_id': doc['product_id'],
                'quantity': doc['quantity'],
              })
          .toList();

      log('Product IDs: $userCartInfo');
    } catch (e) {
      log('Error fetching product IDs: $e');
    }
  }

  Future<void> deleteCartForCheckout() async {
    try {
      // Fetch all documents in the 'cart' collection
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cart')
          .get();

      // Loop through and delete each document
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      log('Successfully deleted all cart items.');
    } catch (e) {
      log('Error deleting products: $e');
    }
  }

  RxList<Map<String, dynamic>> allProducts = <Map<String, dynamic>>[].obs;

  Future<void> getAllProduct() async {
    try {
      // Fetch data from Firestore
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();

      // Map the data to the products list
      allProducts.value = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'category': doc['category'],
          'description': doc['description'],
          'name': doc['name'],
          'price': doc['price'],
          'image': doc['image'],
        };
      }).toList();
    } catch (e) {
      log('Error $e');
    }
  }
}
