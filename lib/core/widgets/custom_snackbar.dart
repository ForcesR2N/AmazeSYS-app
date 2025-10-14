import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    Get.rawSnackbar(
      titleText: _buildTitle(title, type),
      messageText: _buildMessage(message),
      backgroundColor: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: duration,
      snackPosition: SnackPosition.TOP,
      onTap: onTap != null ? (_) => onTap() : null,
      overlayBlur: 0,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
      borderColor: const Color(0xFFE5E7EB),
      borderWidth: 1,
      snackbarStatus: (status) {
        if (status == SnackbarStatus.OPENING) {
          // Add haptic feedback for professional feel
          // HapticFeedback.lightImpact();
        }
      },
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      mainButton: _buildCloseButton(),
    );
  }

  static Widget _buildTitle(String title, SnackbarType type) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _getTypeColor(type),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          _getTypeIcon(type),
          color: _getTypeColor(type),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937), // Gray-800
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 8, top: 4),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280), // Gray-500
          height: 1.4,
        ),
      ),
    );
  }

  static Widget _buildCloseButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Gray-100
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: () => Get.closeCurrentSnackbar(),
        borderRadius: BorderRadius.circular(6),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.close,
            size: 16,
            color: Color(0xFF6B7280), // Gray-500
          ),
        ),
      ),
    );
  }

  static Color _getTypeColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF059669); // Emerald-600
      case SnackbarType.error:
        return const Color(0xFFDC2626); // Red-600
      case SnackbarType.warning:
        return const Color(0xFFD97706); // Amber-600
      case SnackbarType.info:
        return const Color(0xFF2563EB); // Blue-600
    }
  }

  static IconData _getTypeIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_outlined;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  // Convenience methods for specific types
  static void success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  static void error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  static void warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  static void info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      onTap: onTap,
    );
  }
}

// Custom snackbar widget for more complex layouts
class SnackbarContent extends StatelessWidget {
  final String title;
  final String message;
  final SnackbarType type;
  final Widget? action;

  const SnackbarContent({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 0),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5E7EB), // Gray-200
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: CustomSnackbar._getTypeColor(type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            CustomSnackbar._getTypeIcon(type),
            color: CustomSnackbar._getTypeColor(type),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937), // Gray-800
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280), // Gray-500
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            action!,
          ],
          const SizedBox(width: 8),
          InkWell(
            onTap: () => Get.closeCurrentSnackbar(),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // Gray-50
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Color(0xFF6B7280), // Gray-500
              ),
            ),
          ),
        ],
      ),
    );
  }
}