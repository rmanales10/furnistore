import 'package:flutter/material.dart';
import 'package:furnistore/src/app/home_screen.dart';
import 'package:furnistore/src/app/profile/apply/apply.dart';
import 'package:furnistore/src/app/profile/apply/apply_controller.dart';
import 'package:get/get.dart';

class SellerStatusScreen extends StatefulWidget {
  const SellerStatusScreen({super.key});

  @override
  State<SellerStatusScreen> createState() => _SellerStatusScreenState();
}

class _SellerStatusScreenState extends State<SellerStatusScreen> {
  final ApplyController controller = Get.put(ApplyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400, // fixed width for web card look
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Obx(() {
              controller.getSellerStatus();
              final status = controller.sellerStatus.value?['status']
                      ?.toString()
                      .toLowerCase() ??
                  'under review';
              if (status == 'approved') {
                // APPROVED UI
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.black)),
                    ),
                    // Checkmark in circle
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF7B61FF),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(Icons.check, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Application Approved!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    const Text(
                      'Your seller application has been successfully approved. You can now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Color(0xFFDFF6E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Status: Approved',
                        style: TextStyle(
                          color: Color(0xFF388E3C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // What now box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Color(0xFFE9F2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'What now?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          _BulletPoint(
                              text: 'Your seller account is now active.'),
                          _BulletPoint(
                              text:
                                  'Head over to your Seller Dashboard to add products and manage your store.'),
                          _BulletPoint(
                              text:
                                  'Make sure to complete your store profile for better visibility.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Need help box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDFF6E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Contact our support team at furnistoreofficial@gmail.com  if you need assistance with your seller account.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Go to Seller Dashboard button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B5BDB),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Navigate to Seller Dashboard
                        },
                        child: Text(
                          'Go to Seller Dashboard',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (status == 'rejected') {
                // REJECTED UI
                final reason = controller.sellerStatus.value?['reason'] ??
                    'No reason provided.';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.black)),
                    ),
                    // Red cross in circle
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF44336),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(Icons.close, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Application Rejected',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    const Text(
                      'After reviewing your submission, we regret to inform you that your seller application has not been approved.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Status: Rejected',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Reason for rejection box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reason for rejection',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFFE9ECEF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reason,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Need help box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Contact our support team at furnistoreofficial@gmail.com\nif you need any further assistance',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Apply Again button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B5BDB),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ApplyAsSellerScreen())),
                        child: const Text(
                          'Apply Again',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Return to Home button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen())),
                        child: const Text(
                          'Return to Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // UNDER REVIEW UI (existing)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.black)),
                    ),
                    // Checkmark in circle
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF7B61FF),
                            Color(0xFF5B8CFF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(Icons.check, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Application Submitted!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    const Text(
                      'Your seller application has been received and is currently under review.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Status: ${controller.sellerStatus.value?['status'] ?? 'Under Review'}',
                        style: TextStyle(
                          color: Color(0xFF856404),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // What happens next box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Color(0xFFE9F2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'What happens next?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          _BulletPoint(
                              text:
                                  'Our team will review your application within 2-3 business days'),
                          _BulletPoint(
                              text:
                                  'We may contact you for additional information if needed'),
                          _BulletPoint(
                              text:
                                  "You'll receive an email notification with the decision"),
                          _BulletPoint(
                              text:
                                  'If approved, you can immediately start selling'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Need help box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDFF6E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Contact our support team at support\nfurnistoreofficial@gmail.com if you have any questions about your application.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Back to Home button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen())),
                        child: Text(
                          'Back to Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, color: Colors.blue)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
