import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:furnistore/config/semaphore_config.dart';

class SemaphoreService {
  static const String _baseUrl = 'https://api.semaphore.co/api/v4';

  /// Send OTP to phone number using Semaphore OTP endpoint
  static Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
    required String message,
    String? customCode,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/otp');

      final body = {
        'apikey': SemaphoreConfig.apiKey,
        'number': phoneNumber,
        'message': message,
      };

      // Add custom code if provided
      if (customCode != null) {
        body['code'] = customCode;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to send OTP: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error sending OTP: $e',
      };
    }
  }

  /// Send regular SMS message
  static Future<Map<String, dynamic>> sendSMS({
    required String phoneNumber,
    required String message,
    String senderName = 'FurniStore',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/messages');

      final body = {
        'apikey': SemaphoreConfig.apiKey,
        'number': phoneNumber,
        'message': message,
        'sendername': SemaphoreConfig.senderName,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to send SMS: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error sending SMS: $e',
      };
    }
  }

  /// Generate a random 6-digit OTP
  static String generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }
}
