import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../AuthScreens/AuthController.dart';
import '../../../Services/SubjectProgressService.dart';
import '../../../Services/QuizService.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> userStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> recentQuizzes = <Map<String, dynamic>>[].obs;
  final RxList<String> enrolledSubjects = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        Get.offAllNamed('/login');
        return;
      }

      // Load enrolled subjects
      await _loadEnrolledSubjects(currentUser.uid);

      // Load overall statistics
      await _loadUserStatistics(currentUser.uid);

      // Load recent quiz attempts
      await _loadRecentQuizzes(currentUser.uid);

    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadEnrolledSubjects(String userId) async {
    try {
      final enrollmentDoc = await _firestore
          .collection('enrollments')
          .doc(userId)
          .get();

      if (enrollmentDoc.exists) {
        enrolledSubjects.value = List<String>.from(
          enrollmentDoc.data()?['courses'] ?? [],
        );
      }
    } catch (e) {
      print('Error loading enrolled subjects: $e');
    }
  }

  Future<void> _loadUserStatistics(String userId) async {
    try {
      final stats = await SubjectProgressService.getOverallStatistics(userId);

      // Calculate additional metrics
      final allQuizzes = await QuizService.getAllUserQuizAttempts(userId);

      userStats.value = {
        'totalSubjects': enrolledSubjects.length,
        'totalQuizzes': stats['totalQuizzes'] ?? 0,
        'totalQuestions': stats['totalQuestions'] ?? 0,
        'averageAccuracy': stats['averageAccuracy'] ?? 0.0,
        'totalStudyTime': stats['totalStudyTime'] ?? 0,
        'currentStreak': stats['currentStreak'] ?? 0,
        'longestStreak': stats['longestStreak'] ?? 0,
        'totalAttempts': allQuizzes.length,
        'passedQuizzes': allQuizzes.where((q) => q.passed).length,
        'failedQuizzes': allQuizzes.where((q) => !q.passed).length,
        'bestScore': allQuizzes.isEmpty ? 0 : allQuizzes.map((q) => q.score).reduce((a, b) => a > b ? a : b),
        'averageScore': allQuizzes.isEmpty ? 0.0 : allQuizzes.map((q) => q.score).reduce((a, b) => a + b) / allQuizzes.length,
      };
    } catch (e) {
      print('Error loading user statistics: $e');
    }
  }

  Future<void> _loadRecentQuizzes(String userId) async {
    try {
      final attempts = await QuizService.getAllUserQuizAttempts(userId);

      recentQuizzes.value = attempts.take(10).map((attempt) {
        return {
          'quizId': attempt.quizId,
          'subjectId': attempt.subjectId,
          'score': attempt.score,
          'passed': attempt.passed,
          'correctAnswers': attempt.correctAnswers,
          'totalQuestions': attempt.totalQuestions,
          'timeTaken': attempt.timeTaken,
          'completedAt': attempt.completedAt,
        };
      }).toList();
    } catch (e) {
      print('Error loading recent quizzes: $e');
    }
  }

  void refreshData() {
    loadUserData();
  }

  void editProfile() {
    Get.snackbar(
      'Coming Soon',
      'Profile editing feature is under development',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      icon: const Icon(Icons.info_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void showLogoutDialog() {
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          final authController = Get.find<AuthController>();
                          authController.signOut();
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
                          'Logout',
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

}