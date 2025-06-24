import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:furnistore/src/web/auth_screen/login.dart';
import 'package:furnistore/src/web/screens/activity_log/activitylog.dart';
import 'package:furnistore/src/web/screens/sidebar.dart';
import 'firebase_options.dart';
import 'package:furnistore/src/app/categories/categories.dart';
import 'package:furnistore/src/app/home_screen.dart';
import 'package:furnistore/src/app/auth/forgot/forgot_pass.dart';
import 'package:furnistore/src/app/auth/login/login.dart';
import 'package:furnistore/src/app/auth/forgot/new_pass.dart';
import 'package:furnistore/src/app/auth/splash/page1.dart';
import 'package:furnistore/src/app/auth/splash/page2.dart';
import 'package:furnistore/src/app/auth/register/register.dart';
import 'package:furnistore/src/app/payment_track_order/payment_successful.dart';
import 'package:furnistore/src/app/payment_track_order/track_order.dart';
import 'package:furnistore/src/app/profile/about.dart';
import 'package:furnistore/src/app/profile/delivery/delivery_address.dart';
import 'package:furnistore/src/app/profile/edit_profile/edit_profile.dart';
import 'package:furnistore/src/app/profile/profile_settings.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(kIsWeb ? MyAdmin() : MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      title: 'FurniStore',
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
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, elevation: 0),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MyLogin()),
        GetPage(name: '/activitylog', page: () => ActivityLogScreen()),
        GetPage(name: '/admin-dashboard', page: () => Sidebar(role: 'admin')),
        GetPage(name: '/seller-dashboard', page: () => Sidebar(role: 'seller', initialIndex: 8)),
      ],
    );
  }
}
