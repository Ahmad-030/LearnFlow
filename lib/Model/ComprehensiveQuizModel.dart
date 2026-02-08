import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/QuizModel.dart';

/// Comprehensive quiz that covers all subjects
class ComprehensiveQuiz {
  final String id;
  final String userId;
  final String title;
  final List<ComprehensiveQuizQuestion> questions; // Questions from all subjects
  final DateTime createdAt;
  final int totalQuestions;
  final int duration; // Total duration in minutes

  ComprehensiveQuiz({
    required this.id,
    required this.userId,
    required this.title,
    required this.questions,
    required this.createdAt,
    required this.totalQuestions,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'totalQuestions': totalQuestions,
      'duration': duration,
    };
  }

  factory ComprehensiveQuiz.fromMap(Map<String, dynamic> map) {
    return ComprehensiveQuiz(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
          ?.map((q) => ComprehensiveQuizQuestion.fromMap(q))
          .toList() ?? [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      totalQuestions: map['totalQuestions'] ?? 0,
      duration: map['duration'] ?? 60,
    );
  }
}

/// Question with subject tracking for comprehensive quiz
class ComprehensiveQuizQuestion {
  final String id;
  final String subjectId;
  final String subjectName;
  final String quizType;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final int points;

  ComprehensiveQuizQuestion({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.quizType,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    this.points = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'quizType': quizType,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'points': points,
    };
  }

  factory ComprehensiveQuizQuestion.fromMap(Map<String, dynamic> map) {
    return ComprehensiveQuizQuestion(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      quizType: map['quizType'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      explanation: map['explanation'],
      points: map['points'] ?? 1,
    );
  }
}

/// Result of comprehensive quiz attempt
class ComprehensiveQuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final Map<String, SubjectPerformance> subjectPerformance; // subjectId -> performance
  final int totalScore;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTaken; // in minutes
  final DateTime startedAt;
  final DateTime completedAt;
  final double overallAccuracy;

  ComprehensiveQuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.answers,
    required this.subjectPerformance,
    required this.totalScore,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTaken,
    required this.startedAt,
    required this.completedAt,
    required this.overallAccuracy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'answers': answers,
      'subjectPerformance': subjectPerformance.map((key, value) => MapEntry(key, value.toMap())),
      'totalScore': totalScore,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeTaken': timeTaken,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'overallAccuracy': overallAccuracy,
    };
  }

  factory ComprehensiveQuizAttempt.fromMap(Map<String, dynamic> map) {
    return ComprehensiveQuizAttempt(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      answers: Map<String, int>.from(map['answers'] ?? {}),
      subjectPerformance: (map['subjectPerformance'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, SubjectPerformance.fromMap(value))) ?? {},
      totalScore: map['totalScore'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      timeTaken: map['timeTaken'] ?? 0,
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      overallAccuracy: (map['overallAccuracy'] ?? 0.0).toDouble(),
    );
  }
}

/// Performance breakdown per subject in comprehensive quiz
class SubjectPerformance {
  final String subjectId;
  final String subjectName;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final List<String> weakTopics; // Quiz types with low accuracy
  final List<String> incorrectQuestionIds; // For detailed review

  SubjectPerformance({
    required this.subjectId,
    required this.subjectName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.weakTopics,
    required this.incorrectQuestionIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'weakTopics': weakTopics,
      'incorrectQuestionIds': incorrectQuestionIds,
    };
  }

  factory SubjectPerformance.fromMap(Map<String, dynamic> map) {
    return SubjectPerformance(
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      weakTopics: List<String>.from(map['weakTopics'] ?? []),
      incorrectQuestionIds: List<String>.from(map['incorrectQuestionIds'] ?? []),
    );
  }
}