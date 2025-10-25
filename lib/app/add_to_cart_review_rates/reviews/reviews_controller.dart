import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ReviewsController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> allReviews = <String, dynamic>{};
  double averageRating = 0.0;
  int totalReviews = 0;
  Map<int, int> ratingDistribution = <int, int>{};

  Future<void> getAllReviews({required String productId}) async {
    try {
      // Fetch reviews from the reviews collection
      QuerySnapshot querySnapshot = await _firestore
          .collection('reviews')
          .where('product_id', isEqualTo: productId)
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> reviews = [];
      double totalRating = 0.0;
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
        reviews.add(reviewData);

        int rating = reviewData['rating'] ?? 0;
        totalRating += rating;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      // Calculate average rating
      double avgRating =
          reviews.isNotEmpty ? totalRating / reviews.length : 0.0;

      allReviews = {'reviews': reviews};
      averageRating = avgRating;
      totalReviews = reviews.length;
      ratingDistribution = distribution;

      // Update the UI
      update();

      log('✅ Loaded ${reviews.length} reviews for product $productId');
      log('✅ Average rating: ${avgRating.toStringAsFixed(1)}');
    } catch (e) {
      log('❌ Error fetching reviews: $e');
    }
  }

  Map<String, Map<String, dynamic>> _userCache =
      <String, Map<String, dynamic>>{};

  Future<Map<String, dynamic>> getUserInfo({required String userId}) async {
    log('🔍 Getting user info for userId: $userId');

    // Check if userId is empty or null
    if (userId.isEmpty) {
      log('❌ UserId is empty, returning anonymous user');
      return {
        'name': 'Anonymous User',
        'username': 'Anonymous',
        'image': '',
        'profile_image': ''
      };
    }

    // Check cache first
    if (_userCache.containsKey(userId)) {
      log('✅ Found user in cache: ${_userCache[userId]?['name']}');
      return _userCache[userId]!;
    }

    try {
      log('🔍 Fetching user from Firestore: $userId');
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
        log('✅ User found in Firestore: ${userData['name'] ?? userData['username']}');
        // Cache the user data
        _userCache[userId] = userData;
        return userData;
      } else {
        log('❌ User document does not exist: $userId');
      }
    } catch (e) {
      log('❌ Error fetching user info: $e');
    }

    // Return default user data if not found
    log('❌ Returning anonymous user for: $userId');
    return {
      'name': 'Anonymous User',
      'username': 'Anonymous',
      'image': '',
      'profile_image': ''
    };
  }
}
