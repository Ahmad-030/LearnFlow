import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Model/QuizModel.dart';
import '../../../Model/SubjectModel.dart';
import 'QuizDataService.dart';

class QuizListController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late SubjectModel subject;
  final RxList<QuizModel> quizzes = <QuizModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedQuizType = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    subject = Get.arguments as SubjectModel;
    _loadQuizzes();
  }

  void _loadQuizzes() {
    try {
      isLoading.value = true;
      quizzes.value = QuizDataService.getQuizzesForSubject(subject.id);
    } catch (e) {
      print('Error loading quizzes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<QuizModel> get filteredQuizzes {
    if (selectedQuizType.value == 'All') {
      return quizzes;
    }
    return quizzes.where((quiz) => quiz.quizType == selectedQuizType.value).toList();
  }

  List<String> get availableQuizTypes {
    return ['All', ...subject.quizTypes];
  }

  void filterByType(String type) {
    selectedQuizType.value = type;
  }

  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuizListController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Quizzes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: controller.getColorFromHex(controller.subject.color),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.quizzes.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Filter chips
            _buildFilterSection(controller),

            // Quiz list
            Expanded(
              child: _buildQuizList(controller),
            ),
          ],
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
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Quizzes Available',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quizzes for this subject will be added soon',
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

  Widget _buildFilterSection(QuizListController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Type',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.availableQuizTypes.map((type) {
                final isSelected = controller.selectedQuizType.value == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.filterByType(type);
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: controller.getColorFromHex(controller.subject.color).withOpacity(0.2),
                    checkmarkColor: controller.getColorFromHex(controller.subject.color),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? controller.getColorFromHex(controller.subject.color)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuizList(QuizListController controller) {
    return Obx(() {
      final quizzes = controller.filteredQuizzes;

      if (quizzes.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              'No quizzes found for selected filter',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return _buildQuizCard(quiz, controller);
        },
      );
    });
  }

  Widget _buildQuizCard(QuizModel quiz, QuizListController controller) {
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
            Get.toNamed('/quiz-take', arguments: quiz);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: controller.getColorFromHex(controller.subject.color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.quiz_outlined,
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
                            quiz.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            quiz.quizType,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: controller.getDifficultyColor(quiz.difficulty).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        quiz.difficulty.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: controller.getDifficultyColor(quiz.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Fixed: Wrap in SingleChildScrollView to prevent overflow
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoChip(
                        Icons.help_outline,
                        '${quiz.questions.length} Qs',
                        const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.timer_outlined,
                        '${quiz.duration} min',
                        const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.verified_outlined,
                        '${quiz.passingScore}%',
                        const Color(0xFF10B981),
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

  Widget _buildInfoChip(IconData icon, String label, Color color) {
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
}