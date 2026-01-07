import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/Firebase_Service.dart';
import '../../Widgets/Custom_Toast.dart';


class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    _loadRememberMePreference();
  }

  // Load remember me preference
  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool('rememberMe') ?? false;
  }

  // Save remember me preference
  Future<void> _saveRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', rememberMe.value);
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    _saveRememberMePreference();
  }

  // Email & Password Sign Up
  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Validation
      if (fullName.trim().isEmpty) {
        throw 'Please enter your full name';
      }
      if (!GetUtils.isEmail(email)) {
        throw 'Please enter a valid email';
      }
      if (password.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(fullName.trim());

      // Create user document in Firestore
      if (userCredential.user != null) {
        await FirebaseService.createUserDocument(
          userCredential.user!,
          fullName.trim(),
        );
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Success
      Get.offAllNamed('/enrollment'); // Navigate to home
      CustomToast.success(
        'Account created successfully! Please check your email for verification.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign up';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
      }

      CustomToast.error(errorMessage);
    } catch (e) {
      CustomToast.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Email & Password Login
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Validation
      if (!GetUtils.isEmail(email)) {
        throw 'Please enter a valid email';
      }
      if (password.isEmpty) {
        throw 'Please enter your password';
      }

      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update last login time in Firestore
      if (userCredential.user != null) {
        await FirebaseService.updateLastLogin(userCredential.user!.uid);
      }

      // Success
      Get.offAllNamed('/enrollment'); // Navigate to home
      CustomToast.success('Welcome back to LearnFlow!');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
      }

      CustomToast.error(errorMessage);
    } catch (e) {
      CustomToast.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  // Password Reset
  Future<void> resetPassword({required String email}) async {
    try {
      isLoading.value = true;

      // Validation
      if (!GetUtils.isEmail(email)) {
        throw 'Please enter a valid email';
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email.trim());

      // Success
      CustomToast.success('Password reset email sent! Check your inbox.');
      Get.back(); // Go back to login
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Password reset failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
      }

      CustomToast.error(errorMessage);
    } catch (e) {
      CustomToast.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      Get.offAllNamed('/login'); // Navigate to login
      CustomToast.info('Signed out successfully');
    } catch (e) {
      CustomToast.error('Sign out failed: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}