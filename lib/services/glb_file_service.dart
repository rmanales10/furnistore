import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class GlbFileService {
  static const String _glbFolderName = 'glb_models';

  /// Get the local directory for storing GLB files
  static Future<Directory> _getGlbDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final glbDir = Directory('${appDir.path}/$_glbFolderName');

    if (!await glbDir.exists()) {
      await glbDir.create(recursive: true);
    }

    return glbDir;
  }

  /// Generate a unique filename for the GLB file based on URL
  static String _generateFileName(String url) {
    // Extract task ID from Meshy AI URLs
    if (url.contains('assets.meshy.ai') && url.contains('tasks/')) {
      final taskMatch = RegExp(r'tasks/([^/]+)').firstMatch(url);
      if (taskMatch != null) {
        return 'meshy_${taskMatch.group(1)}.glb';
      }
    }

    // Fallback to hash-based filename
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return '${digest.toString().substring(0, 16)}.glb';
  }

  /// Check if a GLB file exists locally
  static Future<bool> isGlbCached(String url) async {
    try {
      final glbDir = await _getGlbDirectory();
      final fileName = _generateFileName(url);
      final file = File('${glbDir.path}/$fileName');
      return await file.exists();
    } catch (e) {
      print('Error checking GLB cache: $e');
      return false;
    }
  }

  /// Get the local file path for a GLB URL
  static Future<String?> getLocalGlbPath(String url) async {
    try {
      final glbDir = await _getGlbDirectory();
      final fileName = _generateFileName(url);
      final file = File('${glbDir.path}/$fileName');

      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      print('Error getting local GLB path: $e');
      return null;
    }
  }

  /// Download and save GLB file locally
  static Future<String?> downloadAndCacheGlb(String url) async {
    try {
      print('🔄 Downloading GLB from: $url');

      // Check if already cached
      if (await isGlbCached(url)) {
        print('✅ GLB already cached locally');
        return await getLocalGlbPath(url);
      }

      // Download the file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to download GLB: HTTP ${response.statusCode}');
      }

      if (response.bodyBytes.isEmpty) {
        throw Exception('Downloaded GLB file is empty');
      }

      // Save to local storage
      final glbDir = await _getGlbDirectory();
      final fileName = _generateFileName(url);
      final file = File('${glbDir.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      print('✅ GLB saved locally: ${file.path}');
      print('📊 File size: ${response.bodyBytes.length} bytes');

      return file.path;
    } catch (e) {
      print('❌ Error downloading GLB: $e');
      return null;
    }
  }

  /// Get or download GLB file (cached if available, download if not)
  static Future<String?> getOrDownloadGlb(String url) async {
    try {
      // First check if already cached
      final localPath = await getLocalGlbPath(url);
      if (localPath != null) {
        print('✅ Using cached GLB: $localPath');
        return localPath;
      }

      // Download if not cached
      return await downloadAndCacheGlb(url);
    } catch (e) {
      print('❌ Error getting GLB: $e');
      return null;
    }
  }

  /// Get GLB file as data URI (for ModelViewer compatibility)
  static Future<String?> getGlbAsDataUri(String url) async {
    try {
      final localPath = await getOrDownloadGlb(url);
      if (localPath == null) return null;

      final file = File(localPath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      return 'data:model/gltf-binary;base64,$base64';
    } catch (e) {
      print('❌ Error converting GLB to data URI: $e');
      return null;
    }
  }

  /// Clear all cached GLB files
  static Future<void> clearCache() async {
    try {
      final glbDir = await _getGlbDirectory();
      if (await glbDir.exists()) {
        await glbDir.delete(recursive: true);
        print('✅ GLB cache cleared');
      }
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final glbDir = await _getGlbDirectory();
      if (!await glbDir.exists()) {
        return {
          'total_files': 0,
          'total_size_mb': '0.00',
          'files': <String>[],
        };
      }

      final files = await glbDir.list().toList();
      int totalSize = 0;
      final fileList = <String>[];

      for (final file in files) {
        if (file is File && file.path.endsWith('.glb')) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileList.add(file.path.split('/').last);
        }
      }

      return {
        'total_files': fileList.length,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'files': fileList,
      };
    } catch (e) {
      print('❌ Error getting cache stats: $e');
      return {
        'total_files': 0,
        'total_size_mb': '0.00',
        'files': <String>[],
      };
    }
  }

  /// Delete a specific GLB file
  static Future<bool> deleteGlb(String url) async {
    try {
      final localPath = await getLocalGlbPath(url);
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
          print('✅ Deleted GLB: $localPath');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error deleting GLB: $e');
      return false;
    }
  }
}
