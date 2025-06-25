import 'package:flutter/material.dart';

class AboutFurniStoreScreen extends StatelessWidget {
  const AboutFurniStoreScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              'About FurniStore',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'FurniStore - Furniture E-commerce UI Kit is a comprehensive user interface (UI) kit crafted specifically for building sleek and modern furniture shopping apps. '
              'This UI kit offers a cohesive set of pre-designed components, templates, and elements, allowing developers and designers to create visually stunning and user-friendly interfaces quickly and efficiently. '
              'It includes features like product showcases, a streamlined checkout process, profile management, and review sections to deliver an exceptional shopping experience tailored for furniture enthusiasts.',
              style: TextStyle(fontSize: 14, color: Colors.black, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Contact Section
            const Text(
              'If you need help or you have any questions, feel free to contact me by email.',
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
