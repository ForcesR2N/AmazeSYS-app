import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/company_form_controller.dart';
import '../models/company_detail_model.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/location_form_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/form_theme.dart';

class CompanyFormPage extends StatelessWidget {
  const CompanyFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanyFormController>();

    return BaseFormPage(
      controller: controller,
      formFields: [
        // Basic Information Section
        _buildSectionHeader('Basic Information'),
        const SizedBox(height: 10),

        CustomFormField(
          label: 'Company Name',
          isRequired: true,
          child: TextFormField(
            controller: controller.nameController,
            decoration: buildInputDecoration(
              hintText: 'Enter company name',
              prefixIcon: Icons.business,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Company name is required';
              }
              if (value.trim().length < 2) {
                return 'Company name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),

        CustomFormField(
          label: 'Company Code',
          isRequired: true,
          helperText: 'Unique identifier for the company',
          child: TextFormField(
            controller: controller.codeController,
            decoration: buildInputDecoration(
              hintText: 'Enter company code',
              prefixIcon: Icons.tag,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Company code is required';
              }
              if (value.trim().length < 2) {
                return 'Company code must be at least 2 characters';
              }
              return null;
            },
          ),
        ),

        CustomFormField(
          label: 'Description',
          isRequired: true,
          child: TextFormField(
            controller: controller.descriptionController,
            maxLines: 3,
            decoration: buildInputDecoration(
              hintText: 'Enter company description',
              prefixIcon: Icons.description,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
        ),

        CustomFormField(
          label: 'Category',
          isRequired: true,
          child: Obx(
            () => FormTheme.buildStyledDropdown<String>(
              value:
                  controller.selectedCategoryId.value.isEmpty
                      ? null
                      : controller.selectedCategoryId.value,
              hintText: 'Select category',
              prefixIcon: Icons.category,
              items:
                  controller.categories
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category['id'].toString(),
                          child: Text(
                            category['name'].toString(),
                            style: TextStyle(
                              color: AppTheme.neutral800,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCategoryId.value = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Location Information Section
        _buildSectionHeader('Location Information'),
        const SizedBox(height: AppSpacing.md),

        // Location form fields (province, district, subdistrict, ward, zipcode)
        LocationFormWidget(tag: 'company_location'),

        // Street Address Field
        CustomFormField(
          label: 'Street Address',
          helperText: 'Building number, street name, etc.',
          child: TextFormField(
            controller: controller.addressController,
            maxLines: 2,
            decoration: buildInputDecoration(
              hintText: 'Enter street address',
              prefixIcon: Icons.home,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Contact Information Section
        _buildSectionHeader('Contact Information'),
        const SizedBox(height: AppSpacing.md),

        CustomFormField(
          label: 'PIC Name',
          helperText: 'Person in Charge',
          child: TextFormField(
            controller: controller.picNameController,
            decoration: buildInputDecoration(
              hintText: 'Enter PIC name',
              prefixIcon: Icons.person,
            ),
          ),
        ),

        CustomFormField(
          label: 'PIC Contact',
          child: TextFormField(
            controller: controller.picContactController,
            keyboardType: TextInputType.phone,
            decoration: buildInputDecoration(
              hintText: 'Enter PIC contact number',
              prefixIcon: Icons.phone,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Additional Information Section
        _buildSectionHeader('Additional Information'),
        const SizedBox(height: AppSpacing.md),

        CustomFormField(
          label: 'Notes',
          child: TextFormField(
            controller: controller.noteController,
            maxLines: 3,
            decoration: buildInputDecoration(
              hintText: 'Enter additional notes',
              prefixIcon: Icons.note,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral800,
            ),
          ),
        ],
      ),
    );
  }
}
