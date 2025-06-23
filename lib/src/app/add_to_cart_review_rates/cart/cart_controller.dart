import 'package:furnistore/src/app/firebase_service/auth_service.dart';
import 'package:furnistore/src/app/firebase_service/firestore_service.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final _firestore = Get.put(FirestoreService());
  final _auth = Get.put(AuthService());

  RxList carts = [].obs;
  RxList productsCart = [].obs;
  RxDouble totalPrice = 0.0.obs;

  Future<void> fetchCartData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.getUserCart(userId: userId);
    carts.value = _firestore.carts;

    final productIds = carts.map((cart) => cart['product_id']).toList();
    if (productIds.isNotEmpty) {
      await _firestore.getProductsInCart(productIds);
      productsCart.value = _firestore.productsCart;
    }

    updateTotalPrice();
  }

  void updateTotalPrice() {
    double newTotalPrice = carts.fold(0, (sum, cart) {
      final product = productsCart.firstWhere(
        (p) => p['id'] == cart['product_id'],
        orElse: () => {},
      );

      final price = product['price'] is int
          ? (product['price'] as int).toDouble()
          : double.tryParse(product['price'].toString()) ?? 0.0;

      return sum + (price * (cart['quantity'] ?? 0));
    });

    totalPrice.value = newTotalPrice; // Make sure to use `.value`
  }

  Future<void> deleteCartItem(String cartId) async {
    await _firestore.deleteCartItem(cartId);
    await fetchCartData();
  }

  Future<void> updateCartQuantity(String cartId, int quantity) async {
    await _firestore.updateCartQuantity(cartId, quantity);
    fetchCartData(); // Ensure that after quantity change, the cart and total price are updated.
  }

  List<Map<String, dynamic>> getCartProducts() {
    return carts.map((cart) {
      final product = productsCart.firstWhere(
        (p) => p['id'] == cart['product_id'],
        orElse: () => {},
      );
      return {
        'product_id': cart['product_id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'quantity': cart['quantity'],
      };
    }).toList();
  }
}
