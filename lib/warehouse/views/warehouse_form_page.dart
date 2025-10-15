import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/warehouse_form_controller.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/widgets/location_form_widget.dart';
import '../../core/theme/app_theme.dart';

class WarehouseFormPage extends StatelessWidget {
  const WarehouseFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WarehouseFormController>();

    return BaseFormPage(
      controller: controller,
      formFields: [
        // Basic Information Section
        _buildSectionHeader('Basic Information'),
        const SizedBox(height: AppSpacing.md),

        CustomFormField(
          label: 'Warehouse Name',
          isRequired: true,
          child: TextFormField(
            controller: controller.nameController,
            decoration: buildInputDecoration(
              hintText: 'Enter warehouse name',
              prefixIcon: Icons.warehouse,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Warehouse name is required';
              }
              if (value.trim().length < 2) {
                return 'Warehouse name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),

        CustomFormField(
          label: 'Warehouse Code',
          helperText: 'Unique identifier for the warehouse (optional)',
          child: TextFormField(
            controller: controller.codeController,
            decoration: buildInputDecoration(
              hintText: 'Enter warehouse code',
              prefixIcon: Icons.tag,
            ),
          ),
        ),

        CustomFormField(
          label: 'Description',
          isRequired: true,
          child: TextFormField(
            controller: controller.descriptionController,
            maxLines: 3,
            decoration: buildInputDecoration(
              hintText: 'Enter warehouse description',
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
          label: 'Branch',
          isRequired: true,
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedBranchId.value.isEmpty
                  ? null
                  : controller.selectedBranchId.value,
              decoration: buildInputDecoration(
                hintText: 'Select branch',
                prefixIcon: Icons.business,
              ),
              items: controller.branches
                  .map(
                    (branch) => DropdownMenuItem<String>(
                      value: branch['id'].toString(),
                      child: Text(branch['name'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedBranchId.value = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Branch is required';
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
        LocationFormWidget(tag: 'warehouse_location'),

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