import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Model/SubjectModel.dart';
import '../../../Services/SubjectProgressService.dart';

class SubjectDetailController extends GetxController with GetSingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late SubjectModel subject;
  final Rx<SubjectProgress?> progress = Rx<SubjectProgress?>(null);
  final RxBool isLoading = true.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    subject = Get.arguments as SubjectModel;
    tabController = TabController(length: 3, vsync: this);
    _loadProgress();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> _loadProgress() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final subjectProgress = await SubjectProgressService.getSubjectProgress(
          user.uid,
          subject.id,
        );
        progress.value = subjectProgress;
      }
    } catch (e) {
      print('Error loading progress: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Public method to refresh progress from outside
  Future<void> refreshProgress() async {
    await _loadProgress();
  }

  Future<void> openLink(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Error',
        'No link available for this material',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    try {
      // Clean and validate the URL
      String cleanUrl = url.trim();

      // Add https:// if no protocol is specified
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);

      // Check if URL is valid
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw Exception('Invalid URL format');
      }

      // Check if it's a homepage/generic link
      final isGenericLink = uri.path == '/' || uri.path.isEmpty;

      // Try to launch the URL
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          // Show info if it's a generic/homepage link
          if (isGenericLink) {
            await Future.delayed(const Duration(milliseconds: 500));
            Get.snackbar(
              'Info',
              'Opened homepage. You may need to search for the specific resource.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF3B82F6),
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
          }
        } else {
          throw Exception('Failed to launch URL');
        }
      } else {
        throw Exception('Cannot launch this type of URL');
      }
    } catch (e) {
      print('Error opening link: $e');
      print('URL attempted: $url');

      // Show user-friendly error message
      Get.snackbar(
        'Unable to Open Link',
        'Could not open this link. Please check your internet connection or try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        mainButton: TextButton(
          onPressed: () {
            Get.back();
            // Copy URL to clipboard as fallback
            _showUrlInDialog(url);
          },
          child: const Text(
            'View URL',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showUrlInDialog(String url) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Resource URL',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SelectableText(
          url,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF3B82F6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openLink(url);
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.inter(
                color: getColorFromHex(subject.color),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}