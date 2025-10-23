import 'dart:convert';
import 'package:http/http.dart' as http;

class MeshyAIService {
  // Meshy AI API key - keep this secure in production
  static const String _apiKey = 'msy_QJHIp1Yf3JxbmCJd9oDOuCrr6A0f2ZatYqKp';
  static const String _baseUrl = 'https://api.meshy.ai/openapi/v1';

  /// Generate a 3D model from an image using Meshy AI
  static Future<String> generate3DModel(String base64Image) async {
    final String imageTo3dUrl = '$_baseUrl/image-to-3d';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    // Updated parameters based on official Meshy AI API documentation
    final Map<String, dynamic> body = {
      'image_url': 'data:image/jpeg;base64,$base64Image',
      'ai_model': 'meshy-5', // Use meshy-5 as default
      'enable_pbr': true, // Enable PBR materials
      'should_remesh': true, // Enable remeshing
      'should_texture': true, // Enable texturing
    };

    print('🔗 Making request to: $imageTo3dUrl');
    print('📋 Request body: ${jsonEncode(body)}');
    print('🔑 Headers: $headers');

    final response = await http.post(
      Uri.parse(imageTo3dUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 202) {
      final responseData = jsonDecode(response.body);
      return responseData['result']; // Returns the task ID
    } else {
      throw Exception(
          'Failed to start 3D generation: ${response.statusCode} - ${response.body}');
    }
  }

  /// Check the status of a 3D model generation task
  static Future<Map<String, dynamic>> checkGenerationStatus(
      String taskId) async {
    final String statusUrl = '$_baseUrl/image-to-3d/$taskId';

    print('🔗 Checking status at: $statusUrl');

    final response = await http.get(
      Uri.parse(statusUrl),
      headers: {'Authorization': 'Bearer $_apiKey'},
    );

    print('📊 Status response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to check status: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get the 3D model URL from a completed task
  static String? getModelUrl(Map<String, dynamic> statusResponse) {
    if (statusResponse['status'] == 'SUCCEEDED') {
      // Check if model_urls exists directly in the response
      if (statusResponse['model_urls'] != null) {
        return statusResponse['model_urls']['glb'];
      }
      // Fallback to nested result structure
      if (statusResponse['result'] != null &&
          statusResponse['result']['model_urls'] != null) {
        return statusResponse['result']['model_urls']['glb'];
      }
    }
    return null;
  }

  /// Check if the generation is still in progress
  static bool isInProgress(Map<String, dynamic> statusResponse) {
    return statusResponse['status'] == 'IN_PROGRESS' ||
        statusResponse['status'] == 'PENDING';
  }

  /// Check if the generation failed
  static bool isFailed(Map<String, dynamic> statusResponse) {
    return statusResponse['status'] == 'FAILED';
  }

  /// Get the progress percentage if available
  static int? getProgress(Map<String, dynamic> statusResponse) {
    return statusResponse['progress']?.toInt();
  }

  /// Get the estimated time remaining if available
  static int? getEstimatedTime(Map<String, dynamic> statusResponse) {
    return statusResponse['estimated_time']?.toInt();
  }

  /// Get all available model URLs (GLB, OBJ, etc.)
  static Map<String, String>? getAllModelUrls(
      Map<String, dynamic> statusResponse) {
    if (statusResponse['status'] == 'SUCCEEDED') {
      // Check if model_urls exists directly in the response
      if (statusResponse['model_urls'] != null) {
        return Map<String, String>.from(statusResponse['model_urls']);
      }
      // Fallback to nested result structure
      if (statusResponse['result'] != null &&
          statusResponse['result']['model_urls'] != null) {
        return Map<String, String>.from(statusResponse['result']['model_urls']);
      }
    }
    return null;
  }

  /// Get the thumbnail URL if available
  static String? getThumbnailUrl(Map<String, dynamic> statusResponse) {
    if (statusResponse['status'] == 'SUCCEEDED') {
      // Check if thumbnail_url exists directly in the response
      if (statusResponse['thumbnail_url'] != null) {
        return statusResponse['thumbnail_url'];
      }
      // Fallback to nested result structure
      if (statusResponse['result'] != null &&
          statusResponse['result']['thumbnail_url'] != null) {
        return statusResponse['result']['thumbnail_url'];
      }
    }
    return null;
  }

  /// Test the API connection and authentication (without creating a task)
  static Future<bool> testConnection() async {
    try {
      // Try to make a simple request to test the API without creating a task
      final response = await http.get(
        Uri.parse('$_baseUrl/image-to-3d'),
        headers: {'Authorization': 'Bearer $_apiKey'},
      );

      print('🧪 API Test - Status: ${response.statusCode}');
      print('🧪 API Test - Response: ${response.body}');

      // Even if it's a 405 (Method Not Allowed), it means the endpoint exists
      return response.statusCode == 200 || response.statusCode == 405;
    } catch (e) {
      print('🧪 API Test - Error: $e');
      return false;
    }
  }

  /// Get task status without polling (for manual checking)
  static Future<Map<String, dynamic>?> getTaskStatus(String taskId) async {
    try {
      final statusResponse = await checkGenerationStatus(taskId);
      return statusResponse;
    } catch (e) {
      print('❌ Error getting task status: $e');
      return null;
    }
  }

  /// Check if task is completed (SUCCEEDED or FAILED)
  static bool isTaskCompleted(Map<String, dynamic> statusResponse) {
    final status = statusResponse['status'];
    return status == 'SUCCEEDED' || status == 'FAILED' || status == 'CANCELED';
  }

  /// Get texture URLs if available
  static List<Map<String, String>>? getTextureUrls(
      Map<String, dynamic> statusResponse) {
    if (statusResponse['status'] == 'SUCCEEDED' &&
        statusResponse['texture_urls'] != null) {
      return List<Map<String, String>>.from(statusResponse['texture_urls']
          .map((texture) => Map<String, String>.from(texture)));
    }
    return null;
  }

  /// Get estimated cost for a generation task
  static int getEstimatedCost() {
    // Based on Meshy AI pricing:
    // - Base generation: 5 credits (meshy-5)
    // - PBR materials: +10 credits (enable_pbr: true)
    // - Texturing: +10 credits (should_texture: true)
    // - Remeshing: included in base cost
    return 25; // Total estimated cost
  }
}
