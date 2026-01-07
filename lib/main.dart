import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'Screens/AuthScreens/ForgetPassScreen.dart';
import 'Screens/AuthScreens/LoginScreen.dart';
import 'Screens/AuthScreens/SignupScreen.dart';
import 'Screens/OnboardingScreen/Onboarding_Screen.dart';
import 'Screens/SplashScreen/Splash_Screen.dart';
import 'Theme/App_Theme.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

class LearnFlowApp extends StatelessWidget {
  const LearnFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LearnFlow - CSS Preparation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // GetX Routes (Add more routes as you build)
      getPages: [
        GetPage(
          name: '/',
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
        // Add more routes here
        // GetPage(
        //   name: '/home',
        //   page: () => const HomeScreen(),
        //   transition: Transition.rightToLeft,
        // ),
      ],
    );
  }
}