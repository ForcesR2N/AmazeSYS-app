import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/navigation_stack_manager.dart';
import '../../core/theme/app_theme.dart';
import '../models/list_item.dart';

class BreadcrumbWidget extends StatelessWidget {
  const BreadcrumbWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationStackManager navigationManager = Get.find<NavigationStackManager>();
    
    return Obx(() {
      final breadcrumbTexts = navigationManager.getBreadcrumbTexts();
      
      if (breadcrumbTexts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < breadcrumbTexts.length; i++) ...[
                _buildBreadcrumbItem(
                  breadcrumbTexts[i],
                  _getIconForIndex(i, navigationManager),
                  i == breadcrumbTexts.length - 1,
                ),
                if (i < breadcrumbTexts.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppTheme.neutral400,
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBreadcrumbItem(String text, IconData icon, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: isLast
          ? BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
                width: 1,
              ),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isLast ? AppTheme.primary : AppTheme.neutral500,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: isLast ? AppTheme.primary : AppTheme.neutral600,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index, NavigationStackManager navigationManager) {
    final pageStack = navigationManager.pageStack;
    final currentLevel = navigationManager.currentLevel;
    
    if (index < pageStack.length) {
      final page = pageStack[index];
      return page.selectedItem != null 
          ? _getIconForLevel(page.selectedItem!.level)
          : _getIconForLevel(page.level);
    } else if (currentLevel != null) {
      return _getIconForLevel(currentLevel);
    }
    
    return Icons.home_outlined;
  }

  IconData _getIconForLevel(ListLevel level) {
    switch (level) {
      case ListLevel.company:
        return Icons.business_outlined;
      case ListLevel.branch:
        return Icons.store_outlined;
      case ListLevel.warehouse:
        return Icons.warehouse_outlined;
      case ListLevel.product:
        return Icons.inventory_2_outlined;
    }
  }
}