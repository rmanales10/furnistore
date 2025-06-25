import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furnistore/web/screens/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key}) {
    _controller.fetchMonthlyUserCounts();
  }

  final _controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin Dashboard",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadiusDirectional.circular(15),
                border: Border.all(width: 1, color: Colors.grey)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                _controller.fetchTotalUsers();
                _controller.fetchTotalSellers();

                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 100, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performance',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: InfoCard(
                        icon: Icons.person_outline_rounded,
                        title: "Total Users",
                        value: "${_controller.totalUsers}",
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: InfoCard(
                        icon: Icons.group_outlined,
                        title: "Total Sellers",
                        value: "${_controller.totalSellers}",
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: 20),
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Obx(() {
      final monthlyCounts = _controller.monthlyUserCounts;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Users',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec'
                          ];
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(monthlyCounts.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          borderRadius: BorderRadius.zero,
                          toY: monthlyCounts[index].toDouble(),
                          color: const Color(0xFF3E6BE0),
                          width: 60,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// InfoCard Widget
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 45)),
            ],
          ),
        ],
      ),
    );
  }
}
