import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? progress;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.isEmailVerified = false,
    this.preferences,
    this.progress,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isEmailVerified': isEmailVerified,
      'preferences': preferences ?? {},
      'progress': progress ?? {
        'totalQuizzesTaken': 0,
        'totalQuestionsAnswered': 0,
        'correctAnswers': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'totalStudyTime': 0, // in minutes
      },
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp).toDate(),
      isEmailVerified: map['isEmailVerified'] ?? false,
      preferences: map['preferences'],
      progress: map['progress'],
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? progress,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      progress: progress ?? this.progress,
    );
  }
}