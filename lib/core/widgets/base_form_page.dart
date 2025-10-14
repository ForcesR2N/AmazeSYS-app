import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import 'confirmation_dialogs.dart';
import 'custom_snackbar.dart';

abstract class BaseFormController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasUnsavedChanges = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  bool get isEditMode;
  String get pageTitle;
  String get entityName;
  
  Future<void> saveData();
  void resetForm();
  bool validateForm() => formKey.currentState?.validate() ?? false;
  
  // Track form changes for unsaved warning
  void markFormAsDirty() {
    hasUnsavedChanges.value = true;
  }
  
  void markFormAsClean() {
    hasUnsavedChanges.value = false;
  }
  
  // Get validation errors for display
  List<String> getValidationErrors();
}

class BaseFormPage extends StatelessWidget {
  final BaseFormController controller;
  final List<Widget> formFields;
  final Widget? additionalActions;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  const BaseFormPage({
    super.key,
    required this.controller,
    required this.formFields,
    this.additionalActions,
    this.onCancel,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.hasUnsavedChanges.value) {
          return await ConfirmationDialogs.showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.surfaceVariant,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildFormContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppTheme.surface,
      surfaceTintColor: AppTheme.surface,
      elevation: 0,
      shadowColor: AppTheme.shadowLight,
      leading: Container(
        margin: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => _handleBackPress(),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppTheme.neutral700,
            ),
          ),
        ),
      ),
      title: Obx(() {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                controller.isEditMode ? Icons.edit : Icons.add,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.pageTitle,
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral900,
                    ),
                  ),
                  if (controller.isLoading.value)
                    Text(
                      'Saving...',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppTheme.neutral500,
                      ),
                    ),
                ],
              ),
            ),
            if (controller.isLoading.value)
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(left: AppSpacing.sm),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildFormContent() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildActionButtons(),
              if (additionalActions != null) ...[
                const SizedBox(height: AppSpacing.lg),
                additionalActions!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: controller.isEditMode 
                      ? AppTheme.warning.withOpacity(0.1)
                      : AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  controller.isEditMode ? Icons.edit : Icons.add,
                  color: controller.isEditMode ? AppTheme.warning : AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.isEditMode ? 'Edit' : 'Create'} ${controller.entityName}',
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutral900,
                      ),
                    ),
                    if (controller.isEditMode)
                      Text(
                        'Update existing information',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return Column(
                children: [
                  _buildErrorAlert(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          ...formFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: field,
              )),
        ],
      ),
    );
  }

  Widget _buildErrorAlert() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.errorLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      return Row(
        children: [
          if (showCancelButton) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: controller.isLoading.value ? null : _handleCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.neutral600,
                  side: BorderSide(color: AppTheme.border, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: showCancelButton ? 1 : 2,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(controller.isEditMode ? 'Update' : 'Create'),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _handleBackPress() async {
    if (controller.hasUnsavedChanges.value) {
      final shouldLeave = await ConfirmationDialogs.showUnsavedChangesDialog();
      if (shouldLeave) {
        if (onCancel != null) {
          onCancel!();
        } else {
          Get.back();
        }
      }
    } else {
      if (onCancel != null) {
        onCancel!();
      } else {
        Get.back();
      }
    }
  }

  Future<void> _handleCancel() async {
    await _handleBackPress();
  }

  Future<void> _handleSave() async {
    if (controller.validateForm()) {
      // Check for required field validation
      final validationErrors = controller.getValidationErrors();
      if (validationErrors.isNotEmpty) {
        ConfirmationDialogs.showValidationErrorDialog(validationErrors);
        return;
      }

      controller.errorMessage.value = '';
      
      // Show confirmation for update operations
      if (controller.isEditMode) {
        final shouldUpdate = await ConfirmationDialogs.showUpdateConfirmationDialog(
          controller.entityName,
        );
        if (!shouldUpdate) return;
      }

      await controller.saveData();
    } else {
      // Show specific validation errors
      final validationErrors = controller.getValidationErrors();
      if (validationErrors.isNotEmpty) {
        ConfirmationDialogs.showValidationErrorDialog(validationErrors);
      }
    }
  }
}

class CustomFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;
  final String? helperText;

  const CustomFormField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.labelMedium.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helperText!,
            style: AppTypography.bodySmall.copyWith(
              color: AppTheme.neutral500,
            ),
          ),
        ],
      ],
    );
  }
}

InputDecoration buildInputDecoration({
  required String hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: AppTheme.neutral400,
    ),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: AppTheme.neutral400, size: 20)
        : null,
    suffixIcon: suffixIcon,
    errorText: errorText,
    filled: true,
    fillColor: AppTheme.surfaceContainer,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: AppTheme.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: AppTheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: AppTheme.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: AppTheme.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
  );
}