import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

/// Logout confirmation dialog
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      title: Text(
        'Sign Out',
        style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
      ),
      content: Text(
        'Are you sure you want to sign out of your account?',
        style: AppTypography.bodyLarge.copyWith(
          color: AppTheme.neutral600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.neutral500,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: Text('Cancel', style: AppTypography.buttonMedium),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            authController.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text('Sign Out', style: AppTypography.buttonMedium),
        ),
      ],
    );
  }
}
