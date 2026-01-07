import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Model/SubjectModel.dart';
import '../../Services/SubjectProgressService.dart';

class SubjectDetailController extends GetxController with GetSingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late SubjectModel subject;
  final Rx<SubjectProgress?> progress = Rx<SubjectProgress?>(null);
  final RxBool isLoading = true.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    subject = Get.arguments as SubjectModel;
    tabController = TabController(length: 3, vsync: this);
    _loadProgress();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> _loadProgress() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final subjectProgress = await SubjectProgressService.getSubjectProgress(
          user.uid,
          subject.id,
        );
        progress.value = subjectProgress;
      }
    } catch (e) {
      print('Error loading progress: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openLink(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Error',
        'No link available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubjectDetailController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          _buildSliverAppBar(controller, context),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: controller.tabController,
                labelColor: controller.getColorFromHex(controller.subject.color),
                unselectedLabelColor: const Color(0xFF6B7280),
                indicatorColor: controller.getColorFromHex(controller.subject.color),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Materials'),
                  Tab(text: 'Progress'),
                ],
              ),
            ),
          ),

          // Content
          SliverFillRemaining(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return TabBarView(
                controller: controller.tabController,
                children: [
                  _buildOverviewTab(controller, context),
                  _buildMaterialsTab(controller, context),
                  _buildProgressTab(controller, context),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(SubjectDetailController controller, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: controller.getColorFromHex(controller.subject.color),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          controller.subject.name,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                controller.getColorFromHex(controller.subject.color),
                controller.getColorFromHex(controller.subject.color).withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Text(
              controller.subject.icon,
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(SubjectDetailController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Card
          Container(
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
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: controller.getColorFromHex(controller.subject.color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'About this Subject',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  controller.subject.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Stats
          _buildQuickStats(controller),

          const SizedBox(height: 20),

          // Quiz Types
          Text(
            'Available Quiz Types',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...controller.subject.quizTypes.map((quizType) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.getColorFromHex(controller.subject.color).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller.getColorFromHex(controller.subject.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: controller.getColorFromHex(controller.subject.color),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      quizType,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: controller.getColorFromHex(controller.subject.color),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickStats(SubjectDetailController controller) {
    final progress = controller.progress.value;
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
            'Quick Stats',
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
                child: _buildStatCard(
                  'Materials',
                  '${controller.subject.materials.length}',
                  Icons.book_outlined,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Quizzes',
                  '${progress?.totalQuizzesTaken ?? 0}',
                  Icons.quiz_outlined,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Accuracy',
                  '${(progress?.accuracyPercentage ?? 0).toStringAsFixed(1)}%',
                  Icons.analytics_outlined,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Study Time',
                  '${progress?.studyTimeMinutes ?? 0}m',
                  Icons.timer_outlined,
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
      ),
    );
  }

  Widget _buildMaterialsTab(SubjectDetailController controller, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Materials',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${controller.subject.materials.length} resources available',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),

          // Group materials by type
          ...['book', 'pdf', 'video', 'website', 'practice'].map((type) {
            final materials = controller.subject.materials
                .where((m) => m.type == type)
                .toList();

            if (materials.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMaterialTypeTitle(type),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                ...materials.map((material) => _buildMaterialCard(controller, material)),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getMaterialTypeTitle(String type) {
    switch (type) {
      case 'book':
        return '📚 Books';
      case 'pdf':
        return '📄 PDF Documents';
      case 'video':
        return '🎥 Video Tutorials';
      case 'website':
        return '🌐 Websites';
      case 'practice':
        return '✏️ Practice Materials';
      default:
        return '📖 Resources';
    }
  }

  Widget _buildMaterialCard(SubjectDetailController controller, EducationalMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          onTap: () => controller.openLink(material.link),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.getColorFromHex(controller.subject.color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMaterialIcon(material.type),
                    color: controller.getColorFromHex(controller.subject.color),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      if (material.author != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'by ${material.author}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                      if (material.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          material.description!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: controller.getColorFromHex(controller.subject.color),
                  size: 20,
                ),
              ],
            ),
          ),
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

  Widget _buildProgressTab(SubjectDetailController controller, BuildContext context) {
    final progress = controller.progress.value;

    if (progress == null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Progress Yet',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start taking quizzes to track your progress',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress
          _buildOverallProgressCard(controller, progress),

          const SizedBox(height: 20),

          // Quiz Type Performance
          Text(
            'Performance by Quiz Type',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...progress.quizTypeProgress.entries.map((entry) {
            return _buildQuizTypeCard(controller, entry.key, entry.value);
          }).toList(),

          const SizedBox(height: 20),

          // Recent Quizzes
          if (progress.recentQuizzes.isNotEmpty) ...[
            Text(
              'Recent Quiz Results',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            ...progress.recentQuizzes.take(5).map((quiz) {
              return _buildRecentQuizCard(controller, quiz);
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(SubjectDetailController controller, SubjectProgress progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            controller.getColorFromHex(controller.subject.color),
            controller.getColorFromHex(controller.subject.color).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: controller.getColorFromHex(controller.subject.color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Performance',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${progress.accuracyPercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Accuracy',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${progress.totalQuizzesTaken}',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Quizzes',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${progress.currentStreak}',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Day Streak',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTypeCard(SubjectDetailController controller, String quizType, QuizTypeProgress progress) {
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
              Expanded(
                child: Text(
                  quizType,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: controller.getColorFromHex(controller.subject.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progress.accuracy.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: controller.getColorFromHex(controller.subject.color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProgressStat('Quizzes', '${progress.attemptedQuizzes}'),
              const SizedBox(width: 16),
              _buildProgressStat('Questions', '${progress.totalQuestions}'),
              const SizedBox(width: 16),
              _buildProgressStat('Best', '${progress.bestScore}'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.accuracy / 100,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation(
                controller.getColorFromHex(controller.subject.color),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentQuizCard(SubjectDetailController controller, QuizResult quiz) {
    final accuracy = (quiz.correctAnswers / quiz.totalQuestions) * 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: controller.getColorFromHex(controller.subject.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.quiz_outlined,
              color: controller.getColorFromHex(controller.subject.color),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.quizType,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quiz.correctAnswers}/${quiz.totalQuestions} correct • ${quiz.timeTakenMinutes}m',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${accuracy.toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: controller.getColorFromHex(controller.subject.color),
                ),
              ),
              Text(
                'Score: ${quiz.score}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}