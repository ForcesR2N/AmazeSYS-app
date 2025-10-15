import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/warehouse_detail_model.dart';
import '../../core/theme/app_theme.dart';

class WarehouseDetailWidget extends StatelessWidget {
  final WarehouseDetail detail;

  const WarehouseDetailWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('warehouse-detail'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildDetailSections(),
      ),
    );
  }

  List<Widget> _buildDetailSections() {
    return [
      // Basic Warehouse Information
      _buildInfoSection(
        title: 'Information',
        icon: Icons.warehouse_outlined,
        color: AppTheme.warning,
        children: [
          _buildInfoRow('Name', detail.name),
          if (detail.codeId?.isNotEmpty == true)
            _buildInfoRow('Code', detail.codeId!),
          _buildInfoRow('Description', detail.description),
          if (detail.note?.isNotEmpty == true)
            _buildInfoRow('Notes', detail.note!),
        ],
      ),

      // Branch Information
      _buildInfoSection(
        title: 'Branch',
        icon: Icons.store_outlined,
        color: AppTheme.success,
        children: [_buildInfoRow('Branch ID', detail.branchId)],
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
          color: const Color(0xFF8B5CF6),
          children: [
            // Street Address (just address field)
            _buildInfoRow('Street Address', detail.streetAddress),

            // Full Address (complete with all location details)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Full Address',
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    detail.fullAddress,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppTheme.neutral800,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Location Details (collapsible/secondary info)
            if (detail.wardName?.isNotEmpty == true ||
                detail.subdistrictName?.isNotEmpty == true ||
                detail.districtName?.isNotEmpty == true ||
                detail.provinceName?.isNotEmpty == true)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Details',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppTheme.neutral500,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (detail.wardName?.isNotEmpty == true)
                        _buildLocationChip(
                          'Kel. ${detail.wardName}',
                          Icons.home_work_outlined,
                        ),
                      if (detail.subdistrictName?.isNotEmpty == true)
                        _buildLocationChip(
                          'Kec. ${detail.subdistrictName}',
                          Icons.location_city_outlined,
                        ),
                      if (detail.districtName?.isNotEmpty == true)
                        _buildLocationChip(
                          detail.districtName!,
                          Icons.domain_outlined,
                        ),
                      if (detail.provinceName?.isNotEmpty == true)
                        _buildLocationChip(
                          detail.provinceName!,
                          Icons.public_outlined,
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),

      // System Information
      _buildInfoSection(
        title: 'System Information',
        icon: Icons.info_outlined,
        color: AppTheme.neutral500,
        children: [
          _buildInfoRow('Warehouse ID', detail.id),
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}
