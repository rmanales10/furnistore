import 'package:flutter/material.dart';
import 'package:furnistore/src/user/add_to_cart_review_rates/cart/cart.dart';
import 'package:furnistore/src/user/add_to_cart_review_rates/cart/cart_controller.dart';
import 'package:furnistore/src/user/home/home.dart';
import 'package:furnistore/src/user/profile/settings.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> body = [
    Home(),
    const CartScreen(),
    const ProfileSettingsScreen(),
  ];
  final cartController = Get.put(CartController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: body[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Stack(children: [
                const Icon(Icons.shopping_cart),
                cartController.carts.isEmpty
                    ? SizedBox.shrink()
                    : Positioned(
                        left: 14,
                        child: Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 10,
                        )),
              ]),
              label: 'Cart'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
