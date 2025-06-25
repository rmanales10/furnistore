import 'package:flutter/material.dart';
import 'package:furnistore/app/auth/login/login_controller.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool obs = true;
  bool isSubmitting = false;
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 40),
                  Image.asset(
                    'assets/image_3.png',
                    height: 70,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover Limitless Choices and Unmatched Convenience.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _email,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: obs,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        obs = !obs;
                      });
                    },
                    child: Icon(
                      obs ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6BE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () async {
                    setState(() {
                      isSubmitting = true;
                    });
                    await _handleLogin();
                  },
                  child: Center(
                    child: isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'SIGN IN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Color(0xFF3E6BE0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    await controller.loginWithEmailAndPassword(
      _email.text,
      _password.text,
    );
    setState(() {
      isSubmitting = false;
    });
    if (controller.isSuccess.value) {
      Get.offAllNamed('/home');
      Get.snackbar('Success', 'Login Successfully');
    } else {
      Get.snackbar('Error', 'Invalid email or password');
    }
  }
}
