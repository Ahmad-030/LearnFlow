import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Screens/AuthScreens/AuthController.dart';
import 'Screens/AuthScreens/ForgetPassScreen.dart';
import 'Screens/AuthScreens/LoginScreen.dart';
import 'Screens/AuthScreens/SignupScreen.dart';
import 'Screens/OnboardingScreen/Onboarding_Screen.dart';
import 'Screens/SplashScreen/Splash_Screen.dart';
import 'Screens/UI/Enrollment_Screen.dart';
import 'Screens/UI/HomeScreen.dart';
import 'Theme/App_Theme.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const LearnFlowApp());
}

// Create an InitialBinding class to manage permanent controllers
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put AuthController as permanent so it persists throughout the app
    Get.put(AuthController(), permanent: true);
  }
}

class LearnFlowApp extends StatelessWidget {
  const LearnFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LearnFlow - CSS Preparation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialBinding: InitialBinding(), // Add this line
      home: const SplashScreen(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // GetX Routes
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/login',
          page: () => const ModernLoginScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/signup',
          page: () => const ModernSignUpScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/forgot-password',
          page: () => const ModernForgotPasswordScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/enrollment',
          page: () => const EnrollmentScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/subject-details',
          page: () => const SubjectDetailsScreen(), // Create this screen
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}