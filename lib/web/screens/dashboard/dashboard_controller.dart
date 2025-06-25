import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxInt totalUsers = 0.obs;
  var totalRevenue = 0.0.obs;
  var totalOrders = 0.obs;
  RxInt totalSellers = 0.obs;
  RxList<int> monthlyUserCounts = List<int>.filled(12, 0).obs;

  Future<void> fetchDataFromFirestore() async {
    try {
      var revenue = 0.0;
      CollectionReference ordersCollection = _firestore.collection('orders');

      QuerySnapshot querySnapshot = await ordersCollection.get();
      totalOrders.value = querySnapshot.size;

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        revenue += (data['total'] ?? 0).toDouble();
      }
      totalRevenue.value = revenue;
      // log('totalRevenue $totalRevenue totalOrders $totalOrders');
    } catch (e) {
      // log("Failed to fetch data: $e");
    }
  }

  Future<void> fetchTotalUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      totalUsers.value = querySnapshot.size;
    } catch (e) {
      log("Failed to fetch data: $e");
    }
  }

  Future<void> fetchTotalSellers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('sellersApplication')
          .where('status', isEqualTo: 'Approved')
          .get();
      totalSellers.value = querySnapshot.size;
    } catch (e) {
      log("Failed to fetch data: $e");
    }
  }

  Future<void> fetchMonthlyUserCounts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      List<int> counts = List.filled(12, 0);
      DateTime now = DateTime.now();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] != null) {
          DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
          if (createdAt.year == now.year) {
            counts[createdAt.month - 1]++;
          }
        }
      }
      monthlyUserCounts.value = counts;
    } catch (e) {
      log("Failed to fetch monthly user counts: $e");
    }
  }
}
