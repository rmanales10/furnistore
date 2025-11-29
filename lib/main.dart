import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/web/auth_screen/login.dart';
import 'package:furnistore/web/screens/sidebar.dart';
import 'services/firebase_options.dart';
import 'services/glb_storage_service.dart';
import 'services/email_service.dart';
import 'package:furnistore/app/categories/categories.dart';
import 'package:furnistore/app/bottom_nav_bar.dart';
import 'package:furnistore/app/auth/forgot/forgot_pass.dart';
import 'package:furnistore/app/auth/login/login.dart';
import 'package:furnistore/app/auth/forgot/new_pass.dart';
import 'package:furnistore/app/auth/splash/page1.dart';
import 'package:furnistore/app/auth/splash/page2.dart';
import 'package:furnistore/app/auth/register/register.dart';
import 'package:furnistore/app/auth/identity_verification/identity_verification_form.dart';
import 'package:furnistore/app/auth/identity_verification/document_scan_screen.dart';
import 'package:furnistore/app/auth/identity_verification/face_detection_instructions.dart';
import 'package:furnistore/app/auth/identity_verification/face_scanning_screen.dart';
import 'package:furnistore/app/auth/identity_verification/verification_success_screen.dart';
import 'package:furnistore/app/payment_track_order/payment_successful.dart';
import 'package:furnistore/app/payment_track_order/track_order.dart';
import 'package:furnistore/app/profile/about.dart';
import 'package:furnistore/app/profile/delivery/delivery_address.dart';
import 'package:furnistore/app/profile/edit_profile/edit_profile.dart';
import 'package:furnistore/app/profile/profile_settings.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize GetX Storage for GLB caching
  await GlbStorageService.init();
  // Initialize EmailJS for email notifications
  await EmailService.initialize();
  runApp(kIsWeb ? MyAdmin() : MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'FurniStore',
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboard1(),
        '/2': (context) => const Onboard2(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/identity-verification/form': (context) =>
            const IdentityVerificationFormScreen(),
        '/identity-verification/document-scan': (context) =>
            const DocumentScanScreen(),
        '/identity-verification/face-detection-instructions': (context) =>
            const FaceDetectionInstructionsScreen(),
        '/identity-verification/face-scanning': (context) =>
            const FaceScanningScreen(),
        '/identity-verification/success': (context) =>
            const VerificationSuccessScreen(),
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
        // '/review': (context) => const ReviewsScreen(),
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
    return GetMaterialApp(
      title: 'FurniStore',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, elevation: 0),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyLogin()),
        GetPage(name: '/admin-dashboard', page: () => Sidebar(role: 'admin')),
        GetPage(
            name: '/seller-dashboard',
            page: () => Sidebar(role: 'seller', initialIndex: 1)),
      ],
    );
  }
}
