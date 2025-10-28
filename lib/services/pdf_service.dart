import 'dart:developer';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PDFService {
  /// Generate and download dashboard PDF report
  static Future<void> generateDashboardReport({
    required double totalRevenue,
    required int totalOrders,
    required List<double> monthlyIncome,
    required String timeRange,
  }) async {
    try {
      log('📄 Starting PDF generation...');

      final pdf = pw.Document();

      // Calculate statistics
      final totalIncome = monthlyIncome.reduce((a, b) => a + b);
      final maxIncome = monthlyIncome.reduce((a, b) => a > b ? a : b);
      final avgIncome = totalIncome / 12;

      // Find best month
      final bestMonthIndex = monthlyIncome.indexOf(maxIncome);
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

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Header
            _buildHeader(),
            pw.SizedBox(height: 30),

            // Report Title
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#3E6BE0'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Dashboard Report',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated: ${DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Period: $timeRange',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Performance Overview Section
            pw.Text(
              'Performance Overview',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#2c3e50'),
              ),
            ),
            pw.SizedBox(height: 15),

            // Metrics Cards
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildMetricCard(
                    title: 'Total Revenue',
                    value: 'PHP ${totalRevenue.toStringAsFixed(2)}',
                    icon: '[Revenue]',
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: _buildMetricCard(
                    title: 'Total Orders',
                    value: totalOrders.toString(),
                    icon: '[Orders]',
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Income Statistics Section
            pw.Text(
              'Income Statistics',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#2c3e50'),
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8F9FA'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                border: pw.Border.all(
                  color: PdfColor.fromHex('#E9ECEF'),
                  width: 1,
                ),
              ),
              child: pw.Column(
                children: [
                  _buildStatRow(
                      'Total Income', 'PHP ${totalIncome.toStringAsFixed(2)}'),
                  pw.Divider(height: 20),
                  _buildStatRow('Average Monthly Income',
                      'PHP ${avgIncome.toStringAsFixed(2)}'),
                  pw.Divider(height: 20),
                  _buildStatRow('Highest Monthly Income',
                      'PHP ${maxIncome.toStringAsFixed(2)}'),
                  pw.Divider(height: 20),
                  _buildStatRow('Best Month', months[bestMonthIndex]),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Monthly Breakdown Section
            pw.Text(
              'Monthly Income Breakdown',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#2c3e50'),
              ),
            ),
            pw.SizedBox(height: 15),

            // Monthly Income Table
            _buildMonthlyTable(monthlyIncome),
            pw.SizedBox(height: 30),

            // Chart
            pw.Text(
              'Income Chart',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#2c3e50'),
              ),
            ),
            pw.SizedBox(height: 15),
            _buildIncomeChart(monthlyIncome),
            pw.SizedBox(height: 30),

            // Footer note
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#E8F5E8'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.only(right: 8),
                    child: pw.Text(
                      'Note:',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#2c3e50'),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'This report is automatically generated from your FurniStore dashboard data.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColor.fromHex('#2c3e50'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          footer: (context) => _buildFooter(context),
        ),
      );

      // Save or print PDF
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );

      log('✅ PDF generated successfully');
    } catch (e) {
      log('❌ Error generating PDF: $e');
      rethrow;
    }
  }

  /// Build PDF header
  static pw.Widget _buildHeader() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromHex('#E9ECEF'),
            width: 2,
          ),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FurniStore',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#3E6BE0'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Business Analytics Report',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('#6c757d'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build metric card
  static pw.Widget _buildMetricCard({
    required String title,
    required String value,
    required String icon,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(
          color: PdfColor.fromHex('#E9ECEF'),
          width: 2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E8F0FE'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              icon,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#3E6BE0'),
              ),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColor.fromHex('#6c757d'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#2c3e50'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build stat row
  static pw.Widget _buildStatRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColor.fromHex('#6c757d'),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#2c3e50'),
          ),
        ),
      ],
    );
  }

  /// Build monthly income table
  static pw.Widget _buildMonthlyTable(List<double> monthlyIncome) {
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

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('#E9ECEF'),
        width: 1,
      ),
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F8F9FA'),
          ),
          children: [
            _buildTableCell('Month', isHeader: true),
            _buildTableCell('Income', isHeader: true),
          ],
        ),
        // Data rows
        ...List.generate(12, (index) {
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color:
                  index.isEven ? PdfColors.white : PdfColor.fromHex('#F8F9FA'),
            ),
            children: [
              _buildTableCell(months[index]),
              _buildTableCell('PHP ${monthlyIncome[index].toStringAsFixed(2)}'),
            ],
          );
        }),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColor.fromHex(isHeader ? '#2c3e50' : '#495057'),
        ),
      ),
    );
  }

  /// Build income chart
  static pw.Widget _buildIncomeChart(List<double> monthlyIncome) {
    final maxIncome = monthlyIncome.reduce((a, b) => a > b ? a : b);

    if (maxIncome == 0) {
      return pw.Container(
        height: 200,
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F8F9FA'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        ),
        child: pw.Center(
          child: pw.Text(
            'No income data available',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#6c757d'),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

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

    return pw.Container(
      height: 200,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColor.fromHex('#E9ECEF'),
          width: 1,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Chart(
        grid: pw.CartesianGrid(
          xAxis: pw.FixedAxis.fromStrings(
            List.generate(12, (index) => months[index]),
            marginStart: 30,
            marginEnd: 10,
          ),
          yAxis: pw.FixedAxis(
            [0, maxIncome / 4, maxIncome / 2, (maxIncome * 3) / 4, maxIncome],
            format: (value) => 'PHP ${(value / 1000).toStringAsFixed(0)}K',
            divisions: true,
          ),
        ),
        datasets: [
          pw.BarDataSet(
            color: PdfColor.fromHex('#3E6BE0'),
            legend: 'Monthly Income',
            width: 15,
            data: List.generate(
              12,
              (index) =>
                  pw.PointChartValue(index.toDouble(), monthlyIncome[index]),
            ),
          ),
        ],
      ),
    );
  }

  /// Build PDF footer
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColor.fromHex('#6c757d'),
        ),
      ),
    );
  }
}
