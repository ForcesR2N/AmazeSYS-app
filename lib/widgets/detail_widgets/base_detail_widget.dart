import 'package:flutter/material.dart';
import '../../models/list_item.dart';
import '../../core/theme/app_theme.dart';

/// Base interface for all detail widgets
/// Ensures consistent implementation across different categories
abstract class BaseDetailWidget extends StatelessWidget {
  final ListItem item;
  
  const BaseDetailWidget({super.key, required this.item});

  /// Each detail widget must implement buildDetailSections
  /// This returns the specific sections for that category type
  List<Widget> buildDetailSections(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('detail'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildDetailSections(context),
      ),
    );
  }

  /// Helper method to build consistent info sections
  Widget buildInfoSection({
    required String title,
    required List<Widget> children,
    IconData? icon,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color ?? AppTheme.neutral600),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              title.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: AppTheme.neutral600,
                fontSize: 12,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Helper method to build consistent info rows
  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppTheme.neutral500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value.isNotEmpty ? value : 'Not specified',
            style: AppTypography.bodyMedium.copyWith(
              color: value.isNotEmpty ? AppTheme.neutral900 : AppTheme.neutral400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}