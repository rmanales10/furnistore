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
      final sellerEmail = sellerData['ownersEmail'] ?? '';
      final sellerName = sellerData['ownerName'] ?? '';
      final storeName = sellerData['storeName'] ?? '';

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
        }
      }

      fetchSellersStatus(id);
    } catch (e) {
      log('❌ Error updating seller status: $e');
    }
  }
}
