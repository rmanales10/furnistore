import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class IncomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  var monthlyIncome = List<double>.filled(12, 0.0).obs;
  var selectedTimeRange = "All Time".obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMonthlyIncome();
  }

  void changeTimeRange(String value) {
    selectedTimeRange.value = value;
    fetchMonthlyIncome();
  }

  Future<void> fetchMonthlyIncome() async {
    try {
      isLoading.value = true;

      // Get current seller's user ID
      final sellerId = currentUser?.uid;
      if (sellerId == null) {
        log('No seller user ID found for income chart');
        monthlyIncome.value = List.filled(12, 0.0);
        return;
      }

      // First, get all product IDs that belong to this seller
      final productsSnapshot = await _firestore
          .collection('products')
          .where('seller_id', isEqualTo: sellerId)
          .get();

      final sellerProductIds = productsSnapshot.docs
          .map((doc) => doc.id)
          .toSet(); // Use Set for faster lookup

      if (sellerProductIds.isEmpty) {
        log('No products found for seller: $sellerId');
        monthlyIncome.value = List.filled(12, 0.0);
        return;
      }

      // Fetch all orders
      QuerySnapshot querySnapshot = await _firestore.collection('orders').get();
      List<double> incomePerMonth = List.filled(12, 0.0);

      DateTime now = DateTime.now();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
        final products = orderData['products'] as List<dynamic>?;

        // Check if any product in the order belongs to this seller
        bool hasSellerProduct = false;
        if (products != null && products.isNotEmpty) {
          for (var product in products) {
            if (product is Map<String, dynamic>) {
              // Check both 'product_id' and 'id' fields
              final productId = product['product_id'] ?? product['id'];
              if (productId != null &&
                  sellerProductIds.contains(productId.toString())) {
                hasSellerProduct = true;
                break;
              }
            }
          }
        }

        // Only process orders that contain seller's products
        if (!hasSellerProduct) continue;

        // Check if date field exists
        if (orderData['date'] == null) continue;

        // Parsing date
        DateTime orderDate = (orderData['date'] as Timestamp).toDate();
        int month = orderDate.month - 1;

        // Filtering based on the selected time range
        if (selectedTimeRange.value == "This Year" &&
            orderDate.year != now.year) {
          continue;
        } else if (selectedTimeRange.value == "This Month" &&
            (orderDate.year != now.year || orderDate.month != now.month)) {
          continue;
        }

        // Adding order total to the respective month
        double orderTotal = (orderData['total'] ?? 0).toDouble();

        incomePerMonth[month] += orderTotal;
      }

      monthlyIncome.value = incomePerMonth;

      log('✅ Fetched monthly income for seller: ${selectedTimeRange.value}');
      log('Total income data: ${incomePerMonth.reduce((a, b) => a + b).toStringAsFixed(2)}');
    } catch (e) {
      log("❌ Failed to fetch monthly income: $e");
      // Reset to empty data on error
      monthlyIncome.value = List.filled(12, 0.0);
    } finally {
      isLoading.value = false;
    }
  }
}
