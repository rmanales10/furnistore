import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furnistore/web/chart/income_controller.dart';
import 'package:get/get.dart';

class TotalIncomeChart extends StatelessWidget {
  TotalIncomeChart({super.key});

  final IncomeController incomeController = Get.put(IncomeController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 24 : 40),
        vertical: isMobile ? 20 : 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Income',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(10),
                            value: incomeController.selectedTimeRange.value,
                            items: ["All Time", "This Year", "This Month"]
                                .map((value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                incomeController.changeTimeRange(value);
                              }
                            },
                            icon:
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: Color(0xFF2c3e50),
                              fontSize: 14,
                            ),
                            dropdownColor: Colors.white,
                          ),
                        )),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Income',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          child: DropdownButton<String>(
                            borderRadius: BorderRadius.circular(10),
                            value: incomeController.selectedTimeRange.value,
                            items: ["All Time", "This Year", "This Month"]
                                .map((value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                incomeController.changeTimeRange(value);
                              }
                            },
                            icon:
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: Color(0xFF2c3e50),
                              fontSize: 14,
                            ),
                            dropdownColor: Colors.white,
                          ),
                        )),
                  ],
                ),
          SizedBox(height: isMobile ? 20 : 30),
          SizedBox(
            height: isMobile ? 280 : (isTablet ? 320 : 380),
            child: Obx(() {
              // Show loading indicator while fetching data
              if (incomeController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3E6BE0),
                  ),
                );
              }

              final maxIncome = incomeController.monthlyIncome
                  .reduce((a, b) => a > b ? a : b);
              final interval =
                  maxIncome > 0 ? (maxIncome / 5).ceilToDouble() : 200;

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxIncome > 0 ? maxIncome * 1.2 : 1000,
                  minY: 0,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 35 : (isTablet ? 40 : 50),
                        interval: interval.toDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return Text(
                              '0',
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 12,
                                color: Color(0xFF6c757d),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return Text(
                            value >= 1000
                                ? '${(value / 1000).toStringAsFixed(0)}K'
                                : value.toInt().toString(),
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              color: Color(0xFF6c757d),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 24 : 30,
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
                          if (value.toInt() >= 0 &&
                              value.toInt() < months.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: isMobile ? 4 : 8),
                              child: Text(
                                months[value.toInt()],
                                style: TextStyle(
                                  fontSize: isMobile ? 9 : 13,
                                  color: Color(0xFF6c757d),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval.toDouble(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: _buildBarGroups(incomeController.monthlyIncome,
                      maxIncome, isMobile, isTablet),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => const Color(0xFF2c3e50),
                      tooltipBorder: const BorderSide(
                        color: Color(0xFF2c3e50),
                        width: 1,
                      ),
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        const months = [
                          'January',
                          'February',
                          'March',
                          'April',
                          'May',
                          'June',
                          'July',
                          'August',
                          'September',
                          'October',
                          'November',
                          'December'
                        ];
                        return BarTooltipItem(
                          '${months[group.x.toInt()]}\n',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                          ),
                          children: [
                            TextSpan(
                              text: '₱${rod.toY.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 10 : 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<double> monthlyIncome,
      double maxIncome, bool isMobile, bool isTablet) {
    return List.generate(monthlyIncome.length, (index) {
      final income = monthlyIncome[index];
      final isHighest = income == maxIncome && maxIncome > 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: income,
            gradient: LinearGradient(
              colors: isHighest
                  ? [
                      const Color(0xFF5A7CE8),
                      const Color(0xFF3E6BE0),
                    ]
                  : [
                      const Color(0xFF6B8DEE),
                      const Color(0xFF4A75E6),
                    ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: isMobile ? 12 : (isTablet ? 18 : 28),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMobile ? 3 : 6),
              topRight: Radius.circular(isMobile ? 3 : 6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxIncome > 0 ? maxIncome * 1.2 : 1000,
              color: Colors.grey.shade100,
            ),
          ),
        ],
      );
    });
  }
}
