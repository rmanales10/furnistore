import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:furnistore/src/user/add_to_cart_review_rates/cart_controller.dart';
import 'package:furnistore/src/user/payment_track_order/order_review.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        cartController.fetchCartData();
        if (cartController.carts.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartController.carts.length,
                  itemBuilder: (context, index) {
                    final cart = cartController.carts[index];
                    final product = cartController.productsCart.firstWhere(
                      (p) => p['id'] == cart['product_id'],
                      orElse: () => {},
                    );

                    Uint8List decodedImageBytes;
                    if (product['image'] != null) {
                      decodedImageBytes = base64Decode(product['image']);
                    } else {
                      decodedImageBytes = Uint8List.fromList([]);
                    }

                    return CartItem(
                      title: product['name'] ?? '',
                      price: product['price'] ?? 0,
                      imageBytes: decodedImageBytes,
                      quantity: cart['quantity'] ?? 1,
                      onDelete: () async {
                        await cartController.deleteCartItem(cart['id']);
                      },
                      onQuantityChanged: (newQuantity) async {
                        await cartController.updateCartQuantity(
                            cart['id'], newQuantity);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          'Total ₱ ${cartController.totalPrice.value}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => OrderReviewScreen(
                              productList: cartController.getCartProducts(),
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class CartItem extends StatelessWidget {
  final String title;
  final dynamic price;
  final Uint8List imageBytes;
  final int quantity;
  final Function() onDelete;
  final Function(int) onQuantityChanged;

  const CartItem({
    super.key,
    required this.title,
    required this.price,
    required this.imageBytes,
    required this.quantity,
    required this.onDelete,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    RxInt currentQuantity = quantity.obs;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFF3E6BE0)),
            onPressed: onDelete,
          ),
          const SizedBox(width: 8),
          imageBytes != null
              ? Image.memory(
                  imageBytes,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported,
                        size: 60, color: Colors.grey);
                  },
                )
              : const Icon(Icons.image_not_supported,
                  size: 60, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₱ ${price.toString()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (currentQuantity.value > 1) {
                      currentQuantity.value -= 1;
                      onQuantityChanged(currentQuantity.value);
                    }
                  },
                  icon: const Icon(Icons.remove, color: Colors.blue),
                ),
                Text(
                  currentQuantity.value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    currentQuantity.value += 1;
                    onQuantityChanged(currentQuantity.value);
                  },
                  icon: const Icon(Icons.add, color: Colors.blue),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
