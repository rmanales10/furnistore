import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DeliveryAddressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<void> setDeliveryAddress(
      {required String address,
      required String townCity,
      required String postcode,
      required String phoneNumber}) async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'address': address,
        'town_city': townCity,
        'postcode': postcode,
        'phone_number': phoneNumber,
      }, SetOptions(merge: true));

      log('Set Delivery Address stored Successfully');
    } catch (e) {
      log('Error storing data $e');
    }
  }

  RxMap<String, dynamic> deliveryAddress = <String, dynamic>{}.obs;
  Future<void> getDeliveryAddress() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (documentSnapshot.exists) {
        deliveryAddress.value = documentSnapshot.data() as Map<String, dynamic>;
        log('Data fetched successfully $deliveryAddress');
      }
    } catch (e) {
      log('Error fetching data $e');
    }
  }
}
