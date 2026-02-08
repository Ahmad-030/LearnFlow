import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Model/SubjectModel.dart';
import '../../../Services/CssSubjectService.dart';
import '../../../Services/SubjectProgressService.dart';
import '../../AuthScreens/AuthController.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<SubjectModel> enrolledSubjects = <SubjectModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxMap<String, SubjectProgress> subjectProgressMap =
      <String, SubjectProgress>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadEnrolledSubjects(); // CHANGED: removed underscore
  }

  Future<void> loadEnrolledSubjects() async { // CHANGED: removed underscore to make it public
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      // Get enrolled courses from Firestore
      final enrollmentDoc =
      await _firestore.collection('enrollments').doc(user.uid).get();

      if (enrollmentDoc.exists) {
        final List<String> courses =
        List<String>.from(enrollmentDoc.data()?['courses'] ?? []);

        // Get subjects from CSS service based on enrolled courses
        enrolledSubjects.value =
            CSSSubjectsService.getSubjectsByEnrolledCourses(courses);

        // Load progress for each subject
        for (var subject in enrolledSubjects) {
          final progress =
          await SubjectProgressService.getSubjectProgress(user.uid, subject.id);
          if (progress != null) {
            subjectProgressMap[subject.id] = progress;
          }
        }
      }
    } catch (e) {
      print('Error loading enrolled subjects: $e');
    } finally {
      isLoading.value = false;
    }
  }

  SubjectProgress? getSubjectProgress(String subjectId) {
    return subjectProgressMap[subjectId];
  }

  void refreshData() {
    loadEnrolledSubjects(); // CHANGED: removed underscore
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'My Subjects',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,

      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.enrolledSubjects.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshData();
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Overall Progress Card
              _buildOverallProgressCard(controller),
              const SizedBox(height: 24),

              // Subjects Title
              Text(
                'Your Enrolled Subjects',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),

              // Subjects List
              ...controller.enrolledSubjects.map((subject) {
                final progress = controller.getSubjectProgress(subject.id);
                return _buildSubjectCard(context, subject, progress);
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 64,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Subjects Enrolled',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t enrolled in any subjects yet. Go to enrollment to select your courses.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.toNamed('/enrollment'),
              child: Text(
                'Enroll Now',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final user = FirebaseAuth.instance.currentUser;
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting! 👋',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.displayName ?? 'Student',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ready to continue your learning journey?',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(HomeController controller) {
    int totalQuizzes = 0;
    int totalMaterials = 0;
    int completedMaterials = 0;

    for (var subject in controller.enrolledSubjects) {
      final progress = controller.getSubjectProgress(subject.id);
      totalQuizzes += progress?.totalQuizzesTaken ?? 0;
      totalMaterials += subject.materials.length;
      completedMaterials += CSSSubjectsService.getCompletedMaterialsCount(subject);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Progress',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Subjects',
                  '${controller.enrolledSubjects.length}',
                  Icons.subject_rounded,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Quizzes',
                  '$totalQuizzes',
                  Icons.quiz_outlined,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Materials',
                  '$completedMaterials/$totalMaterials',
                  Icons.book_outlined,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectCard(
      BuildContext context,
      SubjectModel subject,
      SubjectProgress? progress,
      ) {
    final accuracyPercentage = progress?.accuracyPercentage ?? 0.0;
    final materialsCompleted =
    CSSSubjectsService.getCompletedMaterialsCount(subject);
    final totalMaterials = subject.materials.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to subject detail screen
            Get.toNamed('/subject-details', arguments: subject);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getColorFromHex(subject.color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subject.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subject.description,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildProgressChip(
                      'Quizzes: ${progress?.totalQuizzesTaken ?? 0}',
                      Icons.quiz_outlined,
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 8),
                    _buildProgressChip(
                      'Accuracy: ${accuracyPercentage.toStringAsFixed(1)}%',
                      Icons.check_circle_outline,
                      const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Materials',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                '$materialsCompleted/$totalMaterials',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: totalMaterials > 0
                                  ? materialsCompleted / totalMaterials
                                  : 0.0,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: AlwaysStoppedAnimation(
                                _getColorFromHex(subject.color),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}