import 'package:flutter/material.dart';

class Terms extends StatelessWidget {
  const Terms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const SizedBox.shrink(), // No title in AppBar
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Section
            Center(
              child: Image.asset(
                'assets/image_3.png', // Replace with your logo path
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Terms and Conditions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Welcome to FurniStore! These Terms and Conditions ("Terms") govern your access and use of our e-commerce platform, including any related services provided through our mobile app and website (collectively, the "Service"). By accessing or using the Service, you agree to be bound by these Terms. If you do not agree, please refrain from using the Service.',
              style: TextStyle(fontSize: 14, color: Colors.black, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Eligibility Section
            const Text(
              'Eligibility',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• You must be at least 18 years old or have parental/guardian consent to use our Service.\n'
              '• By using the Service, you represent and warrant that you have the legal right and authority to enter into these Terms.',
              style: TextStyle(fontSize: 14, color: Colors.black, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Contact Section
            const Text(
              'Contact Us',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions about these Terms, feel free to reach us at:',
              style: TextStyle(fontSize: 14, color: Colors.black, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'elsiemrybonza@gmail.com',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
