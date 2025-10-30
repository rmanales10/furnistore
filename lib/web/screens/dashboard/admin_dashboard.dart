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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 40 : 100),
        vertical: isMobile ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin Dashboard",
            style: TextStyle(
              fontSize: isMobile ? 24 : (isTablet ? 26 : 30),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadiusDirectional.circular(15),
                border: Border.all(width: 1, color: Colors.grey)),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Obx(() {
                _controller.fetchTotalUsers();
                _controller.fetchTotalSellers();

                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Performance',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Overview',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InfoCard(
                            icon: Icons.person_outline_rounded,
                            title: "Total Users",
                            value: "${_controller.totalUsers}",
                            isMobile: isMobile,
                          ),
                          SizedBox(height: 16),
                          InfoCard(
                            icon: Icons.group_outlined,
                            title: "Total Sellers",
                            value: "${_controller.totalSellers}",
                            isMobile: isMobile,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right: isTablet ? 40 : 100, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Performance',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Overview',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 20,
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
                              isMobile: isMobile,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 20),
                          Expanded(
                            child: InfoCard(
                              icon: Icons.group_outlined,
                              title: "Total Sellers",
                              value: "${_controller.totalSellers}",
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      );
              }),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildChart(isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildChart(bool isMobile, bool isTablet) {
    return Obx(() {
      final monthlyCounts = _controller.monthlyUserCounts;
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : (isTablet ? 40 : 100),
          vertical: isMobile ? 16 : 20,
        ),
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
            Text(
              'Active Users',
              style: TextStyle(
                fontSize: isMobile ? 18 : (isTablet ? 20 : 24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            SizedBox(
              height: isMobile ? 250 : 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 25 : 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: isMobile ? 10 : 12),
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
                            style: TextStyle(fontSize: isMobile ? 9 : 12),
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
                          width: isMobile ? 15 : (isTablet ? 30 : 60),
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
  final bool isMobile;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isMobile ? 35 : 50,
          ),
          SizedBox(height: isMobile ? 8 : 10),
          Text(title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 13 : 14,
              )),
          SizedBox(height: isMobile ? 8 : 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 32 : 45)),
            ],
          ),
        ],
      ),
    );
  }
}
