import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/QuizModel.dart';
import '../Screens/UI/Home/HomeScreen.dart';
import '../Services/QuizService.dart';
import '../Widgets/Custom_Toast.dart';
import '../Screens/UI/Dashboard/DashboardScreen.dart';
import '../Screens/UI/Home/SubjectDetailScreen.dart';

class QuizTakeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late QuizModel quiz;
  final RxInt currentQuestionIndex = 0.obs;
  final RxMap<String, int> selectedAnswers = <String, int>{}.obs;
  final RxInt timeRemaining = 0.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool quizCompleted = false.obs;
  Timer? _timer;
  late DateTime startTime;

  @override
  void onInit() {
    super.onInit();
    quiz = Get.arguments as QuizModel;
    startTime = DateTime.now();
    timeRemaining.value = quiz.duration * 60;
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        timer.cancel();
        _autoSubmitQuiz();
      }
    });
  }

  void selectAnswer(String questionId, int optionIndex) {
    selectedAnswers[questionId] = optionIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < quiz.questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToQuestion(int index) {
    currentQuestionIndex.value = index;
  }

  int get answeredCount => selectedAnswers.length;
  int get totalQuestions => quiz.questions.length;
  bool get isLastQuestion => currentQuestionIndex.value == quiz.questions.length - 1;

  String get timeRemainingFormatted {
    final minutes = (timeRemaining.value / 60).floor();
    final seconds = timeRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _autoSubmitQuiz() async {
    CustomToast.warning('Time is up! Submitting quiz automatically...');
    await Future.delayed(const Duration(seconds: 1));
    await submitQuiz();
  }

  Future<void> submitQuiz() async {
    try {
      if (isSubmitting.value) return;

      isSubmitting.value = true;
      print('Starting quiz submission...');

      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // Calculate results
      int correctAnswers = 0;
      int totalPoints = 0;
      for (var question in quiz.questions) {
        final selectedAnswer = selectedAnswers[question.id];
        if (selectedAnswer != null && selectedAnswer == question.correctOptionIndex) {
          correctAnswers++;
          totalPoints += question.points;
        }
      }

      final score = ((correctAnswers / quiz.questions.length) * 100).round();
      final passed = score >= quiz.passingScore;
      final timeTaken = DateTime.now().difference(startTime).inMinutes.clamp(1, quiz.duration);

      // Create quiz attempt
      final attempt = UserQuizAttempt(
        id: 'attempt_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        quizId: quiz.id,
        subjectId: quiz.subjectId,
        answers: Map.from(selectedAnswers),
        score: score,
        correctAnswers: correctAnswers,
        totalQuestions: quiz.questions.length,
        timeTaken: timeTaken,
        startedAt: startTime,
        completedAt: DateTime.now(),
        passed: passed,
      );

      print('Saving quiz attempt to Firestore...');
      await QuizService.saveQuizAttempt(attempt);
      print('Quiz attempt saved successfully');

      // Force refresh all controllers
      await _forceRefreshAllControllers();

      quizCompleted.value = true;

      // Show result dialog with retry option
      _showResultDialog(score, correctAnswers, passed);
    } catch (e) {
      print('Error submitting quiz: $e');
      CustomToast.error('Failed to submit quiz: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Enhanced method to force refresh all controllers
  Future<void> _forceRefreshAllControllers() async {
    try {
      print('Force refreshing all controllers...');

      // Small delay to ensure Firestore write completes
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh HomeController
      if (Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          print('Refreshing HomeController...');
          homeController.refreshData();
          homeController.update();
        } catch (e) {
          print('Error refreshing HomeController: $e');
        }
      }

      // Refresh DashboardController
      if (Get.isRegistered<DashboardController>()) {
        try {
          final dashboardController = Get.find<DashboardController>();
          print('Refreshing DashboardController...');
          dashboardController.refreshData();
          dashboardController.update();
        } catch (e) {
          print('Error refreshing DashboardController: $e');
        }
      }

      // Refresh SubjectDetailController
      if (Get.isRegistered<SubjectDetailController>()) {
        try {
          final subjectController = Get.find<SubjectDetailController>();
          print('Refreshing SubjectDetailController...');
          await subjectController.refreshProgress();
          subjectController.update();
        } catch (e) {
          print('Error refreshing SubjectDetailController: $e');
        }
      }

      print('All controllers refreshed successfully');
      await Future.delayed(const Duration(milliseconds: 300));

    } catch (e) {
      print('Error in force refresh: $e');
    }
  }

  void _showResultDialog(int score, int correctAnswers, bool passed) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Result Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: passed
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passed ? Icons.check_circle : Icons.cancel,
                    size: 60,
                    color: passed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  passed ? 'Congratulations!' : 'Keep Practicing!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  passed
                      ? 'You passed the quiz! Great job! 🎉'
                      : 'You didn\'t pass this time, but every attempt makes you stronger! 💪',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Score Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Score',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '$score%',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: passed
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Correct Answers',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '$correctAnswers/${quiz.questions.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Passing Score',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${quiz.passingScore}%',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    // Review Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back(); // Close dialog
                          Get.toNamed('/quiz-review', arguments: {
                            'quiz': quiz,
                            'answers': Map.from(selectedAnswers),
                          });
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(
                          'Review Answers',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Retry Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back(); // Close dialog
                          Get.back(); // Go back to quiz list
                          // Immediately restart the quiz
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Get.toNamed('/quiz-take', arguments: quiz);
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          'Retry Quiz',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10B981),
                          side: const BorderSide(color: Color(0xFF10B981), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Get.back(); // Close dialog
                          Get.back(); // Go back to quiz list
                          Get.back(); // Go back to subject details
                        },
                        child: Text(
                          'Back to Subject',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
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
      ),
      barrierDismissible: false,
    );
  }
}

class QuizTakeScreen extends StatelessWidget {
  const QuizTakeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuizTakeController());

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitDialog();
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            controller.quiz.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2196F3),
          elevation: 0,
          actions: [
            Obx(() => Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: controller.timeRemaining.value < 60
                    ? const Color(0xFFEF4444)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    controller.timeRemainingFormatted,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressBar(controller),
            // Question content
            Expanded(
              child: Obx(() => _buildQuestionContent(controller)),
            ),
            // Navigation buttons
            _buildNavigationButtons(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(QuizTakeController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${controller.currentQuestionIndex.value + 1}/${controller.totalQuestions}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Answered: ${controller.answeredCount}/${controller.totalQuestions}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (controller.currentQuestionIndex.value + 1) / controller.totalQuestions,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2196F3)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildQuestionContent(QuizTakeController controller) {
    final question = controller.quiz.questions[controller.currentQuestionIndex.value];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question card
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
            return _buildOptionCard(
              controller,
              question.id,
              index,
              question.options[index],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
      QuizTakeController controller,
      String questionId,
      int optionIndex,
      String optionText,
      ) {
    return Obx(() {
      final isSelected = controller.selectedAnswers[questionId] == optionIndex;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectAnswer(questionId, optionIndex),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : const Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      optionText,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavigationButtons(QuizTakeController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => Row(
          children: [
            if (controller.currentQuestionIndex.value > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            if (controller.currentQuestionIndex.value > 0) const SizedBox(width: 12),
            Expanded(
              flex: controller.currentQuestionIndex.value > 0 ? 1 : 2,
              child: controller.isLastQuestion
                  ? ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => _showSubmitDialog(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Submit Quiz',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
                  : ElevatedButton(
                onPressed: controller.nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Future<void> _showSubmitDialog(QuizTakeController controller) async {
    final unanswered = controller.totalQuestions - controller.answeredCount;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Submit Quiz?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered question${unanswered > 1 ? 's' : ''}. Do you want to submit anyway?'
              : 'Are you sure you want to submit your quiz?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitDialog() async {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Exit Quiz?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}