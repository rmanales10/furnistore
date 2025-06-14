
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var totalRevenue = 0.0.obs;
  var totalOrders = 0.obs;

  Future<void> fetchDataFromFirestore() async {
    try {
      var revenue = 0.0;
      CollectionReference ordersCollection =
          FirebaseFirestore.instance.collection('orders');

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
}
