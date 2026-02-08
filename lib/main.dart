import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learn_flow/BottomNavigation/MainNavigation.dart';
import 'Screens/AuthScreens/AuthController.dart';
import 'Screens/AuthScreens/ForgetPassScreen.dart';
import 'Screens/AuthScreens/LoginScreen.dart';
import 'Screens/AuthScreens/SignupScreen.dart';
import 'Screens/OnboardingScreen/Onboarding_Screen.dart';
import 'Screens/SplashScreen/Splash_Screen.dart';
import 'Screens/UI/Enrollment_Screen.dart';
import 'Screens/UI/Home/SubjectDetailScreen.dart';
import 'Screens/UI/Tools/ToolScreens/ChatScreen.dart';
import 'Screens/UI/Tools/ToolScreens/QuizGeneratorScreen.dart';
import 'Screens/UI/Tools/ToolScreens/StudyPlanScreen.dart';
import 'Screens/UI/Tools/ToolScreens/SummarizerScreen.dart';
import 'Screens/UI/Tools/ToolScreens/ToolsScreen.dart';
import 'newscreens/DatabaseSeedService.dart';
import 'Theme/App_Theme.dart';
import 'firebase_options.dart';
import 'newscreens/QuizListController.dart';
import 'newscreens/QuizReviewController.dart';
import 'newscreens/QuizTakeController.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize database with quizzes (only runs once)
  try {
    await DatabaseSeedService.initializeDatabase();
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
  }

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
      initialBinding: InitialBinding(),
      home: const SplashScreen(

      ),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      getPages: [
        GetPage(name: '/study-plan', page: () => const StudyPlanScreen()),
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
          name: '/main',
          page: () => const MainNavigationScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/subject-details',
          page: () => const SubjectDetailsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/quiz-list',
          page: () => const QuizListScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/quiz-take',
          page: () => const QuizTakeScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/quiz-review',
          page: () => const QuizReviewScreen(),
          transition: Transition.rightToLeft,
        ),

        GetPage(name: '/tools', page: () => const ToolsScreen()),
        GetPage(name: '/summarizer', page: () => const SummarizerScreen()),
        GetPage(name: '/quiz-generator', page: () => const QuizGeneratorScreen()),
        GetPage(name: '/chat', page: () => const ChatScreen()),
      ],
    );
  }
}