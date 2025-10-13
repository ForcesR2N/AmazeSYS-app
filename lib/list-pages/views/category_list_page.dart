import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_list_controller.dart';
import '../models/list_item.dart';
import '../widgets/skeleton_loader.dart';
import '../../core/theme/app_theme.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryListController controller =
        Get.find<CategoryListController>();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.surfaceVariant,
      body: RefreshIndicator(
        onRefresh: controller.refreshItems,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(controller),
            _buildSearchSection(controller, searchController),
            _buildContentSection(controller, searchController),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(CategoryListController controller) {
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
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: controller.levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                controller.levelIcon,
                color: controller.levelColor,
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
                      'Loading...',
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

  Widget _buildSearchSection(
    CategoryListController controller,
    TextEditingController searchController,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.surface,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: searchController,
                onChanged: controller.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: controller.searchPlaceholder,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppTheme.neutral400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.neutral400,
                    size: 20,
                  ),
                  suffixIcon: Obx(
                    () =>
                        controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppTheme.neutral400,
                                size: 20,
                              ),
                              onPressed: () {
                                searchController.clear();
                                controller.updateSearchQuery('');
                              },
                            )
                            : const SizedBox.shrink(),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide(color: AppTheme.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppTheme.neutral700,
                ),
              ),
            ),
            Container(height: 1, color: AppTheme.border),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(
    CategoryListController controller,
    TextEditingController searchController,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingSliver();
      }

      // Show error state if there's an error and no items
      if (controller.errorMessage.value != null &&
          controller.filteredItems.isEmpty) {
        return SliverToBoxAdapter(child: _buildErrorState(controller));
      }

      final items = controller.filteredItems;

      if (items.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildEmptyState(controller, searchController),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= items.length) return null;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : AppSpacing.md,
              ),
              child: _buildItemCard(items[index], controller),
            );
          }, childCount: items.length),
        ),
      );
    });
  }

  Widget _buildLoadingSliver() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SkeletonLoader.listItemSkeleton(),
          );
        }, childCount: 6),
      ),
    );
  }

  Widget _buildEmptyState(
    CategoryListController controller,
    TextEditingController searchController,
  ) {
    final isSearching = controller.searchQuery.value.isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 400),
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
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 48,
              color: AppTheme.neutral400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isSearching
                ? 'No search results'
                : 'No ${controller.currentLevel.displayName.toLowerCase()}s available',
            style: AppTypography.h3.copyWith(
              color: AppTheme.neutral700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isSearching
                ? 'Try adjusting your search terms'
                : '${controller.currentLevel.displayName}s will appear here when available',
            style: AppTypography.bodyLarge.copyWith(color: AppTheme.neutral500),
            textAlign: TextAlign.center,
          ),
          if (isSearching) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: () {
                searchController.clear();
                controller.updateSearchQuery('');
              },
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear search'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _buildErrorState(CategoryListController controller) {
  return Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 400),
    padding: const EdgeInsets.all(AppSpacing.xl),
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
          style: AppTypography.bodyMedium.copyWith(color: AppTheme.neutral500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: controller.loadItems,
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
  );
}

Widget _buildItemCard(ListItem item, CategoryListController controller) {
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
        onTap: () => controller.navigateToDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: controller.levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: controller.levelColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  controller.levelIcon,
                  color: controller.levelColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppTheme.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.code,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppTheme.neutral500,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppTheme.neutral600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
