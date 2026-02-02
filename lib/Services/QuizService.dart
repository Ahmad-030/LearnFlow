import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/QuizModel.dart';
import '../Model/SubjectModel.dart';
import 'SubjectProgressService.dart';

class QuizService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get quizzes for a subject
  static Future<List<QuizModel>> getQuizzesForSubject(String subjectId) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('subjectId', isEqualTo: subjectId)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting quizzes: $e');
      return [];
    }
  }

  // Get quizzes by type
  static Future<List<QuizModel>> getQuizzesByType(
      String subjectId, String quizType) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('subjectId', isEqualTo: subjectId)
          .where('quizType', isEqualTo: quizType)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting quizzes by type: $e');
      return [];
    }
  }

  // Get a single quiz
  static Future<QuizModel?> getQuiz(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();

      if (doc.exists && doc.data() != null) {
        return QuizModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting quiz: $e');
      return null;
    }
  }

  // Save quiz attempt
  static Future<void> saveQuizAttempt(UserQuizAttempt attempt) async {
    try {
      await _firestore
          .collection('quiz_attempts')
          .doc(attempt.id)
          .set(attempt.toMap());

      // Update subject progress
      final quiz = await getQuiz(attempt.quizId);
      if (quiz != null) {
        final quizResult = QuizResult(
          quizId: attempt.quizId,
          quizType: quiz.quizType,
          score: attempt.score,
          totalQuestions: attempt.totalQuestions,
          correctAnswers: attempt.correctAnswers,
          completedAt: attempt.completedAt,
          timeTakenMinutes: attempt.timeTaken,
        );

        await SubjectProgressService.updateQuizResult(
          attempt.userId,
          attempt.subjectId,
          quizResult,
        );
      }
    } catch (e) {
      print('Error saving quiz attempt: $e');
      rethrow;
    }
  }

  // Get user's quiz attempts for a subject
  static Future<List<UserQuizAttempt>> getUserQuizAttempts(
      String userId, String subjectId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserQuizAttempt.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user quiz attempts: $e');
      return [];
    }
  }

  // Get user's all quiz attempts
  static Future<List<UserQuizAttempt>> getAllUserQuizAttempts(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => UserQuizAttempt.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all user quiz attempts: $e');
      return [];
    }
  }

  // Get quiz statistics for user
  static Future<Map<String, dynamic>> getQuizStatistics(
      String userId, String subjectId) async {
    try {
      final attempts = await getUserQuizAttempts(userId, subjectId);

      if (attempts.isEmpty) {
        return {
          'totalAttempts': 0,
          'averageScore': 0.0,
          'bestScore': 0,
          'passRate': 0.0,
          'totalTimeTaken': 0,
        };
      }

      final totalAttempts = attempts.length;
      final totalScore = attempts.fold(0, (sum, a) => sum + a.score);
      final bestScore = attempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);
      final passedCount = attempts.where((a) => a.passed).length;
      final totalTime = attempts.fold(0, (sum, a) => sum + a.timeTaken);

      return {
        'totalAttempts': totalAttempts,
        'averageScore': totalScore / totalAttempts,
        'bestScore': bestScore,
        'passRate': (passedCount / totalAttempts) * 100,
        'totalTimeTaken': totalTime,
      };
    } catch (e) {
      print('Error getting quiz statistics: $e');
      return {};
    }
  }

  // Create sample quizzes (for initialization)
  static Future<void> createSampleQuizzes() async {
    // This would be called once to populate the database
    // You can implement this based on your needs
  }
}