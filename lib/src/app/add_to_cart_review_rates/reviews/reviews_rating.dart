import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:furnistore/src/app/add_to_cart_review_rates/reviews/reviews_controller.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ReviewsScreen extends StatelessWidget {
  String? productId;
  ReviewsScreen({super.key, required this.productId});

  final _controller = Get.put(ReviewsController());

  @override
  Widget build(BuildContext context) {
    // Fetch reviews once during initialization
    _controller.getAllReviews(productId: productId!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reviews & Ratings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Rating and reviews are verified and are from people who use the same type of device that you use.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Overall Rating
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '896',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),

                  // Rating Breakdown
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, 0.8),
                        _buildRatingBar(4, 0.6),
                        _buildRatingBar(3, 0.4),
                        _buildRatingBar(2, 0.2),
                        _buildRatingBar(1, 0.1),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Rating Section
              Obx(() {
                final List<Map<String, dynamic>> review =
                    List<Map<String, dynamic>>.from(
                        _controller.allReviews['reviews'] ?? []);
                if (review.isEmpty) {
                  return Center(
                    child: Text('No Reviews Yet!'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true, // Prevent ListView from taking all space
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: review.length,
                  itemBuilder: (context, index) {
                    final rev = review[index];

                    return FutureBuilder(
                      future: _controller.getUserInfo(
                          userId:
                              rev['user_id']), // Get user info asynchronously
                      builder: (context, snapshot) {
                        // While waiting for the user info to load, show a loading spinner
                        // if (snapshot.connectionState ==
                        //     ConnectionState.waiting) {
                        //   return CircularProgressIndicator(); // You can customize this part
                        // }

                        if (snapshot.hasError) {
                          return Text(
                              'Error: ${snapshot.error}'); // Handle any errors
                        }

                        // Once the user info is available, render the review card
                        final userName =
                            _controller.userInfo['name'] ?? 'Default Name';
                        final userComment = rev['comment'] ?? 'No Comment';
                        final userRating = rev['ratings'] ?? 0;
                        Uint8List decodedImageBytes;
                        if (_controller.userInfo['image'] != null) {
                          decodedImageBytes =
                              base64Decode(_controller.userInfo['image']);
                        } else {
                          decodedImageBytes = Uint8List.fromList([]);
                        }

                        return _buildReviewCard(
                          userName,
                          userComment,
                          decodedImageBytes, // Replace with your avatar path
                          userRating,
                        );
                      },
                    );
                  },
                );
              }),

              // Review Cards

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Rating Bars
  Widget _buildRatingBar(int rating, double value) {
    return Row(
      children: [
        Text(
          '$rating',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  // Helper Widget for Review Cards
  Widget _buildReviewCard(
      String reviewerName, String reviewText, Uint8List avatarPath, int stars) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reviewer Avatar
                CircleAvatar(
                  radius: 20,
                  child: Image.memory(
                    avatarPath,
                    gaplessPlayback: true,
                  ),
                ),
                const SizedBox(width: 12),

                // Reviewer Name and Review
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        reviewerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                stars,
                (index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              reviewText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
