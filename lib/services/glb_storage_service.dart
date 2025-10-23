import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class GlbStorageService {
  static final GetStorage _storage = GetStorage();
  static const String _glbMetadataKey = 'glb_metadata';

  /// Initialize GetStorage
  static Future<void> init() async {
    await GetStorage.init();
  }

  /// Generate a cache key from URL
  static String _generateCacheKey(String url) {
    var bytes = utf8.encode(url);
    var digest = md5.convert(bytes);
    return 'glb_${digest.toString()}';
  }

  /// Check if GLB file is cached
  static bool isCached(String url) {
    final cacheKey = _generateCacheKey(url);
    return _storage.hasData(cacheKey);
  }

  /// Get cached GLB file as base64 data URI
  static String? getCachedGlb(String url) {
    if (!isCached(url)) return null;

    final cacheKey = _generateCacheKey(url);
    final cachedData = _storage.read(cacheKey);

    if (cachedData != null) {
      return 'data:model/gltf-binary;base64,$cachedData';
    }
    return null;
  }

  /// Cache GLB file from URL
  static Future<String?> cacheGlbFromUrl(String url) async {
    try {
      print('🔄 Downloading GLB from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final base64Data = base64Encode(response.bodyBytes);
        final cacheKey = _generateCacheKey(url);

        // Store the base64 data
        await _storage.write(cacheKey, base64Data);

        // Store metadata (URL, timestamp, file size)
        final metadata = {
          'url': url,
          'cached_at': DateTime.now().millisecondsSinceEpoch,
          'file_size': response.bodyBytes.length,
          'content_type':
              response.headers['content-type'] ?? 'model/gltf-binary',
        };

        final existingMetadata =
            _storage.read(_glbMetadataKey) ?? <String, dynamic>{};
        existingMetadata[cacheKey] = metadata;
        await _storage.write(_glbMetadataKey, existingMetadata);

        print('✅ GLB cached successfully: ${response.bodyBytes.length} bytes');
        return 'data:model/gltf-binary;base64,$base64Data';
      } else {
        print('❌ Failed to download GLB: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error caching GLB: $e');
      return null;
    }
  }

  /// Get or cache GLB file (returns data URI)
  static Future<String> getOrCacheGlb(String url) async {
    // First check if already cached
    final cached = getCachedGlb(url);
    if (cached != null) {
      print('📦 Using cached GLB');
      return cached;
    }

    // Download and cache
    final dataUri = await cacheGlbFromUrl(url);
    if (dataUri != null) {
      return dataUri;
    }

    // Fallback to original URL if caching fails
    print('⚠️ Falling back to original URL');
    return url;
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final metadata = _storage.read(_glbMetadataKey) ?? <String, dynamic>{};
    int totalFiles = 0;
    int totalSize = 0;
    DateTime? oldestCache;
    DateTime? newestCache;

    for (var data in metadata.values) {
      if (data is Map<String, dynamic>) {
        totalFiles++;
        totalSize += ((data['file_size'] as num?)?.toInt()) ?? 0;

        final cachedAt =
            DateTime.fromMillisecondsSinceEpoch(data['cached_at'] ?? 0);
        if (oldestCache == null || cachedAt.isBefore(oldestCache)) {
          oldestCache = cachedAt;
        }
        if (newestCache == null || cachedAt.isAfter(newestCache)) {
          newestCache = cachedAt;
        }
      }
    }

    return {
      'total_files': totalFiles,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'oldest_cache': oldestCache?.toIso8601String(),
      'newest_cache': newestCache?.toIso8601String(),
    };
  }

  /// Clear all cached GLB files
  static Future<void> clearCache() async {
    final metadata = _storage.read(_glbMetadataKey) ?? <String, dynamic>{};

    for (var key in metadata.keys) {
      await _storage.remove(key);
    }

    await _storage.remove(_glbMetadataKey);
    print('🗑️ GLB cache cleared');
  }

  /// Clear specific GLB cache
  static Future<void> clearSpecificCache(String url) async {
    final cacheKey = _generateCacheKey(url);
    await _storage.remove(cacheKey);

    // Remove from metadata
    final metadata = _storage.read(_glbMetadataKey) ?? <String, dynamic>{};
    metadata.remove(cacheKey);
    await _storage.write(_glbMetadataKey, metadata);

    print('🗑️ Cleared cache for: $url');
  }

  /// Get all cached URLs
  static List<String> getCachedUrls() {
    final metadata = _storage.read(_glbMetadataKey) ?? <String, dynamic>{};
    return metadata.values
        .whereType<Map<String, dynamic>>()
        .map((data) => data['url'] as String)
        .toList();
  }
}
