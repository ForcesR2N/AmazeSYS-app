import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TablePage extends StatelessWidget {
  const TablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Tables',
                  style: AppTypography.h3.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'View and manage data',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppTheme.neutral500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Icon(
                Icons.filter_list_outlined,
                color: AppTheme.neutral600,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                Icons.table_chart_outlined,
                size: 64,
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Data Available',
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tables and data will appear here once configured.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                // Future implementation
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Data Source'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}