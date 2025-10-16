import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../models/company_detail_model.dart';
import '../services/company_service.dart';
import '../controllers/company_form_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/crud_action_bar.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../list-pages/widgets/detail_widgets/base_detail_widget.dart';
import '../../list-pages/controllers/list_controller.dart';

class CompanyDetailWidget extends StatelessWidget {
  final CompanyDetail detail;

  const CompanyDetailWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('company-detail'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [..._buildDetailSections(), _buildCrudActions()],
      ),
    );
  }

  Widget _buildCrudActions() {
    return CrudActionBar(
      entityName: 'Company',
      itemName: detail.name,
      onEdit: () => _handleEdit(),
      onDelete: () => _handleDelete(),
      showCreate: false,
    );
  }

  void _handleEdit() async {
    if (Get.isRegistered<CompanyFormController>()) {
      Get.delete<CompanyFormController>();
    }

    final result = await Get.toNamed(
      '/company-form',
      arguments: {'company': detail},
    );

    // If company was updated successfully, show feedback and refresh
    if (result == true) {
      CustomSnackbar.success(
        message: 'Company information has been updated successfully',
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
      final companyService = Get.find<CompanyService>();
      final success = await companyService.deleteCompany(detail.id);

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
      CustomSnackbar.error(
        message: 'Failed to delete company: ${e.toString()}',
      );
    }
  }

  List<Widget> _buildDetailSections() {
    return [
      // Basic Company Information
      _buildInfoSection(
        title: 'Information',
        icon: Icons.business_outlined,
        color: AppTheme.primary,
        children: [
          _buildInfoRow('Name', detail.name),
          _buildInfoRow('Code', detail.code),
          _buildInfoRow('Description', detail.description),
          _buildInfoRow('Category', detail.categoryName ?? detail.categoryId),
          if (detail.note?.isNotEmpty == true)
            _buildInfoRow('Notes', detail.note!),
          _buildInfoRow('Street Address', detail.fullAddress),
          _buildInfoRow('Postal Code', detail.zipcode ?? 'Not specified'),
        ],
      ),

      // Contact Information (PIC)
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
          _buildInfoRow('Company ID', detail.id),
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
        (detail.provinceName?.isNotEmpty == true) ||
        (detail.zipcode?.isNotEmpty == true);
  }

  bool _hasContactInfo() {
    return (detail.picName?.isNotEmpty == true) ||
        (detail.picContact?.isNotEmpty == true);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}
