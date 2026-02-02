import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String id;
  final String subjectId;
  final String title;
  final String quizType;
  final List<QuizQuestion> questions;
  final int duration; // in minutes
  final int passingScore;
  final String difficulty; // 'easy', 'medium', 'hard'
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.quizType,
    required this.questions,
    required this.duration,
    required this.passingScore,
    required this.difficulty,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'quizType': quizType,
      'questions': questions.map((q) => q.toMap()).toList(),
      'duration': duration,
      'passingScore': passingScore,
      'difficulty': difficulty,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      title: map['title'] ?? '',
      quizType: map['quizType'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
          ?.map((q) => QuizQuestion.fromMap(q))
          .toList() ??
          [],
      duration: map['duration'] ?? 30,
      passingScore: map['passingScore'] ?? 60,
      difficulty: map['difficulty'] ?? 'medium',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    this.points = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'points': points,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      explanation: map['explanation'],
      points: map['points'] ?? 1,
    );
  }
}

class UserQuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final String subjectId;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeTaken; // in minutes
  final DateTime startedAt;
  final DateTime completedAt;
  final bool passed;

  UserQuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.subjectId,
    required this.answers,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeTaken,
    required this.startedAt,
    required this.completedAt,
    required this.passed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'subjectId': subjectId,
      'answers': answers,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'passed': passed,
    };
  }

  factory UserQuizAttempt.fromMap(Map<String, dynamic> map) {
    return UserQuizAttempt(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      answers: Map<String, int>.from(map['answers'] ?? {}),
      score: map['score'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timeTaken: map['timeTaken'] ?? 0,
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      passed: map['passed'] ?? false,
    );
  }
}