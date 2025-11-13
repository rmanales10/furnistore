import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furnistore/web/auth_screen/login_controller.dart';
import 'package:get/get.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20.0 : (isTablet ? 30.0 : 40.0),
                  vertical: isMobile ? 32.0 : 48.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 16.0 : 24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  maxWidth:
                      isMobile ? screenWidth * 0.95 : (isTablet ? 480 : 520),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LogoWidget(isMobile: isMobile),
                    SizedBox(height: isMobile ? 24 : 32),
                    Text(
                      'Welcome to FurniStore',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : (isTablet ? 24 : 28),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'Discover Limitless Choices and Unmatched Convenience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : (isTablet ? 14 : 16),
                        color: Colors.grey[600],
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 48),
                    const LoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  final bool isMobile;
  const LogoWidget({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(0.1),
      ),
      child: Image.asset(
        'assets/image_3.png',
        height: isMobile ? 60 : 80,
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _controller = Get.put(LoginController());
  bool _isPasswordVisible = false;
  bool isRememberMeChecked = false;
  bool isSubmitting = false;

  Future<void> loginUser() async {
    final result = await _controller.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (result['success'] == true) {
      final role = result['role'];
      if (role == 'admin') {
        Get.offAllNamed('/admin-dashboard');
        Get.snackbar('Success', 'Admin Logged in successfully!');
      } else if (role == 'seller') {
        Get.offAllNamed('/seller-dashboard');
        Get.snackbar('Success', 'Seller Logged in successfully!');
      }
    } else {
      final error = result['error'];
      final message = result['message'] ?? 'Login failed';

      if (error == 'email_not_verified') {
        Get.dialog(
          AlertDialog(
            title: const Text('Email Not Verified'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    // Try to sign in to get user, then send verification
                    final credential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                    );
                    await credential.user?.sendEmailVerification();
                    await FirebaseAuth.instance.signOut();
                    Get.snackbar(
                      'Success',
                      'Verification email sent! Please check your inbox.',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to send verification email. Please try again.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                  Get.back();
                },
                child: const Text('Resend Verification Email'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar('Error', message);
      }
    }
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration:
                _getInputDecoration('Email or Username', Icons.person_outline),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or username';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration:
                _getInputDecoration('Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  isSubmitting = true;
                });
                await loginUser();
                setState(() {
                  isSubmitting = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Color(0xFF3E6BE0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 2,
            ),
            child: isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
