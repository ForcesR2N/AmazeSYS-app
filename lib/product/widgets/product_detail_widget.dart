import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_detail_model.dart';
import '../../core/theme/app_theme.dart';

class ProductDetailWidget extends StatelessWidget {
  final ProductDetail detail;
  
  const ProductDetailWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('product-detail'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildDetailSections(),
      ),
    );
  }

  List<Widget> _buildDetailSections() {
    return [
      // Basic Product Information
      _buildInfoSection(
        title: 'Information',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF8B5CF6),
        children: [
          _buildInfoRow('Name', detail.name),
          if (detail.codeId?.isNotEmpty == true)
            _buildInfoRow('Code', detail.codeId!),
          _buildInfoRow('Description', detail.description),
          if (detail.note?.isNotEmpty == true)
            _buildInfoRow('Notes', detail.note!),
        ],
      ),

      // Category Information
      if (detail.categoryName?.isNotEmpty == true)
        _buildInfoSection(
          title: 'Category',
          icon: Icons.category_outlined,
          color: AppTheme.warning,
          children: [
            _buildInfoRow('Category', detail.categoryName!),
          ],
        ),

      // Location Information
      _buildInfoSection(
        title: 'Location',
        icon: Icons.location_on_outlined,
        color: AppTheme.success,
        children: [
          _buildInfoRow('Warehouse ID', detail.warehouseId),
          _buildInfoRow('Branch ID', detail.branchId),
        ],
      ),

      // System Information
      _buildInfoSection(
        title: 'System Information',
        icon: Icons.info_outlined,
        color: AppTheme.neutral500,
        children: [
          _buildInfoRow('Product ID', detail.id),
          if (detail.createdAt != null)
            _buildInfoRow('Created Date', _formatDateTime(detail.createdAt!)),
          if (detail.updatedAt != null)
            _buildInfoRow('Last Updated', _formatDateTime(detail.updatedAt!)),
        ],
      ),
    ];
  }

  /// Helper method to build consistent info sections
  Widget _buildInfoSection({
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
  Widget _buildInfoRow(String label, String value) {
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}