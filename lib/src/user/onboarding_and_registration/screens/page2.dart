import 'package:flutter/material.dart';

class Onboard2 extends StatefulWidget {
  const Onboard2({super.key});

  @override
  State<Onboard2> createState() => _Onboard2State();
}

class _Onboard2State extends State<Onboard2> {    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: const DecorationImage(
            image: AssetImage('assets/page2.png'),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Row(
                children: [
                  Text(
                    'We Design\n    Furniture For\n     Your Comfort',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 435),
              Column(
                children: [
                  Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFF202020),
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the border radius as needed
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Adjust the font size as needed
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
