# GLB Storage Service

This service provides local caching for 3D model files (GLB format) using GetX Storage, eliminating the need to download GLB files every time they're viewed.

## Features

- **Local Caching**: GLB files are downloaded once and stored locally
- **CORS Bypass**: Converts remote URLs to data URIs to avoid CORS issues
- **Cache Management**: View cache statistics and clear cache when needed
- **Automatic Fallback**: Falls back to original URL if caching fails
- **Memory Efficient**: Uses base64 encoding for storage

## Usage

### Basic Usage

```dart
// Get or cache a GLB file
final dataUri = await GlbStorageService.getOrCacheGlb('https://example.com/model.glb');

// Check if a file is cached
bool isCached = GlbStorageService.isCached('https://example.com/model.glb');

// Get cached file directly
String? cachedData = GlbStorageService.getCachedGlb('https://example.com/model.glb');
```

### Cache Management

```dart
// Get cache statistics
final stats = GlbStorageService.getCacheStats();
print('Cached files: ${stats['total_files']}');
print('Total size: ${stats['total_size_mb']} MB');

// Clear all cache
await GlbStorageService.clearCache();

// Clear specific file
await GlbStorageService.clearSpecificCache('https://example.com/model.glb');

// Get all cached URLs
final urls = GlbStorageService.getCachedUrls();
```

## Integration with ModelViewerScreen

The `ModelViewerScreen` automatically uses this service:

1. **First Load**: Downloads and caches the GLB file
2. **Subsequent Loads**: Uses cached version (instant loading)
3. **Cache Indicator**: Shows "Cached" badge when using cached files
4. **Cache Management**: Storage icon in app bar shows cache info

## Benefits

- **Faster Loading**: Cached files load instantly
- **Reduced Bandwidth**: Files downloaded only once
- **Offline Support**: Cached files work without internet
- **CORS Solution**: Data URIs bypass CORS restrictions
- **Storage Efficient**: Automatic cleanup and management

## Storage Structure

```
GetStorage Keys:
- glb_<md5_hash>: Base64 encoded GLB file data
- glb_metadata: Cache metadata (URLs, timestamps, file sizes)
```

## Error Handling

- **Download Failures**: Falls back to original URL
- **Storage Errors**: Gracefully handles storage issues
- **Invalid URLs**: Returns original URL as fallback
- **Network Issues**: Shows retry option in UI

## Performance

- **First Load**: ~2-5 seconds (download + cache)
- **Cached Load**: ~100-200ms (instant)
- **Storage Size**: ~1-10MB per model (depending on complexity)
- **Memory Usage**: Minimal (base64 strings)

## Cache Lifecycle

1. **Download**: GLB file downloaded from URL
2. **Encode**: Converted to base64 data URI
3. **Store**: Saved to GetStorage with metadata
4. **Retrieve**: Loaded from cache on subsequent views
5. **Cleanup**: Can be cleared manually or automatically

This implementation provides a seamless 3D model viewing experience with intelligent caching and CORS handling.
