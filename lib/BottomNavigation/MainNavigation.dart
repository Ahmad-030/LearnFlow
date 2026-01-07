import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screens/UI/Dashboard/DashboardScreen.dart';
import '../Screens/UI/Home/HomeScreen.dart';
import '../Screens/UI/Profile/ProfileScreens.dart';
import '../Screens/UI/Tools/ToolsScreen.dart';
import '../Widgets/Custom_BottomNavingation.dart';

// Import your screens (you'll need to create these)
// import 'Screens/UI/HomeScreen.dart';
// import 'Screens/UI/DashboardScreen.dart';
// import 'Screens/UI/ToolsScreen.dart';
// import 'Screens/UI/ProfileScreen.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController());

    // Your screens list
    final List<Widget> screens = [
      const HomeScreen(), // Your existing HomeScreen
      const DashboardScreen(), // Create this
      const ToolsScreen(), // Create this
      const ProfileScreen(), // Create this
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Obx(() => CustomBottomNavigation(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
      )),
    );
  }
}

// Placeholder screens (replace with your actual screens)
