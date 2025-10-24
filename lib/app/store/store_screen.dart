import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furnistore/app/store/brand_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<Map<String, dynamic>> sellers = [];
  List<Map<String, dynamic>> filteredSellers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSellers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterSellers();
  }

  void _filterSellers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredSellers = List.from(sellers);
      } else {
        filteredSellers = sellers.where((seller) {
          final storeName = (seller['storeName'] ?? '').toLowerCase();
          final ownerName = (seller['ownerName'] ?? '').toLowerCase();
          return storeName.contains(query) || ownerName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchSellers() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('sellersApplication')
          .where('status', isEqualTo: 'Approved')
          .limit(8) // Limit to 8 sellers for the grid
          .get();

      final List<Map<String, dynamic>> sellersList = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('🏪 Found seller: ${data['storeName']} | ID: ${doc.id}');
        sellersList.add({
          'id': doc.id,
          'storeName': data['storeName'] ?? 'Unknown Store',
          'ownerName': data['ownerName'] ?? 'Unknown Owner',
          'storeLogoBase64': data['storeLogoBase64'] ?? '',
        });
      }

      if (mounted) {
        setState(() {
          sellers = sellersList;
          filteredSellers = List.from(sellersList);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching sellers: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Store',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in store',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Featured Brands Section
                const Text(
                  'Featured Brands',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (sellers.isEmpty)
                  const Center(
                    child: Text(
                      'No approved sellers available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else if (filteredSellers.isEmpty)
                  const Center(
                    child: Text(
                      'No sellers found matching your search',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    children: filteredSellers.map((seller) {
                      final storeName = seller['storeName'] as String;
                      final storeLogoBase64 =
                          seller['storeLogoBase64'] as String;
                      return _buildBrandItem(
                          storeName, storeLogoBase64, seller['id']);
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String storeName) {
    if (storeName.isEmpty) return '?';

    final words = storeName.trim().split(' ');
    if (words.length == 1) {
      // Single word - take first 2 characters
      return storeName
          .substring(0, storeName.length > 2 ? 2 : storeName.length)
          .toUpperCase();
    } else {
      // Multiple words - take first character of each word (max 2)
      final initials =
          words.take(2).map((word) => word.isNotEmpty ? word[0] : '').join('');
      return initials.toUpperCase();
    }
  }

  Widget _buildBrandItem(String name, String storeLogoBase64, String sellerId) {
    return GestureDetector(
      onTap: () {
        print('🖱️ Tapped brand: $name | Seller ID: $sellerId');
        Get.to(() => BrandScreen(sellerId: sellerId, sellerName: name));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: _buildStoreLogo(storeLogoBase64, name),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoreLogo(String? storeLogoBase64, String storeName) {
    if (storeLogoBase64 == null || storeLogoBase64.isEmpty) {
      // Fallback to initials if no logo
      final initials = _getInitials(storeName);
      return Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    try {
      // Decode the Base64 string to bytes
      final bytes = base64Decode(storeLogoBase64);

      return ClipOval(
        child: Image.memory(
          bytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to initials if image fails to load
            final initials = _getInitials(storeName);
            return Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      // Fallback to initials if Base64 decoding fails
      final initials = _getInitials(storeName);
      return Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
  }
}
