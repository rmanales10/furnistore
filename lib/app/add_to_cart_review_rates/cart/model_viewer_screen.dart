import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furnistore/services/glb_file_service.dart';

class ModelViewerScreen extends StatefulWidget {
  const ModelViewerScreen({super.key, this.productId, this.glbUrl});

  /// Firestore `products/{productId}` document id. If provided, the screen
  /// will fetch the GLB url from `model_3d.model_urls.glb`, falling back to
  /// `model_3d.primary_url` when needed.
  final String? productId;

  /// Optional direct GLB url. If provided, fetching from Firestore is skipped.
  final String? glbUrl;

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Future<String>? _glbFuture;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    // Add a timeout to prevent infinite loading
    _addTimeout();
    // Initialize the GLB future once
    _glbFuture = _prepareSrc();
  }

  @override
  void dispose() {
    // Clean up any ongoing operations
    super.dispose();
  }

  Future<void> _initializeStorage() async {
    // Initialize GLB file service
    print('🔄 Initializing GLB file service...');
  }

  void _addTimeout() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Loading timeout. Please try again.';
        });
      }
    });
  }

  Future<String> _loadGlbUrl() async {
    print('🔍 Loading GLB URL...');
    print('🔍 Widget glbUrl: ${widget.glbUrl}');
    print('🔍 Widget productId: ${widget.productId}');

    // 1) Prefer explicit constructor param
    if (widget.glbUrl != null && widget.glbUrl!.isNotEmpty) {
      print('✅ Using widget glbUrl');
      return widget.glbUrl!;
    }

    // 2) Try route arguments: can be String (glbUrl) or Map with keys
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    print('🔍 Route arguments: $routeArgs');
    if (routeArgs is String && routeArgs.isNotEmpty) {
      print('✅ Using route string argument');
      return routeArgs; // treat as direct glb url
    }
    String? argProductId;
    String? argGlb;
    if (routeArgs is Map) {
      final map = Map<String, dynamic>.from(routeArgs);
      argGlb = (map['glbUrl'] ?? map['glb'] ?? '') as String?;
      argProductId = (map['productId'] ?? '') as String?;
      print('🔍 Route map - glbUrl: $argGlb, productId: $argProductId');
      if (argGlb != null && argGlb.isNotEmpty) {
        print('✅ Using route glbUrl');
        return argGlb;
      }
    }

    // 3) Use productId from widget or route map
    final productId = (widget.productId != null && widget.productId!.isNotEmpty)
        ? widget.productId!
        : (argProductId ?? '');
    print('🔍 Final productId: $productId');

    if (productId.isEmpty) {
      print('⚠️ No productId, using fallback URL');
      // Fallback to a public GLB to avoid crashing if no params are passed
      return 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';
    }

    print('🔍 Fetching product from Firestore...');
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (!doc.exists) {
      print('❌ Product not found in Firestore');
      throw Exception('Product not found');
    }

    final data = doc.data() as Map<String, dynamic>;
    print('🔍 Product data keys: ${data.keys.toList()}');

    final model3d = (data['model_3d'] ?? {}) as Map<String, dynamic>;
    print('🔍 Model3D data: $model3d');

    final modelUrls = (model3d['model_urls'] ?? {}) as Map<String, dynamic>;
    print('🔍 Model URLs: $modelUrls');

    // Prefer explicit GLB url, fallback to primary_url
    final glb = (modelUrls['glb'] ?? model3d['primary_url']) as String?;
    print('🔍 Final GLB URL: $glb');

    if (glb == null || glb.isEmpty) {
      print('❌ No GLB URL found');
      throw Exception('GLB url not available for this product');
    }

    print('✅ GLB URL loaded successfully');
    return glb;
  }

  /// Prepare a model-viewer `src` - download and use local GLB file
  Future<String> _prepareSrc() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      print('🔄 Starting GLB preparation...');
      final url = await _loadGlbUrl();
      print(
          '📍 GLB URL loaded: ${url.substring(0, url.length > 100 ? 100 : url.length)}...');

      // Check if it's a Meshy AI URL
      if (url.contains('assets.meshy.ai')) {
        print('🔄 Meshy AI URL detected, downloading and caching locally...');

        // Try to get as data URI first
        final dataUri = await GlbFileService.getGlbAsDataUri(url);

        if (dataUri != null) {
          print('✅ GLB downloaded and converted to data URI');
          print('🔍 Data URI preview: ${dataUri.substring(0, 100)}...');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return dataUri; // Return data URI for ModelViewer
        } else {
          print('⚠️ Failed to convert to data URI, trying direct URL...');
          // Fallback to direct URL if data URI fails
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return url; // Return original URL as fallback
        }
      } else {
        // For non-Meshy AI URLs, use directly
        print('🔧 Using direct URL');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return url;
      }
    } catch (e) {
      print('❌ Error in _prepareSrc: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load 3D model: $e';
        });
      }

      // Return a fallback URL
      return 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        actions: [
          // Cache info button
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () {
              _showCacheInfo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.touch_app,
                                color: Colors.blue.shade700,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'How to Interact',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInstructionRow(
                          Icons.pinch,
                          'Pinch to zoom in/out',
                        ),
                        const SizedBox(height: 16),
                        _buildInstructionRow(
                          Icons.threed_rotation,
                          'Drag to rotate',
                        ),
                        const SizedBox(height: 16),
                        _buildInstructionRow(
                          Icons.touch_app,
                          'Double tap to reset view',
                        ),
                        const SizedBox(height: 16),
                        _buildInstructionRow(
                          Icons.view_in_ar,
                          'Tap AR button to view in your space',
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Got it!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _glbFuture,
        builder: (context, snapshot) {
          if (_isLoading ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading 3D model...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This may take a moment on first load',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        // Force refresh
                        _glbFuture = _prepareSrc();
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError || _errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ??
                          'Failed to load model: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_errorMessage?.contains('expired') == true) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'The 3D model link has expired. Please regenerate the model from the product page.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.orange),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _glbFuture = _prepareSrc();
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final glbUrl = snapshot.data!;
          final isCached = glbUrl.startsWith('data:');

          return Stack(
            children: [
              // Add error handling for ModelViewer
              Builder(
                builder: (context) {
                  try {
                    return ModelViewer(
                      backgroundColor: const Color(0xFFEEEEEE),
                      src: glbUrl,
                      alt: '3D product model',
                      arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                      ar: true,
                      autoPlay: true,
                      disableZoom: false,
                      cameraControls: true,
                    );
                  } catch (e) {
                    print('❌ ModelViewer error: $e');
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to display 3D model',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: $e',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              // Cache indicator
              if (isCached)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.offline_pin,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Cached',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showCacheInfo() {
    // Use FutureBuilder for async cache stats

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: GlbFileService.getCacheStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading cache information...'),
                  ],
                );
              }

              final stats = snapshot.data ?? {};
              final files = (stats['files'] as List?) ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.storage,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'GLB Cache Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow('Cached Files', '${stats['total_files'] ?? 0}'),
                  _buildInfoRow(
                      'Total Size', '${stats['total_size_mb'] ?? '0.00'} MB'),
                  const SizedBox(height: 24),
                  if (files.isNotEmpty) ...[
                    const Text(
                      'Cached GLB Files:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      child: ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• $file',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearCache();
                          },
                          icon: const Icon(Icons.delete_sweep),
                          label: const Text('Clear Cache'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear GLB Cache'),
        content: const Text(
            'Are you sure you want to clear all cached GLB files? This will require re-downloading them on next view.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await GlbFileService.clearCache();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('GLB cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
