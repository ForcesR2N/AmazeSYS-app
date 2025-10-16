import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../models/branch_detail_model.dart';
import '../services/branch_service.dart';
import '../controllers/branch_form_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/crud_action_bar.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../list-pages/controllers/list_controller.dart';

class BranchDetailWidget extends StatelessWidget {
  final BranchDetail detail;

  const BranchDetailWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('branch-detail'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [..._buildDetailSections(), _buildCrudActions()],
      ),
    );
  }

  List<Widget> _buildDetailSections() {
    return [
      // Basic Branch Information
      _buildInfoSection(
        title: 'Information',
        icon: Icons.store_outlined,
        color: AppTheme.success,
        children: [
          _buildInfoRow('Name', detail.name),
          if (detail.codeId?.isNotEmpty == true)
            _buildInfoRow('Code', detail.codeId!),
          _buildInfoRow('Description', detail.description),
          if (detail.note?.isNotEmpty == true)
            _buildInfoRow('Notes', detail.note!),
          _buildInfoRow('Street Address', detail.fullAddress),
        ],
      ),

      // Company Information
      _buildInfoSection(
        title: 'Company',
        icon: Icons.business_outlined,
        color: AppTheme.primary,
        children: [_buildInfoRow('Company ID', detail.companyId)],
      ),

      // Contact Information
      if (_hasContactInfo())
        _buildInfoSection(
          title: 'Contact Information',
          icon: Icons.contact_phone_outlined,
          color: AppTheme.info,
          children: [
            if (detail.picName?.isNotEmpty == true)
              _buildInfoRow('Person in Charge', detail.picName!),
            if (detail.picContact?.isNotEmpty == true)
              _buildInfoRow('Contact Number', detail.picContact!),
          ],
        ),

      // System Information
      _buildInfoSection(
        title: 'System Information',
        icon: Icons.info_outlined,
        color: AppTheme.neutral500,
        children: [
          _buildInfoRow('Branch ID', detail.id),
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
              color:
                  value.isNotEmpty ? AppTheme.neutral900 : AppTheme.neutral400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build location chips
  Widget _buildLocationChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppTheme.neutral300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.neutral600),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.neutral700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasLocationInfo() {
    return (detail.address?.isNotEmpty == true) ||
        (detail.wardName?.isNotEmpty == true) ||
        (detail.subdistrictName?.isNotEmpty == true) ||
        (detail.districtName?.isNotEmpty == true) ||
        (detail.provinceName?.isNotEmpty == true);
  }

  bool _hasContactInfo() {
    return (detail.picName?.isNotEmpty == true) ||
        (detail.picContact?.isNotEmpty == true);
  }

  Widget _buildCrudActions() {
    return CrudActionBar(
      entityName: 'Branch',
      itemName: detail.name,
      onEdit: () => _handleEdit(),
      onDelete: () => _handleDelete(),
      showCreate: false,
    );
  }

  void _handleEdit() async {
    if (Get.isRegistered<BranchFormController>()) {
      Get.delete<BranchFormController>();
    }

    final result = await Get.toNamed(
      '/branch-form',
      arguments: {'branch': detail},
    );

    // If branch was updated successfully, show feedback and refresh
    if (result == true) {
      CustomSnackbar.success(
        message: 'Branch information has been updated successfully',
      );

      // Refresh the current view to show updated data
      try {
        final listController = Get.find<ListController>();
        await listController.refresh();
      } catch (e) {
        // List controller not found, that's okay
      }
    }
  }

  Future<void> _handleDelete() async {
    try {
      final branchService = Get.find<BranchService>();
      final success = await branchService.deleteBranch(detail.id);

      if (success) {
        // Show success feedback
        CustomSnackbar.success(
          message: '${detail.name} has been deleted successfully',
        );

        // Handle post-delete navigation and refresh
        try {
          final listController = Get.find<ListController>();
          await listController.handleDataModification(itemDeleted: true);
        } catch (e) {
          // If list controller not found, just go back
          Get.back(result: true);
        }
      }
    } catch (e) {
      CustomSnackbar.error(message: 'Failed to delete branch: ${e.toString()}');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}
