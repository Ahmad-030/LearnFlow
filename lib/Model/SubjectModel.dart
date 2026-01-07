import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String description;
  final List<EducationalMaterial> materials;
  final List<String> quizTypes;
  final SubjectProgress? progress;

  SubjectModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.materials,
    required this.quizTypes,
    this.progress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'description': description,
      'materials': materials.map((m) => m.toMap()).toList(),
      'quizTypes': quizTypes,
      'progress': progress?.toMap(),
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
      description: map['description'] ?? '',
      materials: (map['materials'] as List<dynamic>?)
          ?.map((m) => EducationalMaterial.fromMap(m))
          .toList() ??
          [],
      quizTypes: List<String>.from(map['quizTypes'] ?? []),
      progress: map['progress'] != null
          ? SubjectProgress.fromMap(map['progress'])
          : null,
    );
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? description,
    List<EducationalMaterial>? materials,
    List<String>? quizTypes,
    SubjectProgress? progress,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      materials: materials ?? this.materials,
      quizTypes: quizTypes ?? this.quizTypes,
      progress: progress ?? this.progress,
    );
  }
}

class EducationalMaterial {
  final String type; // 'book', 'video', 'article', 'practice', 'pdf', 'website'
  final String title;
  final String? author;
  final String? link;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;

  EducationalMaterial({
    required this.type,
    required this.title,
    this.author,
    this.link,
    this.description,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'author': author,
      'link': link,
      'description': description,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory EducationalMaterial.fromMap(Map<String, dynamic> map) {
    return EducationalMaterial(
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      author: map['author'],
      link: map['link'],
      description: map['description'],
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  EducationalMaterial copyWith({
    String? type,
    String? title,
    String? author,
    String? link,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return EducationalMaterial(
      type: type ?? this.type,
      title: title ?? this.title,
      author: author ?? this.author,
      link: link ?? this.link,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class SubjectProgress {
  final int totalQuizzesTaken;
  final int totalQuestionsAnswered;
  final int correctAnswers;
  final double accuracyPercentage;
  final int studyTimeMinutes;
  final Map<String, QuizTypeProgress> quizTypeProgress;
  final DateTime? lastStudied;
  final int currentStreak;
  final int longestStreak;
  final List<QuizResult> recentQuizzes;

  SubjectProgress({
    this.totalQuizzesTaken = 0,
    this.totalQuestionsAnswered = 0,
    this.correctAnswers = 0,
    this.accuracyPercentage = 0.0,
    this.studyTimeMinutes = 0,
    this.quizTypeProgress = const {},
    this.lastStudied,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.recentQuizzes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'correctAnswers': correctAnswers,
      'accuracyPercentage': accuracyPercentage,
      'studyTimeMinutes': studyTimeMinutes,
      'quizTypeProgress':
      quizTypeProgress.map((key, value) => MapEntry(key, value.toMap())),
      'lastStudied': lastStudied != null ? Timestamp.fromDate(lastStudied!) : null,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'recentQuizzes': recentQuizzes.map((q) => q.toMap()).toList(),
    };
  }

  factory SubjectProgress.fromMap(Map<String, dynamic> map) {
    return SubjectProgress(
      totalQuizzesTaken: map['totalQuizzesTaken'] ?? 0,
      totalQuestionsAnswered: map['totalQuestionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      accuracyPercentage: (map['accuracyPercentage'] ?? 0.0).toDouble(),
      studyTimeMinutes: map['studyTimeMinutes'] ?? 0,
      quizTypeProgress: (map['quizTypeProgress'] as Map<String, dynamic>?)
          ?.map((key, value) =>
          MapEntry(key, QuizTypeProgress.fromMap(value))) ??
          {},
      lastStudied: map['lastStudied'] != null
          ? (map['lastStudied'] as Timestamp).toDate()
          : null,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      recentQuizzes: (map['recentQuizzes'] as List<dynamic>?)
          ?.map((q) => QuizResult.fromMap(q))
          .toList() ??
          [],
    );
  }

  SubjectProgress copyWith({
    int? totalQuizzesTaken,
    int? totalQuestionsAnswered,
    int? correctAnswers,
    double? accuracyPercentage,
    int? studyTimeMinutes,
    Map<String, QuizTypeProgress>? quizTypeProgress,
    DateTime? lastStudied,
    int? currentStreak,
    int? longestStreak,
    List<QuizResult>? recentQuizzes,
  }) {
    return SubjectProgress(
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      totalQuestionsAnswered:
      totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracyPercentage: accuracyPercentage ?? this.accuracyPercentage,
      studyTimeMinutes: studyTimeMinutes ?? this.studyTimeMinutes,
      quizTypeProgress: quizTypeProgress ?? this.quizTypeProgress,
      lastStudied: lastStudied ?? this.lastStudied,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      recentQuizzes: recentQuizzes ?? this.recentQuizzes,
    );
  }
}

class QuizTypeProgress {
  final String quizType;
  final int attemptedQuizzes;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final int bestScore;
  final DateTime? lastAttempted;

  QuizTypeProgress({
    required this.quizType,
    this.attemptedQuizzes = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.accuracy = 0.0,
    this.bestScore = 0,
    this.lastAttempted,
  });

  Map<String, dynamic> toMap() {
    return {
      'quizType': quizType,
      'attemptedQuizzes': attemptedQuizzes,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'bestScore': bestScore,
      'lastAttempted':
      lastAttempted != null ? Timestamp.fromDate(lastAttempted!) : null,
    };
  }

  factory QuizTypeProgress.fromMap(Map<String, dynamic> map) {
    return QuizTypeProgress(
      quizType: map['quizType'] ?? '',
      attemptedQuizzes: map['attemptedQuizzes'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      bestScore: map['bestScore'] ?? 0,
      lastAttempted: map['lastAttempted'] != null
          ? (map['lastAttempted'] as Timestamp).toDate()
          : null,
    );
  }
}

class QuizResult {
  final String quizId;
  final String quizType;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime completedAt;
  final int timeTakenMinutes;

  QuizResult({
    required this.quizId,
    required this.quizType,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.completedAt,
    required this.timeTakenMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'quizType': quizType,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'completedAt': Timestamp.fromDate(completedAt),
      'timeTakenMinutes': timeTakenMinutes,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      quizId: map['quizId'] ?? '',
      quizType: map['quizType'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      timeTakenMinutes: map['timeTakenMinutes'] ?? 0,
    );
  }
}