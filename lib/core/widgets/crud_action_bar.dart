import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import 'confirmation_dialogs.dart';

class CrudActionBar extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCreate;
  final bool showEdit;
  final bool showDelete;
  final bool showCreate;
  final bool isLoading;
  final String? entityName;
  final String? itemName;

  const CrudActionBar({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onCreate,
    this.showEdit = true,
    this.showDelete = true,
    this.showCreate = true,
    this.isLoading = false,
    this.entityName,
    this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    if (!showEdit && !showDelete && !showCreate) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (showCreate) _buildCreateButton(),
          if (showCreate && (showEdit || showDelete))
            const SizedBox(height: AppSpacing.md),
          if (showEdit || showDelete) _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onCreate,
        icon:
            isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.add, size: 20),
        label: Text('Create New ${entityName ?? 'Item'}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    final actions = <Widget>[];

    if (showEdit) {
      actions.add(
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onPressed: isLoading ? null : onEdit,
            color: AppTheme.warning,
            backgroundColor: AppTheme.warningLight,
          ),
        ),
      );
    }

    if (showEdit && showDelete) {
      actions.add(const SizedBox(width: AppSpacing.md));
    }

    if (showDelete) {
      actions.add(
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            onPressed: isLoading ? null : () => _showDeleteConfirmation(),
            color: AppTheme.error,
            backgroundColor: AppTheme.errorLight,
          ),
        ),
      );
    }

    return Row(children: actions);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final shouldDelete = await ConfirmationDialogs.showDeleteConfirmationDialog(
      entityName ?? 'Item',
      itemName ?? 'this item',
    );

    if (shouldDelete) {
      onDelete?.call();
    }
  }
}
