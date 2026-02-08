import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../Model/ComprehensiveQuizModel.dart';
import '../../../../Services/ComprehensiveQuizService.dart';
import '../../../../Services/CssSubjectService.dart';


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

  @override
  void onInit() {
    super.onInit();
    _loadEnrolledSubjectsCount();
  }

  Future<void> _loadEnrolledSubjectsCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final subjects = await CssSubjectService.getEnrolledSubjects(userId);
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
        Get.snackbar('Error', 'Please login first');
        return;
      }

      // Get enrolled subjects
      final subjects = await CSSSubjectsService.getEnrolledSubjects(userId);

      if (subjects.isEmpty) {
        Get.snackbar(
          'No Subjects',
          'Please enroll in subjects first',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      // Generate comprehensive quiz
      final generatedQuiz = await ComprehensiveQuizService.generateComprehensiveQuiz(
        userId,
        subjects,
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
    } finally {
      isLoading.value = false;
    }
  }

  void selectAnswer(String questionId, int optionIndex) {
    selectedAnswers[questionId] = optionIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < quiz.value!.questions.length - 1) {
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
    isLastQuestion.value =
        currentQuestionIndex.value == quiz.value!.questions.length - 1;
  }

  Future<void> submitQuiz() async {
    try {
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
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit quiz: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}