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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller.fetchDataFromFirestore();
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await _controller.fetchDataFromFirestore();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
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
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "General Dashboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Refresh button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: IconButton(
                            icon: _isRefreshing
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color(0xFF3E6BE0)),
                                    ),
                                  )
                                : Icon(Icons.refresh, size: 18),
                            color: const Color(0xFF3E6BE0),
                            onPressed: _isRefreshing ? null : _refreshDashboard,
                            tooltip: 'Refresh dashboard',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGeneratingPDF ? null : _generatePDF,
                        icon: _isGeneratingPDF
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "General Dashboard",
                      style: TextStyle(
                        fontSize: isTablet ? 26 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Refresh button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: IconButton(
                            icon: _isRefreshing
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color(0xFF3E6BE0)),
                                    ),
                                  )
                                : Icon(Icons.refresh, size: 18),
                            color: const Color(0xFF3E6BE0),
                            onPressed: _isRefreshing ? null : _refreshDashboard,
                            tooltip: 'Refresh dashboard',
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isGeneratingPDF ? null : _generatePDF,
                          icon: _isGeneratingPDF
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
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
                  ],
                ),
          SizedBox(height: isMobile ? 16 : 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadiusDirectional.circular(15),
                border:
                    Border.all(width: 1, color: Colors.grey.withOpacity(0.5))),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Obx(() {
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
                            icon: Icons.bar_chart_outlined,
                            title: "Total Revenue",
                            value: "₱ ${_controller.totalRevenue}",
                            isMobile: isMobile,
                          ),
                          SizedBox(height: 16),
                          InfoCard(
                            icon: Icons.shopping_cart_outlined,
                            title: "Total Orders",
                            value: "${_controller.totalOrders}",
                            isMobile: isMobile,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: isTablet ? 40 : 100,
                              left: 10,
                            ),
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
                              icon: Icons.bar_chart_outlined,
                              title: "Total Revenue",
                              value: "₱ ${_controller.totalRevenue}",
                              isMobile: isMobile,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 20),
                          Expanded(
                            child: InfoCard(
                              icon: Icons.shopping_cart_outlined,
                              title: "Total Orders",
                              value: "${_controller.totalOrders}",
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      );
              }),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
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
              Flexible(
                child: Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 28 : 45),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
