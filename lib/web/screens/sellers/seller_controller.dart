import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:furnistore/services/email_service.dart';

class SellerController extends GetxController {
  final _firebase = FirebaseFirestore.instance;
  RxList sellers = [].obs;
  RxMap sellersStatus = {}.obs;

  Future<void> fetchSellers() async {
    try {
      final snapshot = await _firebase.collection('sellersApplication').get();
      sellers.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> fetchSellersStatus(String id) async {
    if (id.isEmpty) {
      return;
    }
    try {
      final snapshot =
          await _firebase.collection('sellersApplication').doc(id).get();
      sellersStatus.value = snapshot.data() ?? {};
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateSellerStatus(
      String id, String status, String reason) async {
    try {
      // Get seller data before updating
      final sellerDoc =
          await _firebase.collection('sellersApplication').doc(id).get();

      if (!sellerDoc.exists) {
        log('❌ Seller document not found: $id');
        return;
      }

      final sellerData = sellerDoc.data()!;

      // Try different possible email field names
      String sellerEmail = sellerData['ownersEmail'] ??
          sellerData['email'] ??
          sellerData['ownerEmail'] ??
          sellerData['contactEmail'] ??
          sellerData['userEmail'] ??
          '';

      // If email is still empty, try to get it from the user's auth data
      if (sellerEmail.isEmpty) {
        try {
          final userDoc = await _firebase.collection('users').doc(id).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            sellerEmail = userData['email'] ?? userData['userEmail'] ?? '';
            log('📧 Found email in user data: "$sellerEmail"');
          }
        } catch (e) {
          log('❌ Error fetching user email: $e');
        }
      }

      final sellerName = sellerData['ownerName'] ?? sellerData['name'] ?? '';
      final storeName = sellerData['storeName'] ?? '';

      // Debug logging to see what data we have
      log('🔍 Seller data keys: ${sellerData.keys.toList()}');
      log('📧 Seller email: "$sellerEmail" (length: ${sellerEmail.length})');
      log('👤 Seller name: "$sellerName"');
      log('🏪 Store name: "$storeName"');

      // Check all possible email-related fields
      for (String key in sellerData.keys) {
        if (key.toLowerCase().contains('email') ||
            key.toLowerCase().contains('contact')) {
          log('📧 Field "$key": "${sellerData[key]}"');
        }
      }

      // Update seller status
      await _firebase
          .collection('sellersApplication')
          .doc(id)
          .update({'status': status, 'reason': reason});

      if (status.toLowerCase() == 'approved') {
        await _firebase.collection('users').doc(id).update({'role': 'seller'});

        // Send approval email notification
        if (sellerEmail.isNotEmpty) {
          log('📧 Sending approval email to: $sellerEmail');
          final emailResult = await EmailService.sendSellerApprovalEmail(
            sellerEmail: sellerEmail,
            sellerName: sellerName,
            storeName: storeName,
          );

          if (emailResult['success']) {
            log('✅ Approval email sent successfully');
          } else {
            log('❌ Failed to send approval email: ${emailResult['error']}');
          }
        } else {
          log('⚠️ No email address found for seller: $id');
          log('⚠️ Available fields: ${sellerData.keys.join(', ')}');
          log('⚠️ Please check if the seller provided an email address during registration');
        }
      } else if (status.toLowerCase() == 'rejected') {
        // Send rejection email notification
        if (sellerEmail.isNotEmpty) {
          log('📧 Sending rejection email to: $sellerEmail');
          final emailResult = await EmailService.sendSellerRejectionEmail(
            sellerEmail: sellerEmail,
            sellerName: sellerName,
            storeName: storeName,
            reason: reason.isNotEmpty
                ? reason
                : 'Application did not meet our requirements',
          );

          if (emailResult['success']) {
            log('✅ Rejection email sent successfully');
          } else {
            log('❌ Failed to send rejection email: ${emailResult['error']}');
          }
        } else {
          log('⚠️ No email address found for seller: $id');
          log('⚠️ Available fields: ${sellerData.keys.join(', ')}');
          log('⚠️ Please check if the seller provided an email address during registration');
        }
      }

      fetchSellersStatus(id);
    } catch (e) {
      log('❌ Error updating seller status: $e');
    }
  }
}
