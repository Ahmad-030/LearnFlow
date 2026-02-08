import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../Model/ComprehensiveQuizModel.dart';
import '../../../../Model/SubjectModel.dart';
import '../../../../Services/ComprehensiveQuizService.dart';
import '../../../../Services/CssSubjectService.dart';
import 'StudyPlanController.dart';

class ComprehensiveQuizController extends GetxController {
  final _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var quiz = Rxn<ComprehensiveQuiz>();
  var currentQuestionIndex = 0.obs;
  var selectedAnswers = <String, int>{}.obs;
  var isQuizCompleted = false.obs;
  var currentAttempt = Rxn<ComprehensiveQuizAttempt>();
  var startTime = Rxn<DateTime>();
  var totalQuestions = 0.obs;
  var estimatedTime = 0.obs;
  var isLastQuestion = false.obs;
  var enrolledSubjects = <SubjectModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadEnrolledSubjectsCount();
  }

  Future<void> _loadEnrolledSubjectsCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get all subjects
      final subjects = CSSSubjectsService.getAllCSSSubjects();

      totalQuestions.value = subjects.length * 5; // 5 questions per subject
      estimatedTime.value = totalQuestions.value * 2; // 2 min per question
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }

  Future<void> generateQuiz() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        Get.snackbar(
          'Error',
          'Please login first',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get all subjects
      enrolledSubjects.value = CSSSubjectsService.getAllCSSSubjects();

      if (enrolledSubjects.isEmpty) {
        Get.snackbar(
          'No Subjects',
          'No subjects available',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      // Generate comprehensive quiz
      final generatedQuiz = await ComprehensiveQuizService.generateComprehensiveQuiz(
        userId,
        enrolledSubjects,
      );

      quiz.value = generatedQuiz;
      startTime.value = DateTime.now();
      selectedAnswers.clear();
      currentQuestionIndex.value = 0;
      isQuizCompleted.value = false;
      _updateLastQuestionStatus();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate quiz: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Generate quiz error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(String questionId, int optionIndex) {
    selectedAnswers[questionId] = optionIndex;
  }

  void nextQuestion() {
    if (quiz.value != null &&
        currentQuestionIndex.value < quiz.value!.questions.length - 1) {
      currentQuestionIndex.value++;
      _updateLastQuestionStatus();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      _updateLastQuestionStatus();
    }
  }

  void _updateLastQuestionStatus() {
    if (quiz.value != null) {
      isLastQuestion.value =
          currentQuestionIndex.value == quiz.value!.questions.length - 1;
    }
  }

  Future<void> submitQuiz() async {
    try {
      if (quiz.value == null) {
        Get.snackbar(
          'Error',
          'No quiz found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if all questions are answered
      final unansweredCount = quiz.value!.questions.length - selectedAnswers.length;

      if (unansweredCount > 0) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Incomplete Quiz'),
            content: Text(
              'You have $unansweredCount unanswered question${unansweredCount > 1 ? 's' : ''}. Submit anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      isLoading.value = true;

      // Calculate performance
      final subjectPerformance = ComprehensiveQuizService.calculateSubjectPerformance(
        quiz.value!,
        selectedAnswers,
      );

      // Calculate overall stats
      int totalCorrect = 0;
      int totalScore = 0;

      for (var question in quiz.value!.questions) {
        final userAnswer = selectedAnswers[question.id];
        if (userAnswer == question.correctOptionIndex) {
          totalCorrect++;
          totalScore += question.points;
        }
      }

      final accuracy = (totalCorrect / quiz.value!.totalQuestions) * 100;
      final timeTaken = DateTime.now().difference(startTime.value!).inMinutes;

      // Create attempt record
      final attempt = ComprehensiveQuizAttempt(
        id: 'attempt_${_auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}',
        userId: _auth.currentUser!.uid,
        quizId: quiz.value!.id,
        answers: selectedAnswers,
        subjectPerformance: subjectPerformance,
        totalScore: totalScore,
        totalQuestions: quiz.value!.totalQuestions,
        correctAnswers: totalCorrect,
        timeTaken: timeTaken,
        startedAt: startTime.value!,
        completedAt: DateTime.now(),
        overallAccuracy: accuracy,
      );

      // Save to Firestore
      await ComprehensiveQuizService.saveComprehensiveQuizAttempt(attempt);

      currentAttempt.value = attempt;
      isQuizCompleted.value = true;

      Get.snackbar(
        'Success',
        'Quiz submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Wait a moment then auto-navigate to study plan
      await Future.delayed(const Duration(seconds: 2));

      // Clear the StudyPlanController to force refresh
      Get.delete<StudyPlanController>();

      // Navigate to study plan screen
      Get.offAllNamed('/study-plan');

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit quiz: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Submit quiz error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry the comprehensive quiz
  Future<void> retryQuiz() async {
    try {
      isLoading.value = true;

      // Reset all quiz state
      selectedAnswers.clear();
      currentQuestionIndex.value = 0;
      isQuizCompleted.value = false;
      currentAttempt.value = null;
      startTime.value = null;

      // Generate a new quiz
      await generateQuiz();

      Get.snackbar(
        'New Quiz Started',
        'Good luck with your new attempt!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start new quiz: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Retry quiz error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper method to get current question
  ComprehensiveQuizQuestion? get currentQuestion {
    if (quiz.value != null &&
        currentQuestionIndex.value < quiz.value!.questions.length) {
      return quiz.value!.questions[currentQuestionIndex.value];
    }
    return null;
  }

  /// Helper method to check if answer is selected for current question
  bool get isCurrentQuestionAnswered {
    if (currentQuestion != null) {
      return selectedAnswers.containsKey(currentQuestion!.id);
    }
    return false;
  }

  /// Helper method to get selected answer for current question
  int? get currentSelectedAnswer {
    if (currentQuestion != null) {
      return selectedAnswers[currentQuestion!.id];
    }
    return null;
  }

  /// Calculate progress percentage
  double get progressPercentage {
    if (quiz.value == null || quiz.value!.questions.isEmpty) return 0.0;
    return (currentQuestionIndex.value + 1) / quiz.value!.questions.length;
  }

  /// Get answered questions count
  int get answeredQuestionsCount => selectedAnswers.length;

  /// Get remaining time in minutes
  int get remainingTime {
    if (quiz.value == null || startTime.value == null) return 0;
    final elapsed = DateTime.now().difference(startTime.value!).inMinutes;
    final remaining = quiz.value!.duration - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if time is up
  bool get isTimeUp {
    if (quiz.value == null || startTime.value == null) return false;
    final elapsed = DateTime.now().difference(startTime.value!).inMinutes;
    return elapsed >= quiz.value!.duration;
  }

  /// Navigate to specific question
  void goToQuestion(int index) {
    if (quiz.value != null &&
        index >= 0 &&
        index < quiz.value!.questions.length) {
      currentQuestionIndex.value = index;
      _updateLastQuestionStatus();
    }
  }

  /// Clear answer for current question
  void clearCurrentAnswer() {
    if (currentQuestion != null) {
      selectedAnswers.remove(currentQuestion!.id);
    }
  }

  /// Get questions by subject
  List<ComprehensiveQuizQuestion> getQuestionsBySubject(String subjectId) {
    if (quiz.value == null) return [];
    return quiz.value!.questions
        .where((q) => q.subjectId == subjectId)
        .toList();
  }

  /// Get subject progress (answered/total)
  Map<String, String> getSubjectProgress(String subjectId) {
    final subjectQuestions = getQuestionsBySubject(subjectId);
    final answeredCount = subjectQuestions
        .where((q) => selectedAnswers.containsKey(q.id))
        .length;

    return {
      'answered': answeredCount.toString(),
      'total': subjectQuestions.length.toString(),
    };
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}