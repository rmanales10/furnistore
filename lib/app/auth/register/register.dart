import 'package:flutter/material.dart';
import 'package:furnistore/app/auth/register/register_controller.dart';
import 'package:furnistore/app/auth/verification/verification.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool agree = false;
  bool obs = true;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _controller = Get.put(RegisterController());
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: InkWell(
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: agree,
                      activeColor: const Color(0xFF3E6BE0),
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          setState(() {
                            agree = newValue;
                          });
                        }
                      },
                    ),
                    const Text('Agree with '),
                    GestureDetector(
                      onTap: () {
                        _showTermsAndConditionsDialog(context);
                      },
                      child: const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          color: Color(0xFF3E6BE0),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF3E6BE0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                isSubmitting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E6BE0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: isSubmitting ? null : _handleSignUp,
                          child: const Text(
                            'SIGN UP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Have an account?"),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Color(0xFF3E6BE0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: const Text(
              'By creating an account, you agree to the following:\n\n'
              '1. You will provide accurate information.\n'
              '2. You are responsible for maintaining the confidentiality of your account.\n'
              '3. You agree not to misuse the app in any way.\n'
              '4. You accept that the app may update its terms and conditions at any time.\n\n'
              'If you do not agree with these terms, please do not use this service.',
              textAlign: TextAlign.justify,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignUp() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if terms are agreed
    if (!agree) {
      Get.snackbar('Error', 'Please agree to Terms & Conditions');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await _controller.registerUser(
        name: _name.text.trim(),
        email: _email.text.trim(),
        status: 'active',
        password: _password.text,
      );

      if (_controller.isSuccess.value) {
        // Navigate to email verification screen
        Get.offAll(() => EmailVerificationScreen(
              email: _email.text.trim(),
            ));
      } else {
        Get.snackbar('Error', 'Failed to register user');
      }
    } catch (e) {
      String errorMessage = 'Registration failed';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage =
            'This email is already registered. Please use a different email or sign in.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak. Please use a stronger password.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address.';
      } else {
        errorMessage = 'Registration failed: ${e.toString()}';
      }
      Get.snackbar('Error', errorMessage);
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
}
