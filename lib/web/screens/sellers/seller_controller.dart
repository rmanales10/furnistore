import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

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
      await _firebase
          .collection('sellersApplication')
          .doc(id)
          .update({'status': status, 'reason': reason});
      if (status == 'approved') {
        await _firebase.collection('users').doc(id).update({'role': 'seller'});
      }
      fetchSellersStatus(id);
    } catch (e) {
      log(e.toString());
    }
  }
}
