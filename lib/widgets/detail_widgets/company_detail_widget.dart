import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/list_item.dart';
import '../../models/company_detail_model.dart';
import '../../services/company_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/skeleton_loader.dart';
import 'base_detail_widget.dart';

class CompanyDetailWidget extends BaseDetailWidget {
  const CompanyDetailWidget({super.key, required super.item});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CompanyDetail?>(
      future: CompanyService().getCompanyDetail(item.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final companyData = snapshot.data;
        if (companyData == null) {
          return _buildNoDataState();
        }

        return SingleChildScrollView(
          key: const ValueKey('company-detail'),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildDetailSections(companyData),
          ),
        );
      },
    );
  }

  @override
  List<Widget> buildDetailSections(BuildContext context) {
    // This won't be called directly since we override build()
    return [];
  }

  List<Widget> _buildDetailSections(CompanyDetail companyData) {
    return [
      // Basic Company Information
      buildInfoSection(
        title: 'Company Information',
        icon: Icons.business_outlined,
        color: AppTheme.primary,
        children: [
          buildInfoRow('Company Name', companyData.name),
          buildInfoRow('Company Code', companyData.code),
          buildInfoRow('Description', companyData.description),
          buildInfoRow('Category', companyData.categoryName ?? 'Not specified'),
          if (companyData.note?.isNotEmpty == true)
            buildInfoRow('Notes', companyData.note!),
        ],
      ),

      // Address & Location Information  
      if (_hasLocationInfo(companyData))
        buildInfoSection(
          title: 'Address & Location',
          icon: Icons.location_on_outlined,
          color: AppTheme.success,
          children: [
            if (companyData.address?.isNotEmpty == true)
              buildInfoRow('Street Address', companyData.address!),
            if (companyData.wardName?.isNotEmpty == true)
              buildInfoRow('Ward (Kelurahan)', companyData.wardName!),
            if (companyData.subdistrictName?.isNotEmpty == true)
              buildInfoRow('Subdistrict (Kecamatan)', companyData.subdistrictName!),
            if (companyData.districtName?.isNotEmpty == true)
              buildInfoRow('District (Kabupaten/Kota)', companyData.districtName!),
            if (companyData.provinceName?.isNotEmpty == true)
              buildInfoRow('Province', companyData.provinceName!),
            if (companyData.zipcode?.isNotEmpty == true)
              buildInfoRow('Postal Code', companyData.zipcode!),
            if (companyData.fullAddress.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppTheme.success.withOpacity(0.3),
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
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Full Address',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      companyData.fullAddress,
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

      // Contact Information (PIC)
      if (_hasContactInfo(companyData))
        buildInfoSection(
          title: 'Contact Information',
          icon: Icons.contact_phone_outlined,
          color: AppTheme.info,
          children: [
            if (companyData.picName?.isNotEmpty == true)
              buildInfoRow('Person in Charge', companyData.picName!),
            if (companyData.picContact?.isNotEmpty == true)
              buildInfoRow('Contact Number', companyData.picContact!),
          ],
        ),

      // System Information
      buildInfoSection(
        title: 'System Information',
        icon: Icons.info_outlined,
        color: AppTheme.neutral500,
        children: [
          buildInfoRow('Company ID', companyData.id),
          if (companyData.createdAt != null)
            buildInfoRow('Created Date', _formatDateTime(companyData.createdAt!)),
          if (companyData.updatedAt != null)
            buildInfoRow('Last Updated', _formatDateTime(companyData.updatedAt!)),
        ],
      ),
    ];
  }

  Widget _buildLoadingState() {
    return Container(
      key: const ValueKey('company-loading'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          SkeletonLoader.detailCardSkeleton(),
          const SizedBox(height: AppSpacing.lg),
          SkeletonLoader.detailCardSkeleton(),
          const SizedBox(height: AppSpacing.lg),
          SkeletonLoader.detailCardSkeleton(),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      key: const ValueKey('company-error'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to Load Company Details',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unable to fetch company information from server',
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      key: const ValueKey('company-no-data'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                Icons.business_outlined,
                size: 40,
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Company Details Not Available',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Company information is not available at this time',
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _hasLocationInfo(CompanyDetail companyData) {
    return (companyData.address?.isNotEmpty == true) ||
           (companyData.wardName?.isNotEmpty == true) ||
           (companyData.subdistrictName?.isNotEmpty == true) ||
           (companyData.districtName?.isNotEmpty == true) ||
           (companyData.provinceName?.isNotEmpty == true) ||
           (companyData.zipcode?.isNotEmpty == true);
  }

  bool _hasContactInfo(CompanyDetail companyData) {
    return (companyData.picName?.isNotEmpty == true) || 
           (companyData.picContact?.isNotEmpty == true);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
}