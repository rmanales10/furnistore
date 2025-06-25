import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class IncomeController extends GetxController {
  var monthlyIncome = List<double>.filled(12, 0.0).obs;
  var selectedTimeRange = "All Time".obs;

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
      CollectionReference ordersCollection =
          FirebaseFirestore.instance.collection('orders');

      QuerySnapshot querySnapshot = await ordersCollection.get();
      List<double> incomePerMonth = List.filled(12, 0.0);

      DateTime now = DateTime.now();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Parsing date
        DateTime orderDate = (data['date'] as Timestamp).toDate();
        int month = orderDate.month - 1;

        // Filtering based on the selected time range
        if (selectedTimeRange.value == "This Year" &&
            orderDate.year != now.year) {
          continue;
        } else if (selectedTimeRange.value == "This Month" &&
            (orderDate.year != now.year || orderDate.month != now.month)) {
          continue;
        }

        // Adding order total and delivery fee to the respective month
        double orderTotal = (data['total'] ?? 0).toDouble();
        double deliveryFee = (data['delivery_fee'] ?? 0).toDouble();

        incomePerMonth[month] += orderTotal + deliveryFee;
      }

      monthlyIncome.value = incomePerMonth;
    } catch (e) {
      log("Failed to fetch data: $e");
    }
  }
}
