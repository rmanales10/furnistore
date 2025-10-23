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
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Income',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => DropdownButton<String>(
                    borderRadius: BorderRadius.circular(10),
                    value: incomeController.selectedTimeRange.value,
                    items: ["All Time", "This Year", "This Month"]
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        incomeController.changeTimeRange(value);
                      }
                    },
                    icon: const Icon(Icons.keyboard_arrow_down),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: Obx(() => BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 100000,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value / 1000).toStringAsFixed(0)}K',
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
                    barGroups: _buildBarGroups(incomeController.monthlyIncome),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<double> monthlyIncome) {
    return List.generate(monthlyIncome.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            borderRadius: BorderRadius.zero,
            toY: monthlyIncome[index],
            color: const Color(0xFF3E6BE0),
            width: 50,
          ),
        ],
      );
    });
  }
}
