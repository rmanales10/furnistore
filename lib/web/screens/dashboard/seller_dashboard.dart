import 'package:flutter/material.dart';
import 'package:furnistore/services/pdf_service.dart';
import 'package:furnistore/web/chart/income_controller.dart';
import 'package:furnistore/web/chart/monthlychart.dart';
import 'package:furnistore/web/screens/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final _controller = Get.put(DashboardController());
  final _incomeController = Get.put(IncomeController());
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _controller.fetchDataFromFirestore();
  }

  Future<void> _generatePDF() async {
    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      await PDFService.generateDashboardReport(
        totalRevenue: _controller.totalRevenue.value,
        totalOrders: _controller.totalOrders.value,
        monthlyIncome: _incomeController.monthlyIncome,
        timeRange: _incomeController.selectedTimeRange.value,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF report generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error generating PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "General Dashboard",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isGeneratingPDF ? null : _generatePDF,
                icon: _isGeneratingPDF
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf, size: 20),
                label: Text(
                  _isGeneratingPDF ? 'Generating...' : 'Export PDF',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E6BE0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadiusDirectional.circular(15),
                border:
                    Border.all(width: 1, color: Colors.grey.withOpacity(0.5))),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
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
                        icon: Icons.bar_chart_outlined,
                        title: "Total Revenue",
                        value: "₱ ${_controller.totalRevenue}",
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: InfoCard(
                        icon: Icons.shopping_cart_outlined,
                        title: "Total Orders",
                        value: "${_controller.totalOrders}",
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
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
