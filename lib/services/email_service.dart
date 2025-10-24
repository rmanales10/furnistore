import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Gmail SMTP configuration
  static const String _smtpServer = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _username = 'furnistoreofficial@gmail.com';
  static const String _password = 'dxfa nygz mmrt vjjx';
  static const String _fromEmail = 'furnistoreofficial@gmail.com';
  static const String _fromName = 'FurniStore Official';

  /// Send seller approval notification email
  static Future<Map<String, dynamic>> sendSellerApprovalEmail({
    required String sellerEmail,
    required String sellerName,
    required String storeName,
  }) async {
    try {
      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        _smtpServer,
        port: _smtpPort,
        username: _username,
        password: _password,
        allowInsecure: false,
        ignoreBadCertificate: false,
      );

      // Create email message
      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(sellerEmail)
        ..subject = '🎉 Your Seller Application Has Been Approved!'
        ..html = _buildApprovalEmailHTML(sellerName, storeName)
        ..text = _buildApprovalEmailText(sellerName, storeName);

      // Send email
      final sendReport = await send(message, smtpServer);

      print('✅ Email sent successfully to $sellerEmail');
      print('📧 Send report: ${sendReport.toString()}');

      return {
        'success': true,
        'message': 'Approval email sent successfully',
        'recipient': sellerEmail,
      };
    } catch (e) {
      print('❌ Error sending approval email: $e');
      return {
        'success': false,
        'error': 'Failed to send approval email: $e',
      };
    }
  }

  /// Send seller rejection notification email
  static Future<Map<String, dynamic>> sendSellerRejectionEmail({
    required String sellerEmail,
    required String sellerName,
    required String storeName,
    required String reason,
  }) async {
    try {
      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        _smtpServer,
        port: _smtpPort,
        username: _username,
        password: _password,
        allowInsecure: false,
        ignoreBadCertificate: false,
      );

      // Create email message
      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(sellerEmail)
        ..subject = '📋 Seller Application Update - Action Required'
        ..html = _buildRejectionEmailHTML(sellerName, storeName, reason)
        ..text = _buildRejectionEmailText(sellerName, storeName, reason);

      // Send email
      final sendReport = await send(message, smtpServer);

      print('✅ Rejection email sent successfully to $sellerEmail');
      print('📧 Send report: ${sendReport.toString()}');

      return {
        'success': true,
        'message': 'Rejection email sent successfully',
        'recipient': sellerEmail,
      };
    } catch (e) {
      print('❌ Error sending rejection email: $e');
      return {
        'success': false,
        'error': 'Failed to send rejection email: $e',
      };
    }
  }

  /// Build HTML content for approval email
  static String _buildApprovalEmailHTML(String sellerName, String storeName) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Application Approved - FurniStore</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f8f9fa;
            }
            .container {
                background-color: white;
                border-radius: 10px;
                padding: 30px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            }
            .header {
                text-align: center;
                margin-bottom: 30px;
            }
            .success-icon {
                width: 80px;
                height: 80px;
                background-color: #28a745;
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 20px;
            }
            .success-icon::before {
                content: "✓";
                color: white;
                font-size: 40px;
                font-weight: bold;
            }
            h1 {
                color: #28a745;
                margin: 0;
                font-size: 28px;
            }
            .status-badge {
                background-color: #d4edda;
                color: #155724;
                padding: 8px 16px;
                border-radius: 20px;
                display: inline-block;
                margin: 10px 0;
                font-weight: bold;
            }
            .content {
                margin: 30px 0;
            }
            .highlight-box {
                background-color: #e3f2fd;
                border-left: 4px solid #2196f3;
                padding: 20px;
                margin: 20px 0;
                border-radius: 0 5px 5px 0;
            }
            .help-box {
                background-color: #e8f5e8;
                border-left: 4px solid #28a745;
                padding: 20px;
                margin: 20px 0;
                border-radius: 0 5px 5px 0;
            }
            .cta-button {
                display: inline-block;
                background-color: #007bff;
                color: white;
                padding: 15px 30px;
                text-decoration: none;
                border-radius: 5px;
                font-weight: bold;
                margin: 20px 0;
                text-align: center;
            }
            .cta-button:hover {
                background-color: #0056b3;
            }
            .footer {
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #eee;
                text-align: center;
                color: #666;
                font-size: 14px;
            }
            ul {
                padding-left: 20px;
            }
            li {
                margin: 8px 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="success-icon"></div>
                <h1>Application Approved!</h1>
                <div class="status-badge">Status: Approved</div>
            </div>
            
            <div class="content">
                <p>Dear <strong>$sellerName</strong>,</p>
                
                <p>Congratulations! Your seller application for <strong>$storeName</strong> has been successfully approved. You can now start selling on FurniStore!</p>
                
                <div class="highlight-box">
                    <h3>What now?</h3>
                    <ul>
                        <li>Your seller account is now active</li>
                        <li>Head over to your Seller Dashboard to add products and manage your store</li>
                        <li>Make sure to complete your store profile for better visibility</li>
                    </ul>
                </div>
                
                <div class="help-box">
                    <h3>Need help?</h3>
                    <p>Contact our support team at <a href="mailto:furnistoreofficial@gmail.com">furnistoreofficial@gmail.com</a> if you need assistance with your seller account.</p>
                </div>
                
                <div style="text-align: center;">
                    <a href="#" class="cta-button">Go to Seller Dashboard</a>
                </div>
            </div>
            
            <div class="footer">
                <p>Thank you for choosing FurniStore!</p>
                <p>Best regards,<br>The FurniStore Team</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build text content for approval email
  static String _buildApprovalEmailText(String sellerName, String storeName) {
    return '''
Application Approved!

Dear $sellerName,

Congratulations! Your seller application for $storeName has been successfully approved. You can now start selling on FurniStore!

What now?
- Your seller account is now active
- Head over to your Seller Dashboard to add products and manage your store
- Make sure to complete your store profile for better visibility

Need help?
Contact our support team at furnistoreofficial@gmail.com if you need assistance with your seller account.

Thank you for choosing FurniStore!

Best regards,
The FurniStore Team
    ''';
  }

  /// Build HTML content for rejection email
  static String _buildRejectionEmailHTML(
      String sellerName, String storeName, String reason) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Application Update - FurniStore</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f8f9fa;
            }
            .container {
                background-color: white;
                border-radius: 10px;
                padding: 30px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            }
            .header {
                text-align: center;
                margin-bottom: 30px;
            }
            .info-icon {
                width: 80px;
                height: 80px;
                background-color: #ffc107;
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 20px;
            }
            .info-icon::before {
                content: "ℹ";
                color: white;
                font-size: 40px;
                font-weight: bold;
            }
            h1 {
                color: #ffc107;
                margin: 0;
                font-size: 28px;
            }
            .status-badge {
                background-color: #fff3cd;
                color: #856404;
                padding: 8px 16px;
                border-radius: 20px;
                display: inline-block;
                margin: 10px 0;
                font-weight: bold;
            }
            .content {
                margin: 30px 0;
            }
            .reason-box {
                background-color: #f8d7da;
                border-left: 4px solid #dc3545;
                padding: 20px;
                margin: 20px 0;
                border-radius: 0 5px 5px 0;
            }
            .help-box {
                background-color: #e3f2fd;
                border-left: 4px solid #2196f3;
                padding: 20px;
                margin: 20px 0;
                border-radius: 0 5px 5px 0;
            }
            .cta-button {
                display: inline-block;
                background-color: #007bff;
                color: white;
                padding: 15px 30px;
                text-decoration: none;
                border-radius: 5px;
                font-weight: bold;
                margin: 20px 0;
                text-align: center;
            }
            .cta-button:hover {
                background-color: #0056b3;
            }
            .footer {
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #eee;
                text-align: center;
                color: #666;
                font-size: 14px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <div class="info-icon"></div>
                <h1>Application Update</h1>
                <div class="status-badge">Status: Rejected</div>
            </div>
            
            <div class="content">
                <p>Dear <strong>$sellerName</strong>,</p>
                
                <p>Thank you for your interest in becoming a seller on FurniStore. After careful review, we regret to inform you that your application for <strong>$storeName</strong> has not been approved at this time.</p>
                
                <div class="reason-box">
                    <h3>Reason for Rejection:</h3>
                    <p>$reason</p>
                </div>
                
                <div class="help-box">
                    <h3>What can you do?</h3>
                    <ul>
                        <li>Review the feedback provided above</li>
                        <li>Make necessary improvements to your application</li>
                        <li>Submit a new application when ready</li>
                        <li>Contact our support team for guidance</li>
                    </ul>
                </div>
                
                <p>If you have any questions or need clarification, please don't hesitate to contact our support team at <a href="mailto:furnistoreofficial@gmail.com">furnistoreofficial@gmail.com</a>.</p>
                
                <div style="text-align: center;">
                    <a href="#" class="cta-button">Apply Again</a>
                </div>
            </div>
            
            <div class="footer">
                <p>We appreciate your interest in FurniStore!</p>
                <p>Best regards,<br>The FurniStore Team</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build text content for rejection email
  static String _buildRejectionEmailText(
      String sellerName, String storeName, String reason) {
    return '''
Application Update

Dear $sellerName,

Thank you for your interest in becoming a seller on FurniStore. After careful review, we regret to inform you that your application for $storeName has not been approved at this time.

Reason for Rejection:
$reason

What can you do?
- Review the feedback provided above
- Make necessary improvements to your application
- Submit a new application when ready
- Contact our support team for guidance

If you have any questions or need clarification, please don't hesitate to contact our support team at furnistoreofficial@gmail.com.

We appreciate your interest in FurniStore!

Best regards,
The FurniStore Team
    ''';
  }
}
