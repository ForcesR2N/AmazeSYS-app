import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/branch_detail_model.dart';
import '../../core/theme/app_theme.dart';

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
        children: _buildDetailSections(),
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
        ],
      ),

      // Company Information
      _buildInfoSection(
        title: 'Company',
        icon: Icons.business_outlined,
        color: AppTheme.primary,
        children: [
          _buildInfoRow('Company ID', detail.companyId),
        ],
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

      // Address Information  
      if (_hasLocationInfo())
        _buildInfoSection(
          title: 'Address',
          icon: Icons.location_on_outlined,
          color: AppTheme.warning,
          children: [
            if (detail.address?.isNotEmpty == true)
              _buildInfoRow('Street Address', detail.address!),
            if (detail.wardName?.isNotEmpty == true)
              _buildInfoRow('Ward (Kelurahan)', detail.wardName!),
            if (detail.subdistrictName?.isNotEmpty == true)
              _buildInfoRow('Subdistrict (Kecamatan)', detail.subdistrictName!),
            if (detail.districtName?.isNotEmpty == true)
              _buildInfoRow('District (Kabupaten/Kota)', detail.districtName!),
            if (detail.provinceName?.isNotEmpty == true)
              _buildInfoRow('Province', detail.provinceName!),
            if (detail.fullAddress.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppTheme.warning.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Full Address',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      detail.fullAddress,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppTheme.neutral800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
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
              color: value.isNotEmpty ? AppTheme.neutral900 : AppTheme.neutral400,
              height: 1.6,
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}