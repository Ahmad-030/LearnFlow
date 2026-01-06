import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;

  // Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // firebaseUser.bindStream(_auth.authStateChanges());
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
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

      // Firebase Sign Up (Commented)
      /*
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(fullName.trim());

      // Send email verification
      await userCredential.user?.sendEmailVerification();
      */

      // Success
      Get.offAllNamed('/home'); // Navigate to home
      CustomToast.success('Account created successfully! Welcome to LearnFlow.');
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

      // Firebase Login (Commented)
      /*
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      */

      // Success
      Get.offAllNamed('/home'); // Navigate to home
      CustomToast.success('Welcome back to LearnFlow!');
    } catch (e) {
      CustomToast.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Google Sign In (Commented)
      /*
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      */

      // Success
      // Get.offAllNamed('/home'); // Navigate to home
      // CustomToast.success('Signed in with Google successfully!');
    } catch (e) {
      CustomToast.error('Google sign-in failed: ${e.toString()}');
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

      // Firebase Password Reset (Commented)
      /*
      await _auth.sendPasswordResetEmail(email: email.trim());
      */

      // Success
      CustomToast.success('Password reset email sent! Check your inbox.');
      Get.back(); // Go back to login
    } catch (e) {
      CustomToast.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Firebase Sign Out (Commented)
      /*
      await _auth.signOut();
      await _googleSignIn.signOut();
      */

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

// Import this in your screens
class CustomToast {
  static void success(String message) {
    // Implementation from custom_toast.dart
  }

  static void error(String message) {
    // Implementation from custom_toast.dart
  }

  static void info(String message) {
    // Implementation from custom_toast.dart
  }
}