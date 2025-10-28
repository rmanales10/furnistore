import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furnistore/web/chart/income_controller.dart';
import 'package:get/get.dart';

class TotalIncomeChart extends StatelessWidget {
  TotalIncomeChart({super.key});

  final IncomeController incomeController = Get.put(IncomeController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Income',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3e50),
                ),
              ),
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
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
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
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
          const SizedBox(height: 30),
          SizedBox(
            height: 380,
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
                        reservedSize: 50,
                        interval: interval.toDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6c757d),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return Text(
                            value >= 1000
                                ? '${(value / 1000).toStringAsFixed(0)}K'
                                : value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
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
                        reservedSize: 30,
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
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 13,
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
                  barGroups: _buildBarGroups(
                      incomeController.monthlyIncome, maxIncome),
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
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: '₱${rod.toY.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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

  List<BarChartGroupData> _buildBarGroups(
      List<double> monthlyIncome, double maxIncome) {
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
            width: 28,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
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
