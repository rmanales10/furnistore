import 'package:flutter/material.dart';
import 'package:furnistore/app/add_to_cart_review_rates/cart/cart.dart';
import 'package:furnistore/app/add_to_cart_review_rates/cart/cart_controller.dart';
import 'package:furnistore/app/home/home.dart';
import 'package:furnistore/app/profile/profile_settings.dart';
import 'package:furnistore/app/store/store_screen.dart';
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
    const StoreScreen(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF3E6BE0),
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.store), label: 'Store'),
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
      ),
    );
  }
}
