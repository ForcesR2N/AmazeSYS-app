import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_form_controller.dart';
import '../../core/widgets/base_form_page.dart';
import '../../core/theme/app_theme.dart';

class ProductFormPage extends StatelessWidget {
  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormController>();

    return BaseFormPage(
      controller: controller,
      formFields: [
        // Basic Information Section
        _buildSectionHeader('Basic Information'),
        const SizedBox(height: AppSpacing.md),

        CustomFormField(
          label: 'Product Name',
          isRequired: true,
          child: TextFormField(
            controller: controller.nameController,
            decoration: buildInputDecoration(
              hintText: 'Enter product name',
              prefixIcon: Icons.inventory,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Product name is required';
              }
              if (value.trim().length < 2) {
                return 'Product name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),

        CustomFormField(
          label: 'Product Code',
          helperText: 'Unique identifier for the product (optional)',
          child: TextFormField(
            controller: controller.codeController,
            decoration: buildInputDecoration(
              hintText: 'Enter product code',
              prefixIcon: Icons.qr_code,
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
              hintText: 'Enter product description',
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

        const SizedBox(height: AppSpacing.lg),

        // Location Information Section
        _buildSectionHeader('Location Information'),
        const SizedBox(height: AppSpacing.md),

        CustomFormField(
          label: 'Warehouse',
          isRequired: true,
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedWarehouseId.value.isEmpty
                  ? null
                  : controller.selectedWarehouseId.value,
              decoration: buildInputDecoration(
                hintText: 'Select warehouse',
                prefixIcon: Icons.warehouse,
              ),
              items: controller.warehouses
                  .map(
                    (warehouse) => DropdownMenuItem<String>(
                      value: warehouse['id'].toString(),
                      child: Text(warehouse['name'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedWarehouseId.value = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Warehouse is required';
                }
                return null;
              },
            ),
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

        CustomFormField(
          label: 'Category',
          helperText: 'Product category (optional)',
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedCategoryId.value.isEmpty
                  ? null
                  : controller.selectedCategoryId.value,
              decoration: buildInputDecoration(
                hintText: 'Select category',
                prefixIcon: Icons.category,
              ),
              items: controller.categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category['id'].toString(),
                      child: Text(category['name'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.selectedCategoryId.value = value ?? '';
              },
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