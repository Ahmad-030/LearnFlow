import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/UserModel.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create user document in Firestore
  static Future<void> createUserDocument(User user, String fullName) async {
    final userModel = UserModel(
      uid: user.uid,
      fullName: fullName,
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isEmailVerified: user.emailVerified,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
  }

  // Update user document
  static Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update(data);
  }

  // Get user document
  static Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  // Update last login time
  static Future<void> updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': Timestamp.now(),
    });
  }

  // Update user progress
  static Future<void> updateUserProgress(String uid, Map<String, dynamic> progressData) async {
    await _firestore.collection('users').doc(uid).update({
      'progress': progressData,
    });
  }

  // Update user preferences
  static Future<void> updateUserPreferences(String uid, Map<String, dynamic> preferences) async {
    await _firestore.collection('users').doc(uid).update({
      'preferences': preferences,
    });
  }

  // Delete user account
  static Future<void> deleteUserAccount(String uid) async {
    // Delete user document from Firestore
    await _firestore.collection('users').doc(uid).delete();

    // Delete user from Firebase Auth
    await currentUser?.delete();
  }

  // Stream user document
  static Stream<UserModel?> streamUserDocument(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Check if user document exists
  static Future<bool> userDocumentExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }
}