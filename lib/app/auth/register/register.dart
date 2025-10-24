import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furnistore/app/auth/register/register_controller.dart';
import 'package:furnistore/app/auth/otp_verification/otp_verification.dart';
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
  final _phoneNumber = TextEditingController();
  final _controller = Get.put(RegisterController());
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  String? _phoneError;

  // Phone number validation
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters
    String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it starts with 9 and has 10 digits total (since +63 is the prefix)
    if (!cleanNumber.startsWith('9') || cleanNumber.length != 10) {
      return 'Please enter a valid Philippine phone number (9xxxxxxxxx)';
    }

    return null;
  }

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
                  controller: _phoneNumber,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: _validatePhoneNumber,
                  onChanged: (value) {
                    setState(() {
                      _phoneError = _validatePhoneNumber(value);
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9xxxxxxxxx',
                    errorText: _phoneError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixText: '+63 ',
                    prefixStyle: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
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
        name: _name.text,
        email: _email.text,
        phoneNumber: _phoneNumber.text,
        status: 'active',
        password: _password.text,
      );

      if (_controller.isSuccess.value) {
        Get.offAll(() => OTPVerificationScreen(
              phoneNumber: _phoneNumber.text,
              userId: _controller.userId ?? '',
              name: _name.text,
              email: _email.text,
              password: _password.text,
            ));
      } else {
        Get.snackbar('Error', 'Failed to register user');
      }
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
}
