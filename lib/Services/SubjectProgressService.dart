import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/SubjectModel.dart';


class SubjectProgressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save or update subject progress
  static Future<void> saveSubjectProgress(
      String userId,
      String subjectId,
      SubjectProgress progress,
      ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('subject_progress')
          .doc(subjectId)
          .set(progress.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving subject progress: $e');
      rethrow;
    }
  }

  // Get subject progress
  static Future<SubjectProgress?> getSubjectProgress(
      String userId,
      String subjectId,
      ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('subject_progress')
          .doc(subjectId)
          .get();

      if (doc.exists && doc.data() != null) {
        return SubjectProgress.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting subject progress: $e');
      return null;
    }
  }

  // Stream subject progress
  static Stream<SubjectProgress?> streamSubjectProgress(
      String userId,
      String subjectId,
      ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('subject_progress')
        .doc(subjectId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return SubjectProgress.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Update quiz result
  static Future<void> updateQuizResult(
      String userId,
      String subjectId,
      QuizResult quizResult,
      ) async {
    try {
      final currentProgress =
          await getSubjectProgress(userId, subjectId) ?? SubjectProgress();

      // Update overall progress
      final newTotalQuizzes = currentProgress.totalQuizzesTaken + 1;
      final newTotalQuestions =
          currentProgress.totalQuestionsAnswered + quizResult.totalQuestions;
      final newCorrectAnswers =
          currentProgress.correctAnswers + quizResult.correctAnswers;
      final newAccuracy =
          (newCorrectAnswers / newTotalQuestions) * 100;

      // Update quiz type progress
      final quizTypeProgress =
      Map<String, QuizTypeProgress>.from(currentProgress.quizTypeProgress);
      final existingTypeProgress = quizTypeProgress[quizResult.quizType];

      if (existingTypeProgress != null) {
        quizTypeProgress[quizResult.quizType] = QuizTypeProgress(
          quizType: quizResult.quizType,
          attemptedQuizzes: existingTypeProgress.attemptedQuizzes + 1,
          totalQuestions:
          existingTypeProgress.totalQuestions + quizResult.totalQuestions,
          correctAnswers:
          existingTypeProgress.correctAnswers + quizResult.correctAnswers,
          accuracy: ((existingTypeProgress.correctAnswers +
              quizResult.correctAnswers) /
              (existingTypeProgress.totalQuestions +
                  quizResult.totalQuestions)) *
              100,
          bestScore: quizResult.score > existingTypeProgress.bestScore
              ? quizResult.score
              : existingTypeProgress.bestScore,
          lastAttempted: quizResult.completedAt,
        );
      } else {
        quizTypeProgress[quizResult.quizType] = QuizTypeProgress(
          quizType: quizResult.quizType,
          attemptedQuizzes: 1,
          totalQuestions: quizResult.totalQuestions,
          correctAnswers: quizResult.correctAnswers,
          accuracy: (quizResult.correctAnswers / quizResult.totalQuestions) * 100,
          bestScore: quizResult.score,
          lastAttempted: quizResult.completedAt,
        );
      }

      // Update recent quizzes (keep last 10)
      final recentQuizzes = List<QuizResult>.from(currentProgress.recentQuizzes);
      recentQuizzes.insert(0, quizResult);
      if (recentQuizzes.length > 10) {
        recentQuizzes.removeRange(10, recentQuizzes.length);
      }

      // Calculate streak
      final now = DateTime.now();
      final lastStudied = currentProgress.lastStudied;
      int newStreak = currentProgress.currentStreak;

      if (lastStudied != null) {
        final daysDifference = now.difference(lastStudied).inDays;
        if (daysDifference == 1) {
          newStreak += 1;
        } else if (daysDifference > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      final newLongestStreak = newStreak > currentProgress.longestStreak
          ? newStreak
          : currentProgress.longestStreak;

      // Create updated progress
      final updatedProgress = SubjectProgress(
        totalQuizzesTaken: newTotalQuizzes,
        totalQuestionsAnswered: newTotalQuestions,
        correctAnswers: newCorrectAnswers,
        accuracyPercentage: newAccuracy,
        studyTimeMinutes:
        currentProgress.studyTimeMinutes + quizResult.timeTakenMinutes,
        quizTypeProgress: quizTypeProgress,
        lastStudied: now,
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        recentQuizzes: recentQuizzes,
      );

      await saveSubjectProgress(userId, subjectId, updatedProgress);
    } catch (e) {
      print('Error updating quiz result: $e');
      rethrow;
    }
  }

  // Mark material as completed
  static Future<void> markMaterialCompleted(
      String userId,
      String subjectId,
      int materialIndex,
      ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('subject_progress')
          .doc(subjectId)
          .update({
        'materials.$materialIndex.isCompleted': true,
        'materials.$materialIndex.completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking material completed: $e');
      rethrow;
    }
  }

  // Get all subject progress for user
  static Future<Map<String, SubjectProgress>> getAllSubjectProgress(
      String userId,
      ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('subject_progress')
          .get();

      final Map<String, SubjectProgress> progressMap = {};
      for (var doc in snapshot.docs) {
        progressMap[doc.id] = SubjectProgress.fromMap(doc.data());
      }
      return progressMap;
    } catch (e) {
      print('Error getting all subject progress: $e');
      return {};
    }
  }

  // Get overall statistics
  static Future<Map<String, dynamic>> getOverallStatistics(
      String userId,
      ) async {
    try {
      final allProgress = await getAllSubjectProgress(userId);

      if (allProgress.isEmpty) {
        return {
          'totalQuizzes': 0,
          'totalQuestions': 0,
          'averageAccuracy': 0.0,
          'totalStudyTime': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'strongestSubject': null,
          'weakestSubject': null,
        };
      }

      int totalQuizzes = 0;
      int totalQuestions = 0;
      int totalCorrect = 0;
      int totalStudyTime = 0;
      int maxStreak = 0;
      int currentStreakAvg = 0;

      String? strongestSubject;
      String? weakestSubject;
      double highestAccuracy = 0.0;
      double lowestAccuracy = 100.0;

      allProgress.forEach((subjectId, progress) {
        totalQuizzes += progress.totalQuizzesTaken;
        totalQuestions += progress.totalQuestionsAnswered;
        totalCorrect += progress.correctAnswers;
        totalStudyTime += progress.studyTimeMinutes;
        if (progress.longestStreak > maxStreak) {
          maxStreak = progress.longestStreak;
        }
        currentStreakAvg += progress.currentStreak;

        if (progress.accuracyPercentage > highestAccuracy &&
            progress.totalQuizzesTaken > 0) {
          highestAccuracy = progress.accuracyPercentage;
          strongestSubject = subjectId;
        }
        if (progress.accuracyPercentage < lowestAccuracy &&
            progress.totalQuizzesTaken > 0) {
          lowestAccuracy = progress.accuracyPercentage;
          weakestSubject = subjectId;
        }
      });

      return {
        'totalQuizzes': totalQuizzes,
        'totalQuestions': totalQuestions,
        'averageAccuracy':
        totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0,
        'totalStudyTime': totalStudyTime,
        'currentStreak':
        allProgress.isNotEmpty ? currentStreakAvg ~/ allProgress.length : 0,
        'longestStreak': maxStreak,
        'strongestSubject': strongestSubject,
        'weakestSubject': weakestSubject,
      };
    } catch (e) {
      print('Error getting overall statistics: $e');
      return {};
    }
  }

  // Reset subject progress
  static Future<void> resetSubjectProgress(
      String userId,
      String subjectId,
      ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('subject_progress')
          .doc(subjectId)
          .delete();
    } catch (e) {
      print('Error resetting subject progress: $e');
      rethrow;
    }
  }
}