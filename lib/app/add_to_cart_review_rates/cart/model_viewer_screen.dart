import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furnistore/services/glb_file_service.dart';
import 'dart:io';

class ModelViewerScreen extends StatefulWidget {
  const ModelViewerScreen({super.key, this.productId, this.glbUrl});

  final String? productId;
  final String? glbUrl;

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _modelUrl;
  bool _arSupported = false;
  bool _isCached = false;

  @override
  void initState() {
    super.initState();
    _checkARSupport();
    _loadModel();
  }

  Future<void> _checkARSupport() async {
    setState(() {
      _arSupported = Platform.isAndroid || Platform.isIOS;
    });
  }

  Future<void> _loadModel() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      String? glbUrl;

      // 1. Use direct GLB URL if provided
      if (widget.glbUrl != null && widget.glbUrl!.isNotEmpty) {
        glbUrl = widget.glbUrl!;
      }
      // 2. Use productId to fetch from Firestore
      else if (widget.productId != null && widget.productId!.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId!)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final model3d = (data['model_3d'] ?? {}) as Map<String, dynamic>;
          final modelUrls =
              (model3d['model_urls'] ?? {}) as Map<String, dynamic>;
          glbUrl = (modelUrls['glb'] ?? model3d['primary_url']) as String?;
        }
      }
      // 3. Use route arguments
      else {
        final routeArgs = ModalRoute.of(context)?.settings.arguments;
        if (routeArgs is String) {
          glbUrl = routeArgs;
        } else if (routeArgs is Map) {
          final map = Map<String, dynamic>.from(routeArgs);
          glbUrl = (map['glbUrl'] ?? map['glb']) as String?;
        }
      }

      if (glbUrl == null || glbUrl.isEmpty) {
        throw Exception('No 3D model URL found');
      }

      // Handle Meshy AI URLs - cache locally and get file path for AR
      if (glbUrl.contains('meshy.ai') || glbUrl.contains('assets.meshy.ai')) {
        print('🔄 Meshy AI URL detected, downloading and caching...');
        // First download and cache the file
        final localPath = await GlbFileService.downloadAndCacheGlb(glbUrl);
        if (localPath != null) {
          // Use file:// URL for AR compatibility with Scene Viewer
          final fileUrl = 'file://$localPath';
          print('✅ GLB cached locally: $localPath');
          print('✅ Using file URL for AR: $fileUrl');
          setState(() {
            _modelUrl = fileUrl;
            _isCached = true;
            _isLoading = false;
          });
          return;
        } else {
          print('❌ Failed to cache GLB file');
        }
      }

      // Use direct URL for non-Meshy URLs
      setState(() {
        _modelUrl = glbUrl;
        _isCached = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load 3D model: $e';
        _isLoading = false;
      });
    }
  }

  void _showARInstructions() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E6BE0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.view_in_ar,
                      color: Color(0xFF3E6BE0),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AR Instructions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_arSupported) ...[
                // Status Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AR is ready! Your model is cached locally.',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'To launch AR camera:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                // Instructions List
                ...List.generate(7, (index) {
                  final steps = [
                    'Look for the AR cube button in the 3D viewer',
                    'It may be a small cube icon with arrows',
                    'Tap the AR button to launch camera',
                    'Allow camera permission if prompted',
                    'Point camera at a flat surface (table/floor)',
                    'Tap to place the 3D model',
                    'Move around to view from different angles',
                  ];
                  final icons = [
                    Icons.search,
                    Icons.view_in_ar,
                    Icons.touch_app,
                    Icons.security,
                    Icons.camera_alt,
                    Icons.touch_app_outlined,
                    Icons.rotate_right,
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E6BE0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Color(0xFF3E6BE0),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          icons[index],
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            steps[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                // Tip Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: The AR button is part of the 3D viewer itself, not a separate button.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade900,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AR not supported',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AR requires a mobile device with camera support.',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E6BE0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showARInstructions,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading 3D model...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadModel,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_modelUrl == null) {
      return const Center(
        child: Text('No 3D model available'),
      );
    }

    return Stack(
      children: [
        // 3D Model Viewer
        ModelViewer(
          backgroundColor: Colors.white,
          src: _modelUrl!,
          alt: '3D product model',
          arModes: _arSupported
              ? const ['scene-viewer', 'webxr', 'quick-look']
              : const [],
          ar: _arSupported,
          autoPlay: true,
          disableZoom: false,
          cameraControls: true,
          interactionPrompt: InteractionPrompt.none,
          arScale: ArScale.auto,
          arPlacement: ArPlacement.floor,
          onWebViewCreated: (controller) {
            print('🌐 WebView created for 3D model');
            print(
                '🔍 Model URL: ${_modelUrl?.substring(0, _modelUrl!.length > 100 ? 100 : _modelUrl!.length)}...');
            print('🔍 AR enabled: $_arSupported');
            print('🔍 AR modes: scene-viewer, webxr, quick-look');
          },
        ),

        // Status indicators
        if (_isCached)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF3E6BE0).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.offline_pin,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
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

        if (_arSupported)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF3E6BE0).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_in_ar,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'AR Ready',
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
  }
}
