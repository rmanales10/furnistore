import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnistore/app/add_to_cart_review_rates/reviews/reviews_controller.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ReviewsScreen extends StatefulWidget {
  String? productId;
  ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ReviewsController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ReviewsController());
    // Fetch reviews once during initialization
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    await _controller.getAllReviews(productId: widget.productId!);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Don't delete the controller as it might be used by other screens
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
      );
    }

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

              // Overall Rating Section
              GetBuilder<ReviewsController>(
                init: _controller,
                builder: (controller) {
                  return Row(
                    children: [
                      // Overall Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${controller.totalReviews}',
                            style: const TextStyle(
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
                            _buildRatingBar(
                                5,
                                controller.ratingDistribution[5] ?? 0,
                                controller.totalReviews),
                            _buildRatingBar(
                                4,
                                controller.ratingDistribution[4] ?? 0,
                                controller.totalReviews),
                            _buildRatingBar(
                                3,
                                controller.ratingDistribution[3] ?? 0,
                                controller.totalReviews),
                            _buildRatingBar(
                                2,
                                controller.ratingDistribution[2] ?? 0,
                                controller.totalReviews),
                            _buildRatingBar(
                                1,
                                controller.ratingDistribution[1] ?? 0,
                                controller.totalReviews),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Reviews List
              GetBuilder<ReviewsController>(
                init: _controller,
                builder: (controller) {
                  final List<Map<String, dynamic>> reviews =
                      List<Map<String, dynamic>>.from(
                          controller.allReviews['reviews'] ?? []);

                  if (reviews.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'No Reviews Yet!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return _buildReviewItem(review);
                    },
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Rating Bars
  Widget _buildRatingBar(int rating, int count, int totalReviews) {
    double percentage = totalReviews > 0 ? count / totalReviews : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$rating',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Review Items
  Widget _buildReviewItem(Map<String, dynamic> review) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _controller.getUserInfo(userId: review['user_id'] ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Error loading user info',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final userData = snapshot.data ?? {};
        final userName =
            userData['name'] ?? userData['username'] ?? 'Anonymous User';
        final userComment = review['comment'] ?? 'No comment provided';
        final userRating = review['rating'] ?? 0;
        final userImage = userData['image'] ?? userData['profile_image'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // User Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.purple.shade100,
                      backgroundImage: userImage.isNotEmpty
                          ? MemoryImage(base64Decode(userImage))
                          : null,
                      child: userImage.isEmpty
                          ? Icon(
                              Icons.person,
                              color: Colors.purple.shade300,
                              size: 24,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // User Name
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Star Rating
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Review Comment
                Text(
                  userComment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
