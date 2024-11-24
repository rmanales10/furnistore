import 'package:flutter/material.dart';
import 'package:furnistore/src/admin/chart/monthlychart.dart';
import 'package:furnistore/src/admin/screens/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';

class DashboardContent extends StatelessWidget {
  DashboardContent({super.key});

  final _controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Obx(() {
            _controller.fetchDataFromFirestore();

            return Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: "Total Revenue",
                    value: "₱ ${_controller.totalRevenue}",
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: InfoCard(
                    title: "Total Orders",
                    value: "${_controller.totalOrders}",
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 20),
          TotalIncomeChart(),
        ],
      ),
    );
  }
}

// InfoCard Widget
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }
}
