import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomToast {
  static void show({
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.rawSnackbar(
      messageText: _ToastContent(
        message: message,
        type: type,
      ),
      backgroundColor: Colors.transparent,
      duration: duration,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      animationDuration: const Duration(milliseconds: 400),
      snackPosition: SnackPosition.TOP,
    );
  }

  static void success(String message) {
    show(message: message, type: ToastType.success);
  }

  static void error(String message) {
    show(message: message, type: ToastType.error);
  }

  static void info(String message) {
    show(message: message, type: ToastType.info);
  }

  static void warning(String message) {
    show(message: message, type: ToastType.warning);
  }
}

enum ToastType {
  success,
  error,
  info,
  warning,
}

class _ToastContent extends StatelessWidget {
  final String message;
  final ToastType type;

  const _ToastContent({
    required this.message,
    required this.type,
  });

  Color get _backgroundColor {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF10B981);
      case ToastType.error:
        return const Color(0xFFEF4444);
      case ToastType.info:
        return const Color(0xFF2196F3);
      case ToastType.warning:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get _icon {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
    }
  }

  String get _title {
    switch (type) {
      case ToastType.success:
        return 'Success';
      case ToastType.error:
        return 'Error';
      case ToastType.info:
        return 'Info';
      case ToastType.warning:
        return 'Warning';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _backgroundColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _backgroundColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _backgroundColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _icon,
              color: _backgroundColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}