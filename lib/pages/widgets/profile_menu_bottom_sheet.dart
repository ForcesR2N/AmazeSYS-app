import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import 'logout_dialog.dart';

/// Bottom sheet showing user profile menu
class ProfileMenuBottomSheet extends StatelessWidget {
  const ProfileMenuBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildAvatar(authController),
                  const SizedBox(height: AppSpacing.md),
                  _buildUserName(authController),
                  const SizedBox(height: AppSpacing.xs),
                  _buildUsername(authController),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSignOutButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.neutral300,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  Widget _buildAvatar(AuthController authController) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: AppTheme.primarySurface,
      child: Text(
        _getUserInitial(authController),
        style: AppTypography.h3.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserName(AuthController authController) {
    return Obx(
      () => Text(
        authController.currentUser?.name ?? 'User',
        style: AppTypography.h4.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUsername(AuthController authController) {
    return Obx(
      () => Text(
        authController.currentUser?.username ?? '',
        style: AppTypography.bodyMedium.copyWith(
          color: AppTheme.neutral500,
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout_outlined),
        label: const Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }

  String _getUserInitial(AuthController authController) {
    final name = authController.currentUser?.name;
    if (name?.isNotEmpty == true) {
      return name!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogoutDialog(),
    );
  }
}
