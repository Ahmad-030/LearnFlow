import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Model/SubjectModel.dart';
import '../../../Services/CssSubjectService.dart';
import '../../../Services/SubjectProgressService.dart';

class DashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;
  final RxList<SubjectModel> enrolledSubjects = <SubjectModel>[].obs;
  final RxMap<String, SubjectProgress> subjectProgressMap = <String, SubjectProgress>{}.obs;
  final RxList<Map<String, dynamic>> weeklyProgress = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user == null) {
        Get.offAllNamed('/login');
        return;
      }

      // Load enrolled subjects
      await _loadEnrolledSubjects(user.uid);

      // Load overall statistics from SubjectProgressService
      final overallStats = await SubjectProgressService.getOverallStatistics(user.uid);

      stats.value = {
        'totalQuizzes': overallStats['totalQuizzes'] ?? 0,
        'totalQuestions': overallStats['totalQuestions'] ?? 0,
        'averageAccuracy': overallStats['averageAccuracy'] ?? 0.0,
        'totalStudyTime': overallStats['totalStudyTime'] ?? 0,
        'currentStreak': overallStats['currentStreak'] ?? 0,
        'longestStreak': overallStats['longestStreak'] ?? 0,
      };

      // Load recent activities from all subjects
      await _loadRecentActivities(user.uid);

      // Load weekly progress data
      await _loadWeeklyProgress(user.uid);

    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadEnrolledSubjects(String userId) async {
    try {
      // Get enrolled courses from Firestore
      final enrollmentDoc = await _firestore
          .collection('enrollments')
          .doc(userId)
          .get();

      if (enrollmentDoc.exists) {
        final List<String> courses = List<String>.from(
          enrollmentDoc.data()?['courses'] ?? [],
        );

        // Get subjects from CSS service
        enrolledSubjects.value = CSSSubjectsService.getSubjectsByEnrolledCourses(courses);

        // Load progress for each subject
        for (var subject in enrolledSubjects) {
          final progress = await SubjectProgressService.getSubjectProgress(
            userId,
            subject.id,
          );
          if (progress != null) {
            subjectProgressMap[subject.id] = progress;
          }
        }
      }
    } catch (e) {
      print('Error loading enrolled subjects: $e');
    }
  }

  Future<void> _loadRecentActivities(String userId) async {
    try {
      final List<Map<String, dynamic>> activities = [];

      // Collect all quiz results from all subjects
      for (var subject in enrolledSubjects) {
        final progress = subjectProgressMap[subject.id];
        if (progress != null && progress.recentQuizzes.isNotEmpty) {
          for (var quiz in progress.recentQuizzes.take(3)) {
            activities.add({
              'title': '${subject.name} - ${quiz.quizType}',
              'type': 'quiz',
              'score': quiz.score,
              'accuracy': (quiz.correctAnswers / quiz.totalQuestions * 100).toInt(),
              'date': quiz.completedAt,
              'subjectIcon': subject.icon,
              'subjectColor': subject.color,
            });
          }
        }

        // Add material completion activities if available
        final completedMaterials = subject.materials.where((m) => m.isCompleted).toList();
        for (var material in completedMaterials.take(2)) {
          if (material.completedAt != null) {
            activities.add({
              'title': '${subject.name} - ${material.title}',
              'type': 'study',
              'materialType': material.type,
              'date': material.completedAt!,
              'subjectIcon': subject.icon,
              'subjectColor': subject.color,
            });
          }
        }
      }

      // Sort activities by date (most recent first)
      activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      // Take only the 10 most recent activities
      recentActivities.value = activities.take(10).toList();

    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  Future<void> _loadWeeklyProgress(String userId) async {
    try {
      final now = DateTime.now();
      final List<Map<String, dynamic>> weekData = [];

      // Get data for the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayName = _getDayName(date.weekday);

        int quizzesCount = 0;
        int totalQuestions = 0;
        int correctAnswers = 0;

        // Check all subjects for quizzes on this day
        for (var subject in enrolledSubjects) {
          final progress = subjectProgressMap[subject.id];
          if (progress != null) {
            for (var quiz in progress.recentQuizzes) {
              if (_isSameDay(quiz.completedAt, date)) {
                quizzesCount++;
                totalQuestions += quiz.totalQuestions;
                correctAnswers += quiz.correctAnswers;
              }
            }
          }
        }

        final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) : 0.0;

        weekData.add({
          'day': dayName,
          'progress': accuracy,
          'quizzes': quizzesCount,
        });
      }

      weeklyProgress.value = weekData;

    } catch (e) {
      print('Error loading weekly progress: $e');
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void refreshData() {
    _loadDashboardData();
  }

  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Dashboard',
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

        // Show empty state if no data
        if (controller.enrolledSubjects.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshData();
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome Section
              _buildWelcomeCard(),
              const SizedBox(height: 20),

              // Statistics Grid
              _buildStatisticsGrid(controller),
              const SizedBox(height: 24),

              // Progress Chart Section
              _buildProgressChartSection(controller),
              const SizedBox(height: 24),

              // Recent Activities
              if (controller.recentActivities.isNotEmpty)
                _buildRecentActivities(controller),

              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.dashboard_outlined,
                size: 64,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Your Journey',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enroll in courses and start taking quizzes to see your progress here.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/enrollment'),
              icon: const Icon(Icons.school_rounded),
              label: const Text('Enroll Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here\'s your learning progress',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(DashboardController controller) {
    final stats = controller.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Statistics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            _buildStatCard(
              'Total Quizzes',
              '${stats['totalQuizzes'] ?? 0}',
              Icons.quiz_outlined,
              const Color(0xFF2196F3),
            ),
            _buildStatCard(
              'Accuracy',
              '${(stats['averageAccuracy'] ?? 0).toStringAsFixed(1)}%',
              Icons.check_circle_outline,
              const Color(0xFF10B981),
            ),
            _buildStatCard(
              'Study Time',
              '${((stats['totalStudyTime'] ?? 0) / 60).toStringAsFixed(0)}h',
              Icons.access_time_rounded,
              const Color(0xFFF59E0B),
            ),
            _buildStatCard(
              'Current Streak',
              '${stats['currentStreak'] ?? 0} days',
              Icons.local_fire_department_rounded,
              const Color(0xFFEF4444),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChartSection(DashboardController controller) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Last 7 days',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (controller.weeklyProgress.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No activity this week',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            )
          else
            ...controller.weeklyProgress.map((dayData) {
              return _buildProgressBar(
                dayData['day'] as String,
                dayData['progress'] as double,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String day, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        ...controller.recentActivities.map((activity) {
          return _buildActivityCard(activity, controller);
        }).toList(),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, DashboardController controller) {
    final isQuiz = activity['type'] == 'quiz';
    final icon = isQuiz ? Icons.quiz_outlined : _getMaterialIcon(activity['materialType'] ?? 'study');
    final color = controller.getColorFromHex(activity['subjectColor'] ?? '#2196F3');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity['subjectIcon'] ?? '📚',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, color: color, size: 20),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(activity['date']),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isQuiz) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${activity['accuracy']}%',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'book':
        return Icons.menu_book;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.play_circle_outline;
      case 'website':
        return Icons.language;
      case 'practice':
        return Icons.assignment;
      default:
        return Icons.article;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}