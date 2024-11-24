import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/src/admin/screens/homepage.dart';
import 'package:furnistore/src/user/add_to_cart_review_rates/reviews&rating.dart';
import 'package:furnistore/src/user/categories/categories.dart';
import 'package:furnistore/src/user/home_screen.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/forgot_pass.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/login.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/new_pass.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/page1.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/page2.dart';
import 'package:furnistore/src/user/onboarding_and_registration/screens/register.dart';
import 'package:furnistore/src/user/payment_track_order/payment_successful.dart';
import 'package:furnistore/src/user/payment_track_order/track_order.dart';
import 'package:furnistore/src/user/profile/about.dart';
import 'package:furnistore/src/user/profile/delivery_address.dart';
import 'package:furnistore/src/user/profile/edit_profile.dart';
import 'package:furnistore/src/user/profile/settings.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDT_qGJTcu8trU488EPJE4hWs2ytc5x7-I",
            authDomain: "furnistore-359e1.firebaseapp.com",
            projectId: "furnistore-359e1",
            storageBucket: "furnistore-359e1.firebasestorage.app",
            messagingSenderId: "1083898171282",
            appId: "1:1083898171282:web:a920e13b56064044a1bb4b",
            measurementId: "G-SSCBMY1ZVG"));
    runApp(MyAdmin());
  } else {
    await Firebase.initializeApp();
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furnistore',
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboard1(),
        '/2': (context) => const Onboard2(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // '/verify': (context) => EmailVerificationScreen(),
        '/forgot': (context) => ForgetPasswordScreen(),
        '/newpass': (context) => const NewPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/chair': (context) => const ChairsScreen(),
        '/table': (context) => TablesScreen(),
        '/bed': (context) => BedsScreen(),
        '/lamp': (context) => LampsScreen(),
        '/sofa': (context) => SofasScreen(),
        // '/product': (context) => ProductDetailsScreen(),
        '/review': (context) => const ReviewsScreen(),
        // '/cart': (context) => const CartScreen(),
        // '/order': (context) => const OrderReviewScreen(),
        '/pay': (context) => const PaymentSuccessScreen(),
        '/track': (context) => const MyOrdersScreen(),
        '/setting': (context) => const ProfileSettingsScreen(),
        '/editprof': (context) => const EditProfileScreen(),
        '/adrress': (context) => const DeliveryAddressScreen(),
        '/about': (context) => const AboutFurniStoreScreen(),
      },
    );
  }
}

class MyAdmin extends StatelessWidget {
  const MyAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(),
    );
  }
}
