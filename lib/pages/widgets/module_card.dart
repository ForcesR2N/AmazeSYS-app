import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_pages.dart';
import '../models/home_menu_item.dart';

/// Individual module card widget with animation
class ModuleCard extends StatelessWidget {
  final HomeMenuItem item;
  final int index;

  const ModuleCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: _buildCard(context),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.lg),
                _buildTitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: _buildIcon(),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildCountBadge(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(
        item.icon,
        color: item.color,
        size: 24,
      ),
    );
  }

  Widget _buildCountBadge() {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 32,
        maxWidth: 60,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Text(
        item.formattedCount,
        style: AppTypography.labelSmall.copyWith(
          color: AppTheme.neutral600,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildTitle() {
    return Flexible(
      child: Text(
        item.name,
        style: AppTypography.h4.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _handleTap() {
    Get.toNamed(Routes.CATEGORY_LIST, arguments: item.level);
  }
}
