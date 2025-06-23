import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furnistore/src/app/firebase_service/auth_service.dart';
import 'package:furnistore/src/app/auth/verification/verification.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final _auth = Get.put(AuthService());

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _fetchIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['ip'];
      }
      return 'Unknown';
    } catch (e) {
      return 'Error';
    }
  }

  String _generateUserId() {
    final random = math.Random();
    return 'UID-${random.nextInt(1000000).toString().padLeft(6, '0')}';
  }

  Future<void> _saveToFirestore({
    required String name,
    required String email,
    required String phoneNumber,
    required String idNumber,
    required String ipAddress,
    required String status,
  }) async {
    try {
      final emailKey = base64Url.encode(utf8.encode(email));
      await _firestore.collection('users').doc(emailKey).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'idNumber': idNumber,
        'ipAddress': ipAddress,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      log('User data saved successfully.');
    } catch (e) {
      log('Error saving user data to Firestore: $e');
      rethrow;
    }
  }

  Future<void> _handleSignUp() async {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _phoneNumber.text.isEmpty ||
        _password.text.isEmpty) {
      Get.snackbar(
        'Error',
        'All fields are required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final ipAddress = await _fetchIpAddress();
      final idNumber = _generateUserId();

      // Save to Firestore with "online" status
      await _saveToFirestore(
        name: _name.text,
        email: _email.text,
        phoneNumber: _phoneNumber.text,
        idNumber: idNumber,
        ipAddress: ipAddress,
        status: 'online',
      );

      // Create user in authentication
      await _auth.createEmailAndPassword(
        name: _name.text,
        email: _email.text,
        phoneNumber: _phoneNumber.text,
        password: _password.text,
        idNumber: idNumber,
        ipAddress: ipAddress,
      );

      // Navigate to email verification screen
      if (mounted) {
        Get.to(() => EmailVerificationScreen(
              email: _email.text,
            ));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to register: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
                decoration: InputDecoration(
                  labelText: 'Phone Number',
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
              Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E6BE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: agree ? _handleSignUp : null,
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
}
