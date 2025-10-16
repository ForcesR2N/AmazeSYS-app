import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import 'profile_menu_bottom_sheet.dart';

/// Custom app bar for home page with branding and profile button
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBranding(),
            _buildProfileButton(context, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMAZESYS',
          style: AppTypography.h3.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Management',
          style: AppTypography.bodySmall.copyWith(
            color: AppTheme.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton(
    BuildContext context,
    AuthController authController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => _showProfileMenu(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primarySurface,
              child: Text(
                _getUserInitial(authController),
                style: AppTypography.labelMedium.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileMenuBottomSheet(),
    );
  }
}
