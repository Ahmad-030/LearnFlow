import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/QuizModel.dart';
import '../Model/SubjectModel.dart';
import 'QuizDataService.dart';

/// Service to seed the database with initial quiz data
class DatabaseSeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if database has been seeded
  static Future<bool> isDatabaseSeeded() async {
    try {
      final doc = await _firestore.collection('app_config').doc('seed_status').get();
      return doc.exists && (doc.data()?['isSeeded'] ?? false);
    } catch (e) {
      print('Error checking seed status: $e');
      return false;
    }
  }

  /// Mark database as seeded
  static Future<void> markAsSeeded() async {
    try {
      await _firestore.collection('app_config').doc('seed_status').set({
        'isSeeded': true,
        'seedDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking as seeded: $e');
    }
  }

  /// Seed all quizzes into Firestore
  static Future<void> seedQuizzes() async {
    try {
      final allQuizzes = QuizDataService.getAllQuizzes();

      final batch = _firestore.batch();

      for (var quiz in allQuizzes) {
        final docRef = _firestore.collection('quizzes').doc(quiz.id);
        batch.set(docRef, quiz.toMap());
      }

      await batch.commit();
      print('Successfully seeded ${allQuizzes.length} quizzes');
    } catch (e) {
      print('Error seeding quizzes: $e');
      rethrow;
    }
  }

  /// Create demo quiz attempts for a user to show statistics
  static Future<void> createDemoQuizAttempts(String userId) async {
    try {
      final demoAttempts = _generateDemoAttempts(userId);

      final batch = _firestore.batch();

      for (var attempt in demoAttempts) {
        final docRef = _firestore.collection('quiz_attempts').doc(attempt.id);
        batch.set(docRef, attempt.toMap());
      }

      await batch.commit();
      print('Successfully created ${demoAttempts.length} demo quiz attempts');
    } catch (e) {
      print('Error creating demo attempts: $e');
      rethrow;
    }
  }

  /// Generate realistic demo quiz attempts
  static List<UserQuizAttempt> _generateDemoAttempts(String userId) {
    final now = DateTime.now();
    final List<UserQuizAttempt> attempts = [];

    // English Essay - 3 attempts
    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_1',
      userId: userId,
      quizId: 'essay_outline_1',
      subjectId: 'english_essay',
      answers: {'q1': 1, 'q2': 1, 'q3': 2, 'q4': 1, 'q5': 2},
      score: 80,
      correctAnswers: 4,
      totalQuestions: 5,
      timeTaken: 12,
      startedAt: now.subtract(const Duration(days: 7)),
      completedAt: now.subtract(const Duration(days: 7)),
      passed: true,
    ));

    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_2',
      userId: userId,
      quizId: 'essay_topics_1',
      subjectId: 'english_essay',
      answers: {'q1': 1, 'q2': 1, 'q3': 1, 'q4': 1, 'q5': 1},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 15,
      startedAt: now.subtract(const Duration(days: 5)),
      completedAt: now.subtract(const Duration(days: 5)),
      passed: true,
    ));

    // English Precis - 2 attempts
    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_3',
      userId: userId,
      quizId: 'precis_basics_1',
      subjectId: 'english_precis_composition',
      answers: {'q1': 1, 'q2': 2, 'q3': 2, 'q4': 1, 'q5': 2},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 13,
      startedAt: now.subtract(const Duration(days: 4)),
      completedAt: now.subtract(const Duration(days: 4)),
      passed: true,
    ));

    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_4',
      userId: userId,
      quizId: 'grammar_usage_1',
      subjectId: 'english_precis_composition',
      answers: {'q1': 2, 'q2': 0, 'q3': 1, 'q4': 2, 'q5': 1},
      score: 80,
      correctAnswers: 4,
      totalQuestions: 5,
      timeTaken: 18,
      startedAt: now.subtract(const Duration(days: 3)),
      completedAt: now.subtract(const Duration(days: 3)),
      passed: true,
    ));

    // General Science - 3 attempts
    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_5',
      userId: userId,
      quizId: 'science_mcq_1',
      subjectId: 'general_science_ability',
      answers: {'q1': 1, 'q2': 3, 'q3': 2, 'q4': 2, 'q5': 2},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 14,
      startedAt: now.subtract(const Duration(days: 6)),
      completedAt: now.subtract(const Duration(days: 6)),
      passed: true,
    ));

    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_6',
      userId: userId,
      quizId: 'science_physics_1',
      subjectId: 'general_science_ability',
      answers: {'q1': 1, 'q2': 2, 'q3': 2, 'q4': 2, 'q5': 1},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 16,
      startedAt: now.subtract(const Duration(days: 2)),
      completedAt: now.subtract(const Duration(days: 2)),
      passed: true,
    ));

    // Current Affairs - 2 attempts
    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_7',
      userId: userId,
      quizId: 'current_affairs_1',
      subjectId: 'current_affairs',
      answers: {'q1': 1, 'q2': 1, 'q3': 3, 'q4': 1, 'q5': 2},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 17,
      startedAt: now.subtract(const Duration(days: 8)),
      completedAt: now.subtract(const Duration(days: 8)),
      passed: true,
    ));

    // Pakistan Affairs - 3 attempts
    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_8',
      userId: userId,
      quizId: 'pakistan_history_1',
      subjectId: 'pakistan_affairs',
      answers: {'q1': 1, 'q2': 2, 'q3': 2, 'q4': 1, 'q5': 1},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 11,
      startedAt: now.subtract(const Duration(days: 9)),
      completedAt: now.subtract(const Duration(days: 9)),
      passed: true,
    ));

    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_9',
      userId: userId,
      quizId: 'pakistan_geography_1',
      subjectId: 'pakistan_affairs',
      answers: {'q1': 1, 'q2': 3, 'q3': 1, 'q4': 2, 'q5': 2},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 10,
      startedAt: now.subtract(const Duration(days: 1)),
      completedAt: now.subtract(const Duration(days: 1)),
      passed: true,
    ));

    // Islamic Studies - 2 attempts
    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_10',
      userId: userId,
      quizId: 'islamic_basics_1',
      subjectId: 'islamic_studies',
      answers: {'q1': 2, 'q2': 2, 'q3': 2, 'q4': 1, 'q5': 2},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 13,
      startedAt: now.subtract(const Duration(days: 10)),
      completedAt: now.subtract(const Duration(days: 10)),
      passed: true,
    ));

    attempts.add(UserQuizAttempt(
      id: 'demo_attempt_11',
      userId: userId,
      quizId: 'quran_knowledge_1',
      subjectId: 'islamic_studies',
      answers: {'q1': 1, 'q2': 0, 'q3': 1, 'q4': 0, 'q5': 3},
      score: 100,
      correctAnswers: 5,
      totalQuestions: 5,
      timeTaken: 19,
      startedAt: now.subtract(const Duration(hours: 2)),
      completedAt: now.subtract(const Duration(hours: 2)),
      passed: true,
    ));

    return attempts;
  }

  /// Initialize the entire database (should be called once)
  static Future<void> initializeDatabase() async {
    try {
      final isSeeded = await isDatabaseSeeded();

      if (isSeeded) {
        print('Database already seeded. Skipping...');
        return;
      }

      print('Initializing database...');

      // Seed quizzes
      await seedQuizzes();

      // Mark as seeded
      await markAsSeeded();

      print('Database initialization complete!');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create demo data for a new user (optional - for testing)
  static Future<void> setupDemoDataForUser(String userId) async {
    try {
      print('Setting up demo data for user: $userId');
      await createDemoQuizAttempts(userId);
      print('Demo data setup complete!');
    } catch (e) {
      print('Error setting up demo data: $e');
      rethrow;
    }
  }

  /// Clear all quiz data (use with caution - for development only)
  static Future<void> clearAllQuizData() async {
    try {
      // Delete all quizzes
      final quizzesSnapshot = await _firestore.collection('quizzes').get();
      final batch1 = _firestore.batch();
      for (var doc in quizzesSnapshot.docs) {
        batch1.delete(doc.reference);
      }
      await batch1.commit();

      // Delete all quiz attempts
      final attemptsSnapshot = await _firestore.collection('quiz_attempts').get();
      final batch2 = _firestore.batch();
      for (var doc in attemptsSnapshot.docs) {
        batch2.delete(doc.reference);
      }
      await batch2.commit();

      // Reset seed status
      await _firestore.collection('app_config').doc('seed_status').delete();

      print('All quiz data cleared successfully');
    } catch (e) {
      print('Error clearing quiz data: $e');
      rethrow;
    }
  }
}