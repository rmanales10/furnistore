import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop  (),
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

              // Rating Section
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
              const SizedBox(height: 20),

              // Review Cards
              _buildReviewCard(
                'Dave John',
                'Absolutely love this piece! The quality is top-notch, and it fits perfectly in my living room. The design is elegant, and the finish is flawless. Highly recommend for anyone looking to elevate their home decor!',
                'assets/avatar1.png', // Replace with your avatar path
                5,
              ),
              const SizedBox(height: 16),
              _buildReviewCard(
                'Dave John',
                'Comfortable and stylish! The furniture arrived on time and looks even better in person. The customer service was also very helpful throughout the process.',
                'assets/avatar2.png', // Replace with your avatar path
                5,
              ),
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
      String reviewerName, String reviewText, String avatarPath, int stars) {
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
                  backgroundImage: AssetImage(avatarPath),
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
