import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Model/QuizModel.dart';

class QuizReviewController extends GetxController {
  late QuizModel quiz;
  late Map<String, int> userAnswers;
  final RxInt currentQuestionIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    quiz = args['quiz'] as QuizModel;
    userAnswers = args['answers'] as Map<String, int>;
  }

  void goToQuestion(int index) {
    currentQuestionIndex.value = index;
  }

  bool isAnswerCorrect(String questionId, int correctIndex) {
    return userAnswers[questionId] == correctIndex;
  }

  int getCorrectAnswersCount() {
    int count = 0;
    for (var question in quiz.questions) {
      if (userAnswers[question.id] == question.correctOptionIndex) {
        count++;
      }
    }
    return count;
  }

  double getScorePercentage() {
    return (getCorrectAnswersCount() / quiz.questions.length) * 100;
  }
}

class QuizReviewScreen extends StatelessWidget {
  const QuizReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuizReviewController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Review Answers',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Score summary
          _buildScoreSummary(controller),

          // Question navigation
          _buildQuestionNavigation(controller),

          // Question review content
          Expanded(
            child: Obx(() => _buildQuestionReview(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(QuizReviewController controller) {
    final correctCount = controller.getCorrectAnswersCount();
    final totalQuestions = controller.quiz.questions.length;
    final percentage = controller.getScorePercentage();
    final passed = percentage >= controller.quiz.passingScore;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: passed
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Score', '${percentage.toStringAsFixed(0)}%', Icons.star),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildStatItem('Correct', '$correctCount/$totalQuestions', Icons.check_circle),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildStatItem('Status', passed ? 'Passed' : 'Failed',
                    passed ? Icons.verified : Icons.cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionNavigation(QuizReviewController controller) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.quiz.questions.length,
        itemBuilder: (context, index) {
          final question = controller.quiz.questions[index];
          final userAnswer = controller.userAnswers[question.id];
          final isCorrect = userAnswer == question.correctOptionIndex;
          final isSelected = controller.currentQuestionIndex.value == index;

          return Obx(() => GestureDetector(
            onTap: () => controller.goToQuestion(index),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2196F3)
                    : (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2196F3)
                      : (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                  ),
                ],
              ),
            ),
          ));
        },
      ),
    );
  }

  Widget _buildQuestionReview(QuizReviewController controller) {
    final question = controller.quiz.questions[controller.currentQuestionIndex.value];
    final userAnswer = controller.userAnswers[question.id];
    final isCorrect = userAnswer == question.correctOptionIndex;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Question ${controller.currentQuestionIndex.value + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? 'Correct' : 'Incorrect',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
            child: Text(
              question.question,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Options
          ...List.generate(question.options.length, (index) {
            final isUserAnswer = userAnswer == index;
            final isCorrectAnswer = question.correctOptionIndex == index;

            return _buildReviewOption(
              question.options[index],
              index,
              isUserAnswer,
              isCorrectAnswer,
            );
          }),

          const SizedBox(height: 24),

          // Explanation
          if (question.explanation != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF2196F3),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Explanation',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.explanation!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF1F2937),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewOption(
      String optionText,
      int index,
      bool isUserAnswer,
      bool isCorrectAnswer,
      ) {
    Color borderColor;
    Color backgroundColor;
    IconData? icon;
    Color? iconColor;

    if (isCorrectAnswer) {
      borderColor = const Color(0xFF10B981);
      backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
      icon = Icons.check_circle;
      iconColor = const Color(0xFF10B981);
    } else if (isUserAnswer) {
      borderColor = const Color(0xFFEF4444);
      backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
      icon = Icons.cancel;
      iconColor = const Color(0xFFEF4444);
    } else {
      borderColor = const Color(0xFFE5E7EB);
      backgroundColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: iconColor, size: 24)
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              optionText,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: (isCorrectAnswer || isUserAnswer) ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}