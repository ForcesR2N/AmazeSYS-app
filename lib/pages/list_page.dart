import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_controller.dart';
import '../models/list_item.dart';
import '../models/list_arguments.dart';
import '../models/company_detail_model.dart';
import '../models/branch_detail_model.dart';
import '../models/warehouse_detail_model.dart';
import '../widgets/skeleton_loader.dart';
import '../core/theme/app_theme.dart';
import '../widgets/detail_widgets/company_detail_widget.dart';
import '../widgets/detail_widgets/branch_detail_widget.dart';
import '../widgets/detail_widgets/warehouse_detail_widget.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ListController controller = Get.find<ListController>();
    final TextEditingController searchController = TextEditingController();

    // Initialize page on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ListArguments.fromMap(Get.arguments as Map<String, dynamic>);
      if (args.parentItem != null) {
        controller.loadItemWithChildren(args.parentItem!);
      } else {
        controller.loadRootItems(args.level);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(controller),
          _buildHeaderSection(controller, searchController),
          _buildContentSection(controller),
        ],
      ),
      floatingActionButton: Obx(() {
        // Only show refresh button when there's data and not currently loading
        if (controller.displayItems.isNotEmpty && !controller.isLoading.value && !controller.isLoadingDetail.value) {
          return FloatingActionButton(
            onPressed: () => controller.refresh(),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.refresh),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildAppBar(ListController controller) {
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
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppTheme.neutral700,
            ),
          ),
        ),
      ),
      title: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getBreadcrumbText(controller),
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral900,
                    ),
                  ),
                ),
                if (controller.isLoading.value || controller.isLoadingDetail.value)
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
            ),
            if (controller.selectedItem.value != null)
              Text(
                controller.selectedItem.value!.displayName,
                style: AppTypography.bodySmall.copyWith(
                  color: AppTheme.neutral500,
                ),
              ),
          ],
        );
      }),
    );
  }

  String _getBreadcrumbText(ListController controller) {
    final selectedItem = controller.selectedItem.value;
    final currentLevel = controller.currentLevel;
    
    if (selectedItem != null && currentLevel != null) {
      return '${selectedItem.level.displayName} > ${currentLevel.displayName}';
    } else if (controller.currentItems.isNotEmpty) {
      return controller.currentItems.first.level.displayName;
    }
    return 'Items';
  }

  Widget _buildHeaderSection(ListController controller, TextEditingController searchController) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.surface,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildSelectedItemCard(controller),
                  const SizedBox(height: AppSpacing.lg),
                  _buildToggleTabs(controller),
                ],
              ),
            ),
            Container(height: 1, color: AppTheme.border),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItemCard(ListController controller) {
    return Obx(() {
      if (controller.selectedItem.value == null) return const SizedBox.shrink();

      final selectedItem = controller.selectedItem.value!;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryLight],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _getIconForLevel(selectedItem.level),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedItem.displayName,
                    style: AppTypography.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    selectedItem.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToggleTabs(ListController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                label: 'Detail',
                isActive: controller.isShowingDetail.value,
                onTap: () => controller.toggleView(),
                isDisabled: !controller.canToggleDetail,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTabButton(
                label: 'List',
                isActive: !controller.isShowingDetail.value,
                onTap: () => controller.toggleView(),
                isDisabled: false,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isActive && !isDisabled
            ? AppTheme.primary
            : (isDisabled ? AppTheme.neutral100 : Colors.transparent),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: isActive && !isDisabled ? AppShadows.card : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: isDisabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDisabled && label.contains('Detail'))
                  const Icon(
                    Icons.block,
                    size: 14,
                    color: AppTheme.neutral400,
                  ),
                if (isDisabled && label.contains('Detail'))
                  const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isDisabled 
                        ? AppTheme.neutral400
                        : (isActive ? Colors.white : AppTheme.neutral500),
                    fontWeight: isActive && !isDisabled 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(ListController controller) {
    return SliverToBoxAdapter(
      child: Obx(() => controller.isShowingDetail.value ? _buildDetailView(controller) : _buildListView(controller)),
    );
  }

  Widget _buildListView(ListController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: SkeletonLoader.listItemSkeleton(),
              ),
            ),
          ),
        );
      }

      // Show error state if there's an error and no items
      if (controller.errorMessage.value != null && controller.displayItems.isEmpty) {
        return _buildListErrorState(controller);
      }

      final items = controller.displayItems;

      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _buildEmptyState(),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildItemCard(item, controller),
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.xxxl),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No items available',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Items will appear here when available',
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

  Widget _buildListErrorState(ListController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                borderRadius: BorderRadius.circular(AppRadius.xxxl),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to Load Data',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              controller.errorMessage.value ?? 'Unknown error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (controller.selectedItem.value != null) {
                      controller.retryLoadChildren();
                    } else {
                      controller.retryLoadRootItems();
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Try Again'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ListItem item, ListController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () => _handleItemTap(item, controller),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getColorForLevel(item.level).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _getColorForLevel(item.level).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getIconForLevel(item.level),
                    color: _getColorForLevel(item.level),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppTheme.neutral900,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppTheme.neutral500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppTheme.borderLight, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppTheme.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView(ListController controller) {
    return Obx(() {
      if (controller.isLoadingDetail.value) {
        return _buildDetailLoadingState();
      }
      
      if (controller.detailError.value != null) {
        return _buildDetailErrorState(controller);
      }
      
      if (controller.selectedDetail.value == null) {
        return _buildNoDetailState();
      }
      
      return _buildDetailWidgetForLevel(controller.selectedDetail.value);
    });
  }

  Widget _buildDetailLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: SkeletonLoader.listItemSkeleton(),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailErrorState(ListController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error Loading Detail',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              controller.detailError.value ?? 'Unknown error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.retryLoadDetail(),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Retry'),
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
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                TextButton(
                  onPressed: () => controller.toggleView(),
                  child: const Text('Back to List'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDetailState() {
    return Container(
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
              child: const Icon(
                Icons.info_outline,
                size: 40,
                color: AppTheme.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Detail Available',
              style: AppTypography.h3.copyWith(
                color: AppTheme.neutral700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Detail information is not available',
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

  Widget _buildDetailWidgetForLevel(dynamic detail) {
    if (detail is CompanyDetail) {
      return CompanyDetailWidget(detail: detail);
    } else if (detail is BranchDetail) {
      return BranchDetailWidget(detail: detail);
    } else if (detail is WarehouseDetail) {
      return WarehouseDetailWidget(detail: detail);
    }
    
    return _buildGenericDetailWidget(detail);
  }

  Widget _buildPlaceholderDetailWidget(String type, String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppTheme.infoLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppTheme.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outlined,
                  color: AppTheme.info,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '$type detail widget will be implemented soon for $name',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppTheme.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericDetailWidget(dynamic detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'Detail loaded: ${detail.toString()}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(ListItem item, ListController controller) {
    if (item.level == ListLevel.product) {
      controller.navigateToProductDetail(item);
    } else {
      controller.selectItemAndValidate(item);
    }
  }

  IconData _getIconForLevel(ListLevel level) {
    switch (level) {
      case ListLevel.company:
        return Icons.business_outlined;
      case ListLevel.branch:
        return Icons.store_outlined;
      case ListLevel.warehouse:
        return Icons.warehouse_outlined;
      case ListLevel.product:
        return Icons.inventory_2_outlined;
    }
  }

  Color _getColorForLevel(ListLevel level) {
    switch (level) {
      case ListLevel.company:
        return AppTheme.primary;
      case ListLevel.branch:
        return AppTheme.success;
      case ListLevel.warehouse:
        return AppTheme.warning;
      case ListLevel.product:
        return const Color(0xFF8B5CF6);
    }
  }
}