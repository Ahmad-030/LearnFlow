import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnrollmentController extends GetxController with GetTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<String> selectedCourses = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showContent = false.obs;

  late AnimationController fadeController;
  late AnimationController slideController;
  late AnimationController pulseController;

  final List<Map<String, dynamic>> courses = [
    {
      'title': 'English Essay',
      'icon': Icons.edit_note_rounded,
      'color': const Color(0xFF6366F1),
      'description': 'Master essay writing skills',
    },
    {
      'title': 'English (Precis & Composition)',
      'icon': Icons.library_books_rounded,
      'color': const Color(0xFFEC4899),
      'description': 'Enhance comprehension & writing',
    },
    {
      'title': 'General Science & Ability',
      'icon': Icons.science_rounded,
      'color': const Color(0xFF10B981),
      'description': 'Build scientific knowledge',
    },
    {
      'title': 'Current Affairs',
      'icon': Icons.public_rounded,
      'color': const Color(0xFFF59E0B),
      'description': 'Stay updated with world events',
    },
    {
      'title': 'Pakistan Affairs',
      'icon': Icons.flag_rounded,
      'color': const Color(0xFF8B5CF6),
      'description': 'Understand national dynamics',
    },
    {
      'title': 'Islamic Studies / Comparative Religion',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF06B6D4),
      'description': 'Explore religious knowledge',
    },
  ];

  @override
  void onInit() {
    super.onInit();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    fadeController.forward();
    slideController.forward();

    // Delay content appearance for smooth animation
    Future.delayed(const Duration(milliseconds: 300), () {
      showContent.value = true;
    });
  }

  void toggleCourse(String courseTitle) {
    if (selectedCourses.contains(courseTitle)) {
      selectedCourses.remove(courseTitle);
    } else {
      selectedCourses.add(courseTitle);
    }
  }

  void showEnrollmentDialog() {
    if (selectedCourses.isEmpty) {
      Get.snackbar(
        'No Courses Selected',
        'Please select at least one course to enroll',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Confirm Enrollment',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                'Are you sure you want to enroll in the selected courses?',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Selected courses count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${selectedCourses.length} ${selectedCourses.length == 1 ? 'Course' : 'Courses'} Selected',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1976D2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          confirmEnrollment();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> confirmEnrollment() async {
    try {
      isLoading.value = true;

      // Firebase enrollment logic
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      await _firestore.collection('enrollments').doc(user.uid).set({
        'userId': user.uid,
        'email': user.email,
        'courses': selectedCourses.toList(),
        'enrolledAt': FieldValue.serverTimestamp(),
      });

      // Success
      Get.snackbar(
        'Enrollment Successful!',
        'You have been enrolled in ${selectedCourses.length} courses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );

      // Navigate to home after delay
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed('/main');
      });
    } catch (e) {
      Get.snackbar(
        'Enrollment Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fadeController.dispose();
    slideController.dispose();
    pulseController.dispose();
    super.onClose();
  }
}

class EnrollmentScreen extends StatelessWidget {
  const EnrollmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnrollmentController());
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.height < 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFFAFAFA),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar

              // Main Content
              Expanded(
                child: Obx(() => AnimatedOpacity(
                  opacity: controller.showContent.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Animated Header
                        _buildHeader(controller, isSmallDevice),

                        const SizedBox(height: 24),

                        // Motivational Text
                        _buildMotivationalText(isSmallDevice),

                        const SizedBox(height: 32),

                        // Course List
                        _buildCourseList(controller, isSmallDevice),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: Obx(() => AnimatedScale(
        scale: controller.showContent.value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: _buildEnrollButton(controller, isSmallDevice),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(EnrollmentController controller, bool isSmallDevice) {
    return AnimatedBuilder(
      animation: controller.pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (controller.pulseController.value * 0.03),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  size: isSmallDevice ? 40 : 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Courses to Enroll',
                style: GoogleFonts.poppins(
                  fontSize: isSmallDevice ? 26 : 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMotivationalText(bool isSmallDevice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFF1976D2),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Step into your journey of success with LearnFlow! Choose courses that will sharpen your knowledge, boost your skills, and prepare you for the CSS exam. Your future starts here – unlock your potential!',
              style: GoogleFonts.inter(
                fontSize: isSmallDevice ? 13 : 14,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(EnrollmentController controller, bool isSmallDevice) {
    return Column(
      children: List.generate(
        controller.courses.length,
            (index) {
          final course = controller.courses[index];
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.easeOutCubic,
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Obx(() {
              final isSelected = controller.selectedCourses.contains(course['title']);
              return _buildCourseCard(
                controller,
                course,
                isSelected,
                isSmallDevice,
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(
      EnrollmentController controller,
      Map<String, dynamic> course,
      bool isSelected,
      bool isSmallDevice,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.toggleCourse(course['title']),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? (course['color'] as Color).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? course['color'] : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? (course['color'] as Color).withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 15 : 10,
                  offset: Offset(0, isSelected ? 6 : 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? course['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? course['color'] : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),

                const SizedBox(width: 16),

                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (course['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    course['icon'],
                    color: course['color'],
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: GoogleFonts.poppins(
                          fontSize: isSmallDevice ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['description'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollButton(EnrollmentController controller, bool isSmallDevice) {
    return Obx(() => Container(
      width: MediaQuery.of(Get.context!).size.width - 40,
      height: isSmallDevice ? 56 : 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.selectedCourses.isEmpty
              ? [const Color(0xFF9CA3AF), const Color(0xFF6B7280)]
              : [const Color(0xFF2196F3), const Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: controller.selectedCourses.isEmpty
                ? Colors.black.withOpacity(0.1)
                : const Color(0xFF2196F3).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isLoading.value ? null : controller.showEnrollmentDialog,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: controller.isLoading.value
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Done Enrollment',
                  style: GoogleFonts.inter(
                    fontSize: isSmallDevice ? 16 : 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (controller.selectedCourses.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.selectedCourses.length}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}