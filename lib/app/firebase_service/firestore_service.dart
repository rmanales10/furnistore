import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
          'seller_id': doc['seller_id'],
          'stock': doc['stock'],
        };
      }).toList();

      // log('Successfully fetched products: ${products.length} items');
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
          'seller_id': doc['seller_id'],
          'stock': doc['stock'],
        };
      }).toList();

      // log('Successfully fetched products: ${products.length} items');
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
      // Reduce stock for each product in the order
      await _reduceProductStock(product);

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
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('orders').doc(orderId).set(orderData);

      log("✅ Order data stored successfully and stock reduced.");
    } catch (e) {
      log("❌ Failed to store order data: $e");
    }
  }

  // Get detailed order information
  Future<Map<String, dynamic>?> getOrderDetails(
      {required String orderId}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('order_id', isEqualTo: orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> orderData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

        log('🔍 FirestoreService - Raw order data: $orderData');
        log('🔍 FirestoreService - Products field: ${orderData['products']}');
        log('🔍 FirestoreService - Products type: ${orderData['products'].runtimeType}');

        // Get user information for delivery details
        String userId = orderData['user_id'] ?? '';
        Map<String, dynamic> userData = {};

        if (userId.isNotEmpty) {
          try {
            DocumentSnapshot userDoc =
                await _firestore.collection('users').doc(userId).get();

            if (userDoc.exists) {
              userData = userDoc.data() as Map<String, dynamic>;
            }
          } catch (e) {
            log('Error fetching user data: $e');
          }
        }

        Map<String, dynamic> result = {
          ...orderData,
          'user_name':
              userData['name'] ?? userData['username'] ?? 'Unknown User',
          'user_email': userData['email'] ?? 'No email provided',
          'delivery_address': userData['address'] ?? 'No address provided',
          'town_city': userData['town_city'] ?? '',
          'postcode': userData['postcode'] ?? '',
          'phone_number':
              userData['phone_number'] ?? userData['phoneNumber'] ?? '',
        };

        log('🔍 FirestoreService - Final result products: ${result['products']}');
        log('🔍 FirestoreService - Final result products type: ${result['products'].runtimeType}');

        return result;
      }
      return null;
    } catch (e) {
      log('Error fetching order details: $e');
      return null;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('order_id', isEqualTo: orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'status': newStatus,
          'updated_at': FieldValue.serverTimestamp(),
        });
        return true;
      }
      return false;
    } catch (e) {
      log('Error updating order status: $e');
      return false;
    }
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders(
      {required String userId}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'order_id': data['order_id'],
          'status': data['status'],
          'date': data['date'],
          'total': data['total'],
          'total_items': data['total_items'],
          'products': data['products'],
        };
      }).toList();
    } catch (e) {
      log('Error fetching user orders: $e');
      return [];
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

      // log('Product IDs: $userCartInfo');
    } catch (e) {
      log('Error fetching product IDs: $e');
    }
  }

  /// Reduce stock for products in an order
  Future<void> _reduceProductStock(List<Map<String, dynamic>> products) async {
    try {
      for (Map<String, dynamic> product in products) {
        String productId = product['id'] ?? product['product_id'] ?? '';
        int quantity = product['quantity'] ?? 1;

        if (productId.isNotEmpty) {
          // Get current stock
          DocumentSnapshot productDoc =
              await _firestore.collection('products').doc(productId).get();

          if (productDoc.exists) {
            Map<String, dynamic> productData =
                productDoc.data() as Map<String, dynamic>;
            int currentStock = productData['stock'] ?? 0;
            int newStock = currentStock - quantity;

            // Ensure stock doesn't go below 0
            if (newStock < 0) {
              log('⚠️ Warning: Product $productId stock would go negative. Setting to 0.');
              newStock = 0;
            }

            // Update stock
            await _firestore.collection('products').doc(productId).update({
              'stock': newStock,
              'updated_at': FieldValue.serverTimestamp(),
            });

            log('📦 Reduced stock for product $productId: $currentStock → $newStock (quantity: $quantity)');
          } else {
            log('❌ Product $productId not found in database');
          }
        } else {
          log('❌ Invalid product ID in order: $product');
        }
      }
    } catch (e) {
      log('❌ Error reducing product stock: $e');
      throw Exception('Failed to reduce product stock: $e');
    }
  }

  /// Validate stock availability before placing order
  Future<Map<String, dynamic>> validateStockAvailability(
      List<Map<String, dynamic>> products) async {
    Map<String, dynamic> result = {
      'isValid': true,
      'errors': <String>[],
      'warnings': <String>[],
    };

    try {
      for (Map<String, dynamic> product in products) {
        String productId = product['id'] ?? product['product_id'] ?? '';
        String productName = product['name'] ?? 'Unknown Product';
        int quantity = product['quantity'] ?? 1;

        if (productId.isNotEmpty) {
          // Get current stock
          DocumentSnapshot productDoc =
              await _firestore.collection('products').doc(productId).get();

          if (productDoc.exists) {
            Map<String, dynamic> productData =
                productDoc.data() as Map<String, dynamic>;
            int currentStock = productData['stock'] ?? 0;

            if (currentStock < quantity) {
              result['isValid'] = false;
              result['errors'].add(
                  '$productName: Only $currentStock items available (requested: $quantity)');
            } else if (currentStock == quantity) {
              result['warnings']
                  .add('$productName: Last $quantity items in stock');
            } else if (currentStock <= 5) {
              result['warnings'].add(
                  '$productName: Low stock ($currentStock items remaining)');
            }
          } else {
            result['isValid'] = false;
            result['errors'].add('$productName: Product not found');
          }
        } else {
          result['isValid'] = false;
          result['errors'].add('Invalid product ID in cart');
        }
      }
    } catch (e) {
      log('❌ Error validating stock: $e');
      result['isValid'] = false;
      result['errors'].add('Error validating stock: $e');
    }

    return result;
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
          'seller_id': doc['seller_id'],
          'stock': doc['stock'],
          'model_3d': doc['model_3d'],
          'created_at': doc['created_at'],
          'updated_at': doc['updated_at'],
        };
      }).toList();
    } catch (e) {
      log('Error $e');
    }
  }

  // Future<void> getAllProduct() async {
  //   try {
  //     var category = ['Chair', 'Table', 'Sofa', 'Bed'];
  //     List<Map<String, dynamic>> allProductsList = [];

  //     for (String cat in category) {
  //       QuerySnapshot querySnapshot = await _firestore
  //           .collection('products')
  //           .where('category', isEqualTo: cat)
  //           .get();

  //       // Add each product from this category to the allProductsList
  //       allProductsList.addAll(querySnapshot.docs.map((doc) {
  //         return {
  //           'id': doc.id,
  //           'category': doc['category'],
  //           'description': doc['description'],
  //           'name': doc['name'],
  //           'price': doc['price'],
  //           'image': doc['image'],
  //         };
  //       }).toList());
  //     }

  //     // Assign the collected products to allProducts
  //     allProducts.value = allProductsList;
  //   } catch (e) {
  //     log('Error $e');
  //   }
  // }
}
