import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../Model/ComprehensiveQuizModel.dart';
import '../Model/SubjectModel.dart';
import '../Services/CssSubjectService.dart';
import '../newscreens/QuizDataService.dart';

class ComprehensiveQuizService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a comprehensive quiz with questions from all enrolled subjects
  static Future<ComprehensiveQuiz> generateComprehensiveQuiz(
      String userId,
      List<SubjectModel> enrolledSubjects,
      ) async {
    try {
      List<ComprehensiveQuizQuestion> allQuestions = [];
      int questionsPerSubject = 5; // 5 questions per subject

      for (var subject in enrolledSubjects) {
        // Get all available quizzes for this subject
        final subjectQuizzes = QuizDataService.getQuizzesForSubject(subject.id);

        if (subjectQuizzes.isEmpty) continue;

        // Collect questions from different quiz types
        List<ComprehensiveQuizQuestion> subjectQuestions = [];

        for (var quiz in subjectQuizzes) {
          for (var question in quiz.questions) {
            subjectQuestions.add(
              ComprehensiveQuizQuestion(
                id: '${subject.id}_${question.id}_${DateTime.now().millisecondsSinceEpoch}',
                subjectId: subject.id,
                subjectName: subject.name,
                quizType: quiz.quizType,
                question: question.question,
                options: question.options,
                correctOptionIndex: question.correctOptionIndex,
                explanation: question.explanation,
                points: question.points,
              ),
            );
          }
        }

        // Shuffle and select random questions
        subjectQuestions.shuffle(Random());
        allQuestions.addAll(
          subjectQuestions.take(questionsPerSubject).toList(),
        );
      }

      // Shuffle all questions so subjects are mixed
      allQuestions.shuffle(Random());

      final quiz = ComprehensiveQuiz(
        id: 'comprehensive_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: 'CSS Comprehensive Assessment Quiz',
        questions: allQuestions,
        createdAt: DateTime.now(),
        totalQuestions: allQuestions.length,
        duration: allQuestions.length * 2, // 2 minutes per question
      );

      // Save to Firestore
      await _firestore
          .collection('comprehensive_quizzes')
          .doc(quiz.id)
          .set(quiz.toMap());

      return quiz;

    } catch (e) {
      print('Error generating comprehensive quiz: $e');
      rethrow;
    }
  }

  /// Save comprehensive quiz attempt with subject-wise breakdown
  static Future<void> saveComprehensiveQuizAttempt(
      ComprehensiveQuizAttempt attempt,
      ) async {
    try {
      await _firestore
          .collection('comprehensive_quiz_attempts')
          .doc(attempt.id)
          .set(attempt.toMap());
    } catch (e) {
      print('Error saving comprehensive quiz attempt: $e');
      rethrow;
    }
  }

  /// Calculate subject-wise performance from quiz answers
  static Map<String, SubjectPerformance> calculateSubjectPerformance(
      ComprehensiveQuiz quiz,
      Map<String, int> userAnswers,
      ) {
    Map<String, SubjectPerformance> performance = {};

    // Group questions by subject
    Map<String, List<ComprehensiveQuizQuestion>> questionsBySubject = {};
    for (var question in quiz.questions) {
      if (!questionsBySubject.containsKey(question.subjectId)) {
        questionsBySubject[question.subjectId] = [];
      }
      questionsBySubject[question.subjectId]!.add(question);
    }

    // Calculate performance for each subject
    questionsBySubject.forEach((subjectId, questions) {
      int totalQuestions = questions.length;
      int correctAnswers = 0;
      List<String> incorrectQuestionIds = [];
      Map<String, int> quizTypeCorrect = {};
      Map<String, int> quizTypeTotal = {};

      for (var question in questions) {
        final userAnswer = userAnswers[question.id];
        final isCorrect = userAnswer == question.correctOptionIndex;

        if (isCorrect) {
          correctAnswers++;
        } else {
          incorrectQuestionIds.add(question.id);
        }

        // Track by quiz type
        quizTypeTotal[question.quizType] = (quizTypeTotal[question.quizType] ?? 0) + 1;
        if (isCorrect) {
          quizTypeCorrect[question.quizType] = (quizTypeCorrect[question.quizType] ?? 0) + 1;
        }
      }

      // Identify weak topics (quiz types with < 60% accuracy)
      List<String> weakTopics = [];
      quizTypeTotal.forEach((quizType, total) {
        final correct = quizTypeCorrect[quizType] ?? 0;
        final accuracy = (correct / total) * 100;
        if (accuracy < 60) {
          weakTopics.add(quizType);
        }
      });

      final accuracy = (correctAnswers / totalQuestions) * 100;

      performance[subjectId] = SubjectPerformance(
        subjectId: subjectId,
        subjectName: questions.first.subjectName,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        accuracy: accuracy,
        weakTopics: weakTopics,
        incorrectQuestionIds: incorrectQuestionIds,
      );
    });

    return performance;
  }

  /// Get user's latest comprehensive quiz attempt
  static Future<ComprehensiveQuizAttempt?> getLatestAttempt(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('comprehensive_quiz_attempts')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return ComprehensiveQuizAttempt.fromMap(snapshot.docs.first.data());
    } catch (e) {
      print('Error getting latest attempt: $e');
      return null;
    }
  }

  /// Get all comprehensive quiz attempts for a user
  static Future<List<ComprehensiveQuizAttempt>> getAllAttempts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('comprehensive_quiz_attempts')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ComprehensiveQuizAttempt.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all attempts: $e');
      return [];
    }
  }

  /// Check if user has taken comprehensive quiz
  static Future<bool> hasUserTakenQuiz(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('comprehensive_quiz_attempts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking quiz status: $e');
      return false;
    }
  }

  /// Get comprehensive quiz by ID
  static Future<ComprehensiveQuiz?> getQuiz(String quizId) async {
    try {
      final doc = await _firestore
          .collection('comprehensive_quizzes')
          .doc(quizId)
          .get();

      if (!doc.exists) return null;

      return ComprehensiveQuiz.fromMap(doc.data()!);
    } catch (e) {
      print('Error getting quiz: $e');
      return null;
    }
  }
}