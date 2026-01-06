import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class OnboardingController extends GetxController with GetTickerProviderStateMixin {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxDouble pageOffset = 0.0.obs;
  late AnimationController fadeController;

  @override
  void onInit() {
    super.onInit();
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeController.forward();

    pageController.addListener(() {
      pageOffset.value = pageController.page ?? 0.0;
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    fadeController.reset();
    fadeController.forward();
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Navigate to home or login screen
      // Get.offAllNamed('/home');
    }
  }

  void skipToEnd() {
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    fadeController.dispose();
    super.onClose();
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isSmallDevice = height < 700;
    final isTablet = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Clean Header
            _buildHeader(controller, width, height, isSmallDevice),

            // Page View - takes most space
            Expanded(
              flex: 10,
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final offset = controller.pageOffset.value - index;
                    return _buildPage(
                      context: context,
                      index: index,
                      offset: offset,
                      size: size,
                      isSmallDevice: isSmallDevice,
                      isTablet: isTablet,
                    );
                  });
                },
              ),
            ),

            // Bottom Section - Fixed height
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? width * 0.25 : width * 0.06,
                vertical: height * 0.02,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Obx(() => _buildPageIndicators(
                    controller.currentPage.value,
                    controller.pageOffset.value,
                    width,
                  )),

                  SizedBox(height: height * 0.025),

                  // Action Button
                  Obx(() => _buildActionButton(
                    context: context,
                    controller: controller,
                    size: size,
                    isSmallDevice: isSmallDevice,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(OnboardingController controller, double width, double height, bool isSmallDevice) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.05,
        height * 0.015,
        width * 0.05,
        height * 0.01,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: isSmallDevice ? 18 : 20,
                ),
              ),
              SizedBox(width: width * 0.025),
              Text(
                'LearnFlow',
                style: GoogleFonts.poppins(
                  fontSize: isSmallDevice ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          // Skip Button
          Obx(() => controller.currentPage.value < 2
              ? TextButton(
            onPressed: controller.skipToEnd,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: 8,
              ),
              backgroundColor: const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontSize: isSmallDevice ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required int index,
    required double offset,
    required Size size,
    required bool isSmallDevice,
    required bool isTablet,
  }) {
    final List<Map<String, dynamic>> pages = [
      {
        'title': 'Welcome to LearnFlow',
        'description': 'Your complete companion for CSS exam preparation. Access study materials, practice tests, and track your progress.',
        'image': 'assets/images/img.png',
        'icon': '📚',
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'Master CSS with Smart Tools',
        'description': 'Subject-wise content, daily quizzes, mock tests, and analytics to help you identify strengths and improve.',
        'image': 'assets/images/analytics.png',
        'icon': '📊',
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Your Success, Our Mission',
        'description': 'Join thousands of CSS aspirants. Practice past papers, stay updated with current affairs, and achieve your dream.',
        'image': 'assets/images/img_2.png',
        'icon': '🎯',
        'color': const Color(0xFF10B981),
      },
    ];

    final pageData = pages[index];
    final absOffset = offset.abs();
    final scale = math.max(0.88, 1 - absOffset * 0.12);
    final opacity = math.max(0.4, 1 - absOffset * 0.6);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.15 : size.width * 0.08,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Container
              Container(
                width: isTablet ? size.width * 0.5 : size.width * 0.7,
                height: isSmallDevice
                    ? size.height * 0.3
                    : isTablet
                    ? size.height * 0.38
                    : size.height * 0.35,
                decoration: BoxDecoration(
                  color: (pageData['color'] as Color).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Image.asset(
                    pageData['image']!,
                    width: size.width * 0.5,
                    height: size.height * 0.25,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        pageData['icon']!,
                        style: TextStyle(
                          fontSize: isTablet ? 100 : 80,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),

              // Title
              Text(
                pageData['title']!,
                style: GoogleFonts.poppins(
                  fontSize: isSmallDevice ? 24 : isTablet ? 34 : 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),

              SizedBox(height: size.height * 0.02),

              // Description
              Text(
                pageData['description']!,
                style: GoogleFonts.inter(
                  fontSize: isSmallDevice ? 14 : isTablet ? 17 : 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators(int currentPage, double pageOffset, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final distance = (pageOffset - index).abs();
        final isActive = currentPage == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: EdgeInsets.symmetric(horizontal: width * 0.015),
          width: isActive ? width * 0.08 : width * 0.02,
          height: width * 0.02,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF6366F1)
                : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required OnboardingController controller,
    required Size size,
    required bool isSmallDevice,
  }) {
    final isLastPage = controller.currentPage.value == 2;

    return Container(
      width: double.infinity,
      height: isSmallDevice ? 54 : 58,
      decoration: BoxDecoration(
        color: Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.nextPage,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: GoogleFonts.inter(
                    fontSize: isSmallDevice ? 16 : 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Icon(
                  isLastPage ? Icons.arrow_forward_rounded : Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: isSmallDevice ? 18 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}