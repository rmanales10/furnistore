import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class Onboard1 extends StatefulWidget {
  const Onboard1({super.key});

  @override
  State<Onboard1> createState() => _Onboard1State();
}

class _Onboard1State extends State<Onboard1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    Timer(const Duration(seconds: 3), () {
      // Check if user is already logged in
      User? user = _auth.currentUser;
      if (user != null) {
        // User is logged in, navigate to home
        Get.offAllNamed('/home');
      } else {
        // User is not logged in, navigate to onboarding
        Navigator.pushNamed(context, '/2');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 75,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image_3.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
