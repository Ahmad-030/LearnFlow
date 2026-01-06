import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    animationController.forward();

    // Navigate to home after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      // Navigate to your onboarding screen using GetX
      // Get.offNamed('/onboarding');
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Responsive sizing
    final isSmallDevice = height < 700;
    final animationSize = width * (isSmallDevice ? 0.65 : 0.75);
    final titleFontSize = isSmallDevice ? 40.0 : 48.0;
    final subtitleFontSize = isSmallDevice ? 16.0 : 18.0;
    final badgeFontSize = isSmallDevice ? 12.0 : 14.0;
    final loadingTextFontSize = isSmallDevice ? 12.0 : 14.0;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3), // Primary Blue
              Color(0xFF1976D2), // Dark Blue
              Color(0xFF0D47A1), // Accent Blue
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.08),

                        // Lottie Animation with Scale Animation
                        AnimatedBuilder(
                          animation: controller.animationController,
                          builder: (context, child) {
                            return ScaleTransition(
                              scale: controller.scaleAnimation,
                              child: Lottie.asset(
                                'assets/animations/education.json',
                                width: animationSize,
                                height: animationSize,
                                fit: BoxFit.contain,
                                repeat: true,
                                animate: true,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: height * 0.04),

                        // App Name with Fade and Slide Animation
                        AnimatedBuilder(
                          animation: controller.animationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: controller.fadeAnimation,
                              child: SlideTransition(
                                position: controller.slideAnimation,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                                  child: Column(
                                    children: [
                                      // App Name
                                      Text(
                                        'LearnFlow',
                                        style: GoogleFonts.poppins(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                          shadows: [
                                            Shadow(
                                              offset: const Offset(0, 4),
                                              blurRadius: 12,
                                              color: Colors.black.withOpacity(0.3),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      SizedBox(height: height * 0.015),

                                      // Tagline
                                      Text(
                                        'CSS Exam Preparation',
                                        style: GoogleFonts.inter(
                                          fontSize: subtitleFontSize,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          letterSpacing: 0.8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      SizedBox(height: height * 0.02),

                                      // Subtitle Badge
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.06,
                                          vertical: height * 0.012,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(25),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.4),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.school_rounded,
                                              color: Colors.white,
                                              size: badgeFontSize + 4,
                                            ),
                                            SizedBox(width: width * 0.02),
                                            Flexible(
                                              child: Text(
                                                'Your Path to Success',
                                                style: GoogleFonts.inter(
                                                  fontSize: badgeFontSize,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        // Loading Indicator
                        AnimatedBuilder(
                          animation: controller.animationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: controller.fadeAnimation,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: isSmallDevice ? 35 : 40,
                                    height: isSmallDevice ? 35 : 40,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 3.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                                    child: Text(
                                      'Preparing Your Learning Journey...',
                                      style: GoogleFonts.inter(
                                        fontSize: loadingTextFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: height * 0.04),

                        // Version Info
                        Padding(
                          padding: EdgeInsets.only(bottom: height * 0.02),
                          child: Text(
                            'Version 1.0.0',
                            style: GoogleFonts.inter(
                              fontSize: isSmallDevice ? 11 : 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}