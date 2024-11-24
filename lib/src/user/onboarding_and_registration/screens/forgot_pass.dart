import 'package:flutter/material.dart';
import 'package:furnistore/src/user/firebase_service/auth_service.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/login.dart';
import 'package:get/get.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});
  final _auth = Get.put(AuthService());
  final email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Forget password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Don't worry sometimes people can forget too, enter your email and we will send you a password reset link.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 50),

              // Email TextField
              TextFormField(
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6BE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    _auth.forgotPassword(email: email.text);
                    Get.snackbar('Success', 'Check you reset link');
                    Get.dialog(AlertDialog(
                      title: Text('Success'),
                      content: Text('Please check your email.'),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Get.off(() => LoginScreen()),
                            child: Text('Confirm'))
                      ],
                    ));
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
